require 'cfpropertylist'
require 'securerandom'
require 'fileutils'
require 'puppet/managedmac/common'

class Puppet::Provider::MobileConfig < Puppet::Provider

  confine :operatingsystem  => :darwin

  class << self

    # Returns an Array of a provider instances for every resource discovered
    def instances
      fetch_resources(true)
    end

    # Puppet MAGIC
    def prefetch(resources)
      fetch_resources.each do |prov|
        if resource = resources[prov.name]
          resource.provider = prov
        end
      end
    end

    # Rather than letting #instances control what a resource looks like, def
    # a method to collect the data. This way we can choose whterh or not to
    # scrub the PayloadUUID which we now use as a checksum.
    def fetch_resources(scrub_uuids=false)
      all = get_installed_profiles
      all.collect do |profile|
        resource = get_resource_properties(profile)
        if scrub_uuids
          resource[:content].collect! do |hash|
            hash.delete('PayloadUUID')
            hash
          end
        end
        new(resource)
      end
    end

    # Use the profiles command to return an array containing a Hash
    # representation of each of the profiles installed
    # Returns: Array
    def get_installed_profiles
      # Setup a tmp dir we can dump the installed profiles in
      dir  = Dir.mktmpdir
      path = [dir, "profiles#{SecureRandom.hex}.plist"].join("/")

      begin
        profiles(['-P', '-o', path])
      rescue Puppet::ExecutionFailure => e
        raise Puppet::Error, "#mobileconfig: command returned non-zero
          `profiles -P -o #{path}`"
      end

      # Parse the plist and remove it
      parsed = parse_propertylist path
      FileUtils.rm_rf path

      # Return an empty array if there are no profiles installed
      return [] if parsed.empty?

      parsed['_computerlevel']
    end

    # Profile read from profile dump goes in, Puppet resource comes out
    def get_resource_properties(profile)

      # No profile, empty Hash
      return {} if profile.nil?

      # Adjust for a key change in Yosemite as per
      # https://github.com/dayglojesus/managedmac/issues/21
      # They changed this key to match what it would be if it
      # were in a Payload. Yay, parity?
      removal_disallowed_key = if profile['ProfileUninstallPolicy']
        # Mavericks
        profile['ProfileUninstallPolicy'] == 'allowed' ? 'false' : 'true'
      else
        # Yosemite
        profile['ProfileRemovalDisallowed']
      end

      # Prepare the content array for insertion into the resource
      content = prepare_content(profile['ProfileItems'])

      # Ladies and gentleman, the Puppet resource as a Hash
      {
        :name              => profile['ProfileIdentifier'],
        :description       => profile['ProfileDescription'],
        :displayname       => profile['ProfileDisplayName'],
        :organization      => profile['ProfileOrganization'],
        :removaldisallowed => removal_disallowed_key,
        :provider          => :mobileconfig,
        :ensure            => :present,
        :content           => content,
      }
    end

    # Formats the PayloadContent data for use the in the resource
    def prepare_content(content)
      content.collect do |item|
        # Extract the PayloadContent
        settings = item.delete('PayloadContent')

        # Scrub the filtered keys
        ::ManagedMacCommon::FILTERED_PAYLOAD_KEYS.each do |key|
          item.delete_if     { |k| k.eql?(key) }
          settings.delete_if { |k| k.eql?(key) }
        end

        # Reject AD Flag keys
        # We do this here so the `puppet resource mobileconfig ...` will return
        # the correct :content no matter which provider is used. This feels
        # cheap, but it is economical and may be required by other subclasses
        # of the mobielconfig provider down the road.
        settings.reject! { |k| k =~ /\AAD.*Flag\z/ }

        item.merge settings
      end
    end

    # Parse a plist and return a Ruby object
    def parse_propertylist(file)
      plist = CFPropertyList::List.new(:file => file)
      raise Puppet::Error, "Cannot parse: #{file}" if plist.nil?
      CFPropertyList.native_types(plist.value)
    end

  end

  def initialize(value={})
    super(value)
    @property_flush = {}

    # A little Ruby metaprogramming magic...
    #
    # Insert a singleton method after intialization that overrides the #content
    # getter so that we can intercept any Password key/values.
    #
    # To enable this to work with the `mk_resource_methods` method (a class
    # method which we like for its convenience) the content method must be
    # fasionably late to the party. So, use the define_singleton_method after
    # super init to ensure our method isn't squashed.
    #
    # Why do we need this method override?
    #
    # Certain PayloadTypes contain information that gets scrubbed from the
    # `/usr/bin/profiles` output. In particular, these:
    # - com.apple.wifi.managed
    # - com.apple.firstactiveethernet.managed
    # - com.apple.DirectoryService.managed
    #
    # All of these PayloadTypes use a Password key whose value is output as:
    # '********' -- negating Puppet's ability to compare it with the content
    # specified in the resource declaration.
    #
    # As a workaround, we perform a substitution, re-inserting the specified
    # value. This is sub-optimal and means that this value is
    # NOT IDEMPOTENT (ie. changes to this value, will not trigger a puppet
    # apply).
    #
    # However, there is a workaround if you follow this rule of thumb:
    #
    # If you change the password, rotate/change/set the PayloadUUID inside
    # the affected Payload.
    #
    # Doing this will signal Puppet that something has changed and it will
    # reinstall the profile.

    define_singleton_method(:content) do
      if @resource[:content] and not @resource[:content].empty?
        return @property_hash[:content].each_with_index.map do |hash, i|
          if hash.key?('Password')
            hash['Password'] = @resource[:content][i]['Password']
          end
          hash
        end
      end
      @property_hash[:content] || :absent
    end

  end

  def create
    @property_flush[:ensure] = :present
  end

  def destroy
    @property_flush[:ensure] = :absent
  end

  def exists?
    @property_hash[:ensure] == :present
  end

  # This used to be accomplished in the :activedirectory provider, but we are
  # collapsing this functionality back into the parent class and abandoning the
  # sub-classed provider.
  #
  # The Advanced Active Directory profile contains flag keys which inform
  # the installation process which configuration keys should actually be
  # activated.
  #
  # http://support.apple.com/kb/HT5981?viewlocale=en_US&locale=en_US
  #
  # For example, if we wanted to change the default shell for AD accounts, we
  # would actually need to define two keys: a configuration key and a flag key.
  #
  # <key>ADDefaultUserShell</key>
  # <string>/bin/zsh</string>
  #
  # <key>ADDefaultUserShellFlag</key>
  # <true/>
  #
  # If you fail to specify this second key (the activation or "flag" key), the
  # configuration key will be ignored when the mobileconfig is processed.
  #
  # To avoid having to activate and deactivate the configuration keys, we
  # pre-process the content array by overriding the transform_content method
  # and shoehorn these flag keys into place dynamically, as required.
  #
  def add_activedirectory_keys(payload)
    needs_flag = ['ADAllowMultiDomainAuth',
                  'ADCreateMobileAccountAtLogin',
                  'ADDefaultUserShell',
                  'ADDomainAdminGroupList',
                  'ADForceHomeLocal',
                  'ADNamespace',
                  'ADPacketEncrypt',
                  'ADPacketSign',
                  'ADPreferredDCServer',
                  'ADRestrictDDNS',
                  'ADTrustChangePassIntervalDays',
                  'ADUseWindowsUNCPath',
                  'ADWarnUserBeforeCreatingMA',]

    needs_flag.each do |e|
      if payload.key?(e)
        flag_key = e + 'Flag'
        payload[flag_key] = true
      end
    end
    payload
  end

  # Validates a String as a com.apple.security.pkcs1 Certificate Payload
  # - will decode Base64 if it can
  def parse_cert_data_from_string(string)
    begin
      OpenSSL::X509::Certificate.new string
    rescue OpenSSL::X509::CertificateError
      begin
        string = Base64.decode64(string)
        OpenSSL::X509::Certificate.new string
      rescue OpenSSL::X509::CertificateError => e
        raise Puppet::Error, "##{__method__}:
          Could not parse certificate data! [#{e.message}]"
      end
    end
    string
  end

  # Validates a Blob as a com.apple.security.pkcs1 Certificate Payload
  def parse_cert_data_from_blob(blob)
    begin
      blob = Base64.decode64(blob)
      OpenSSL::X509::Certificate.new blob
    rescue OpenSSL::X509::CertificateError => e
      raise Puppet::Error, "##{__method__}:
        Could not parse certificate data! [#{e.message}]"
    end
    blob
  end

  # Processes the com.apple.security.pkcs1 PayloadContent as required
  #
  # This provider allows PayloadContent for com.apple.security.pkcs1
  # to be expressed as PEM (ASCII), Base64 Encoded binary, or a Base64
  # encoded CFPropertyList::Blob.
  #
  # Parsable data is validated using OpenSSL.
  #
  # It should be able to determine what you are passing in, but if it
  # can't, an Exception is raised.
  #
  def process_certificate_payload(payload)
    data = case payload['PayloadContent']
    when CFPropertyList::Blob
      parse_cert_data_from_blob(payload['PayloadContent'])
    when String
      parse_cert_data_from_string(payload['PayloadContent'])
    else
      raise Puppet::Error, "Invalid Certificate Data!"
    end
    payload['PayloadContent'] = CFPropertyList::Blob.new data
    payload
  end

  # Formats and fortifies the PayloadContent array
  # - ensures required keys to each Hash
  def transform_content(content)
    return [] if content.empty?
    content.collect! do |payload|

      # PayloadUUID for each Payload is modified MD5 sum of Payload itself,
      # minus any of the other ephemeral keys. We can use this to check whether
      # or not the content has been modified. Even when the Payload attributes
      # cannot be compared (ie. Password keys).

      payload.delete('PayloadUUID')
      embedded_payload_uuid = ::ManagedMacCommon::content_to_uuid payload.sort
      embedded_payload_id   = payload['PayloadIdentifier'] || [@resource[:name],
                                      embedded_payload_uuid].join('.')
      payload.merge!({
        'PayloadIdentifier' => embedded_payload_id,
        'PayloadUUID'       => embedded_payload_uuid,
        'PayloadEnabled'    => true,
        'PayloadVersion'    => 1,
      })

      case payload['PayloadType']
      when 'com.apple.DirectoryService.managed'
        add_activedirectory_keys(payload)
      when 'com.apple.security.pkcs1'
        process_certificate_payload(payload)
      else
        payload
      end
    end
  end

  # Provider Helper method
  # Build and install the mobileconfig OR destroy it
  def coalesce_mobileconfig

    if @property_flush[:ensure] == :absent

      # Remove the profile
      id = @resource[:name]
      begin
        profiles(['-R', '-p', id])
      rescue Puppet::ExecutionFailure => e
        raise Puppet::Error, "#mobileconfig: command returned
          non-zero `profiles -R -p #{id}`"
      end

    else
      # Create a tmp dir we can use to house the .mobileconfig
      path = [Dir.mktmpdir, "#{SecureRandom.hex}.mobileconfig"].join("/")

      # Transform @resource into usable Hash
      document = {
        'PayloadIdentifier'        => @resource[:name],
        'PayloadDescription'       => @resource[:description],
        'PayloadDisplayName'       => @resource[:displayname],
        'PayloadOrganization'      => @resource[:organization],
        'PayloadRemovalDisallowed' =>
          @resource[:removaldisallowed] == :false ? false : true,
        'PayloadScope'             => 'System',
        'PayloadType'              => 'Configuration',
        'PayloadUUID'              => SecureRandom.uuid,
        'PayloadVersion'           => 1,
        'PayloadContent'           => transform_content(@resource[:content]),
      }

      # Parse the document Hash and create new plist file
      plist       = CFPropertyList::List.new
      plist.value = CFPropertyList.guess(document)
      plist.save(path, CFPropertyList::List::FORMAT_XML)

      begin
        profiles(['-I', '-F', path])
      rescue Puppet::ExecutionFailure => e
        raise Puppet::Error, "#mobileconfig: command returned non-zero
          `profiles -I -F #{path}`"
      end

      FileUtils.rm_rf path if File.exists? path
    end

  end

  # Puppet MAGIC
  # The flush method is called once per resource whenever the
  # ‘is’ and ‘should’ values for a property differ
  # (and synchronization needs to occur).
  # As per Shit Gary Says: http://bit.ly/1j9ou3Q
  def flush
    coalesce_mobileconfig

    # Collect the resources again once they've been changed (that way `puppet
    # resource` will show the correct values after changes have been made).
    all_profiles = self.class.get_installed_profiles
    this_profile = all_profiles.find do |profile|
      profile['ProfileIdentifier'].eql? resource[:name]
    end

    @property_hash = self.class.get_resource_properties(this_profile)
  end

end
