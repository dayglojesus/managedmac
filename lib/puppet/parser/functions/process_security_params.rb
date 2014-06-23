module Puppet::Parser::Functions
  newfunction(:process_security_params, :type => :rvalue, :doc => <<-EOS
Returns a Payload Array for configuring a Loginwindow profile.
    EOS
  ) do |args|

    if args.size != 1
      e = "process_security_params(): Wrong number of args: #{args.size} for 1"
      raise(Puppet::ParseError, e)
    end

    params = args[0]

    unless params.is_a? Hash
      e = "process_security_params(): Wrong arg type! (#{params.class} instead of Hash)"
      raise(Puppet::ParseError, e)
    end

    params.inject([]) do |memo, (domain,hash)|
      hash.delete_if { |k,v| (v.respond_to? :empty? and v.empty?) or v == :undef }
      unless hash.empty?
        hash['PayloadType'] = domain
        memo << hash
      end
      memo
    end

  end
end
