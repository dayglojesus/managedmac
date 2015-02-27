module Puppet::Parser::Functions
  newfunction(:process_dsconfigad_params, :type => :rvalue, :doc => <<-EOS
Returns a Hash for Dsconfigad type suitable for consumption by
`create_resources`. It will compact the data and transform Booleans into the
preferred enable|disable toggle. Accepts a single argument, a Hash.
    EOS
  ) do |args|

    if args.size != 1
      e = "process_dsconfigad_params(): Wrong number of args: #{args.size} \
for 1"
      raise(Puppet::ParseError, e)
    end

    params = args[0]

    unless params.is_a? Hash
      e = "process_dsconfigad_params(): Wrong arg type! (#{params.class} \
instead of Hash)"
      raise(Puppet::ParseError, e)
    end

    params.inject({}) do |memo, (key,value)|
      value = case value
      when NilClass, :absent, :undef
        nil
      when TrueClass
        'enable'
      when FalseClass
        'disable'
      else
        value
      end
      unless value.nil? or (value.respond_to? :empty? and value.empty?)
        memo[key] = value
      end
      memo
    end

  end
end
