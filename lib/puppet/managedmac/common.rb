module ManagedMacCommon
  
  FILTERED_PAYLOAD_KEYS = ['PayloadIdentifier',
                           'PayloadDescription',
                           'PayloadDisplayName',
                           'PayloadOrganization',
                           'PayloadRemovalDisallowed',
                           'PayloadScope',
                           'PayloadUUID',
                           'PayloadVersion',]
  
  # Recurse the data argument and transform it into real Ruby objects
  def self.destringify(data)
    case data
    when /\A-?\d+\z/ # Fixnum
      data.to_i
    when /\A-?\d+\.\d+\z/ # Float
      data.to_f
    when /\Atrue\z/ # TrueClass
      true
    when /\Afalse\z/ # FalseClass
      false
    when NilClass
      data.to_s
    when String, Fixnum, Float, TrueClass, FalseClass # Leave my elevator alone
      data
    when Array
      data.map { |e| destringify e }
    when Hash
      Hash[ data.map { |k, v| [k, destringify(v)] } ]
    else
      raise Puppet::Error, "Cast Error: #destringify unknown type: 
        #{data.class}, #{data}"
    end
  end
  
end

