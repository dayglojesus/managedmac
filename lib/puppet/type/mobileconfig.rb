require 'puppet/managedmac/common'

Puppet::Type.newtype(:mobileconfig) do
  @doc = %q{Dynamically create and manage OS X .mobileconfig profiles

  A custom Puppet type for delivering policy via OS X profiles.

  When you define a Mobileconfig resource, a .mobileconfig file containing the
  settings you specified oin the resource is automatically generated and
  installed.

  Use of this custom type can be complicated if you don't understand the basic
  structure of a .mobileconfig file.

  If you need to do some trench work with profiles, I recommend you abstract
  the mobileconfig resource by wrappping it in a parameterized Puppet class,
  as per the various classes in this module. See the activedirectory.pp file
  for an example of this pattern.

  ==== USAGE ====

  # Create an Array of 1 or more PayloadContent Hashes
  # - You can stack multiple PayloadContent Hashes inside the Array
  # - Each Hash is a single payload
  # - Each payload contains key/value pairs representing the settings you want
  # to manage
  # - You MUST include a PayloadType key for this to work

  $content = [{ 'contents-immutable' => true,
    'largesize' => 128,
    'orientation' => 'left',
    'tilesize' => 128,
    'autohide' => true,
    'PayloadType' => 'com.apple.dock'
  }]

  # The resource name MUST be unique!
  # - Only the :name and :content properties are required
  mobileconfig { 'puppetlabs.dock.alacarte':
    ensure       => present,
    displayname  => 'Puppet Labs: Dock Settings',
    description  => 'Dock configuration. Installed by Puppet.',
    organization => 'Puppet Labs',
    content      => $options,
  }

  # You can remove an existing profile just like any other Puppet resource
  mobileconfig { 'puppetlabs.dock.alacarte':
    ensure => absent,
  }

  # Use the puppet resource command to get a list of installed profiles:
  `sudo puppet resource mobileconfig`

  # Remove the profile using puppet resource...
  `sudo puppet resource mobileconfig puppetlabs.dock.alacarte ensure=absent`
  }

  ensurable

  newparam(:name) do
    isnamevar
  end

  newproperty(:content, :array_matching => :all) do
    desc "Array of Hashes containing the payload data for the profile.
    Each hash is a key/value store represnting the payload settings
    a given PayloadType.

    * This content can be complicated to construct manually.
    * Required Keys: PayloadIdentifier, PayloadType
    * You should always include a unique PayloadIdentifier key/value
      for each Hash in the Array.
    * You should always include an appropriate PayloadType key/value
      for each Hash in the Array.
    * Other Payload keys (PayloadDescription, etc.) will be ignored.

    Corresponds to the PayloadContent key."

    def is_to_s(value)
      value.hash
    end

    def should_to_s(value)
      value.hash
    end

    # Make sure that each of the Hashes in the Array contains PayloadType key
    #
    # - PayloadType: required by OS X so that it knows which preference domain
    # is being managed in the profile; we do not validate the string, just it's
    # presence. If you fail to provide a valid domain, profile installation
    # will fail outright.
    #
    validate do |value|
      required_keys = ['PayloadType']
      required_keys.each do |key|
        unless value.key?(key)
          raise ArgumentError, "Missing #{key} key! #{value.pretty_inspect}"
        end
      end
    end

    # Override #insync?
    #
    # This method is used to compare the 'is' (current resource settings) with
    # the 'should' values (desired resource settings).
    #
    # Doing this is tricky because `/usr/bin/profiles` does not always
    # return complete information about the profiles we've installed. As a
    # workaround, we...
    #
    #    1. calculate an MD5 sum of the content
    #    2. convert that value to a UUID
    #    3. inject it into the each of the Payload objects
    #
    # Then, rather than granularly comparing each resource attribute, we only
    # compare the MD5 sums.
    #
    def insync?(is)
      key = 'PayloadUUID'

      # Return false if the two arrays are not of equal length
      return false unless is.length == should.length

      # Shoehorn the MD5 sums
      should.collect! do |hash|
        hash[key] = ::ManagedMacCommon::content_to_uuid hash.sort
        hash
      end

      # Sort the arrays
      i, s = [is, should].each do |a|
        a.sort! { |x, y| x[key] <=> y[key] }
      end

      # Compare ONLY the PayloadUUIDs
      result = i.collect.each_with_index do |a, index|
        s[index][key] == a[key]
      end

      # Is each result true?
      result.all?
    end

    # Normalize the :content array
    munge do |value|
      value = ::ManagedMacCommon::destringify value
      # Scrub keys
      ::ManagedMacCommon::FILTERED_PAYLOAD_KEYS.each do |key|
        value.delete_if { |k| k.eql?(key) }
      end
      value
    end

  end

  newproperty(:description) do
    desc "String that describes what this profile does.
      Corresponds to the PayloadDescription key."
    validate do |value|
      unless value.is_a? String
        raise ArgumentError, "Expected String, got #{value.class}"
      end
    end
    defaultto 'Installed by Puppet'
  end

  newproperty(:displayname) do
    desc "String displayed as the title common name for this profile.
      Corresponds to the PayloadDisplayName key."
    validate do |value|
      unless value.is_a? String
        raise ArgumentError, "Expected String, got #{value.class}"
      end
    end
    defaultto { "Puppet Mobile Config: " + @resource[:name] }
  end

  newproperty(:organization) do
    desc "String that describes the org that prodcued the profile.
      Corresponds to the PayloadOrganization key."
    validate do |value|
      unless value.is_a? String
        raise ArgumentError, "Expected String, got #{value.class}"
      end
    end
    defaultto 'Simon Fraser University'
  end

  newproperty(:removaldisallowed) do
    desc "Bool: whether or not to allow the removal of the profile.
      Setting this to false means it can be removed. Don't blame me
      for the stupid double-negative name, blame Apple.
      Corresponds to the PayloadRemovalDisallowed key."
    newvalues(:true, :false)
    defaultto :false

    def insync?(is)
      is.to_sym == should.to_sym
    end
  end

end
