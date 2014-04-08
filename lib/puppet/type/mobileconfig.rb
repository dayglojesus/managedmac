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
    
    # Override #insync?
    #
    # In this type, the _is_ value can be a superset of the _should_ value if
    # we are not strictly managing each key in each of of the Payloads. As such,
    # the simple equality test Puppet uses to determine state is inadequate.
    #
    # Instead, we first need to normalize the _should_ value by merging it into
    # the _is_ value. Then we can perform an equaity test with the _is_ and
    # NEW normalized _should_ value to give us the correct result.
    #
    def insync?(is)
      primary_key = 'PayloadIdentifier'
      hash = proc { Hash.new }
      normalized = is.collect do |e|
        id = e[primary_key]
        e.merge (should.detect(hash) { |e| e[primary_key].eql? id })
      end
      is.eql? normalized
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
