module Puppet::Parser::Functions
  newfunction(:process_activedirectory_params, :type => :rvalue, :doc => <<-EOS
Returns a Payload Hash of for cofnigruing an Active Directory profile.
    EOS
  ) do |args|

    if args.size != 1
      e = "process_activedirectory_params(): Wrong number of args: #{args.size} for 1"
      raise(Puppet::ParseError, e)
    end

    params = args[0]

    unless params.is_a? Hash
      e = "process_activedirectory_params(): Wrong arg type! (#{params.class} instead of Hash)"
      raise(Puppet::ParseError, e)
    end

    return {} if params.empty?
      e = "process_activedirectory_params(): Params Hash is empty!"

    params.inject({}) do |memo,(k,v)|
      unless v.empty? or v == :undef
        memo[k.to_s] = v
      end
      memo
    end

  end
end
