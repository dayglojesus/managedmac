require 'pry'
require 'puppet/managedmac/common'

Puppet::Type.newtype(:mobileconfig) do
  
  ensurable
  
  newparam(:name) do
    isnamevar
  end
  
  newproperty(:content, :array_matching => :all) do
    desc "Array of Hashes containing the payload data for the profile. 
    Each hash is a key/value store represnting the payload settings
    a given PayloadType.
    
    * This content can be complicated to construct manually.
    * You should always include an appropriate PayloadType key/value
      for each Hash in the Array.
    
    Corresponds to PayloadContent."
    
    def is_to_s(value)
      value.hash
    end
    
    def should_to_s(value)
      value.hash
    end
    
    munge do |value|
      ::ManagedMacCommon::destringify value
    end
    
  end
  
  newproperty(:description) do
    desc "String that describes what this profile does.
      Corresponds to PayloadDescription."
    validate do |value|
      unless value.is_a? String
        raise ArgumentError, "Expected String, got #{value.class}"
      end
    end
    defaultto 'Installed by Puppet'
  end
  
  newproperty(:displayname) do
    desc "String displayed as the title common name for this profile.
      Corresponds to PayloadDisplayName."
    validate do |value|
      unless value.is_a? String
        raise ArgumentError, "Expected String, got #{value.class}"
      end
    end
    defaultto { "Puppet Mobile Config: " + @resource[:name] }
  end
  
  # Not implemented
  # newproperty(:identifier) do
  #   desc "String uniquely identifying this profile.
  #     Corresponds to PayloadIdentifier."
  #   validate do |value|
  #     unless value.is_a? String
  #       raise ArgumentError, "Expected String, got #{value.class}"
  #     end
  #   end
  #   defaultto { [@resource[:name], Facter.sp_platform_uuid, 'alacarte' ].join('.') }
  # end
  
  newproperty(:organization) do
    desc "String that describes the org that prodcued the profile.
      Corresponds to PayloadOrganization."
    validate do |value|
      unless value.is_a? String
        raise ArgumentError, "Expected String, got #{value.class}"
      end
    end
    defaultto 'Puppet Labs'
  end
  
  newproperty(:removaldisallowed) do
    desc "Bool: whether or not to allow the removal of the profile. 
      Setting this to false means it can be removed. Don't blame me
      for the stupid name, blame Apple.
      Corresponds to PayloadRemovalDisallowed."
    newvalues(:true, :false)
    defaultto :false
  end
  
end