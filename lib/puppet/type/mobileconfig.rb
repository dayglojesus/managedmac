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
    # - We need to sort the Arrays before performing an equality test. We do
    # this using the PayloadType key because it is guarnteed to be present.
    def insync?(is)
      # Dupe the is and should values
      i, s = is.dup, should.dup
      # Collect Arrays of sorted Hashes and compare those
      [i, s].collect! do |a|
        a.collect! do |hash|
          # We insert a PayloadUUID/MD5 sum into each Hash if it's missing
          unless hash['PayloadUUID']
            hash['PayloadUUID'] = ::ManagedMacCommon::content_to_uuid hash.sort
          end
          hash.sort
        end
        a.sort!
      end
      i == s
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
  end

end
