module Puppet::Parser::Functions
  newfunction(:process_mounts, :type => :rvalue, :doc => <<-EOS
Returns a Payload Hash of properly formatted mounts. Expects Array.
    EOS
  ) do |args|

    if args.size != 1
      e = "process_mounts(): Wrong number of args: #{args.size} for 1"
      raise(Puppet::ParseError, e)
    end

    urls = args[0]

    unless urls.is_a? Array
      e = "process_mounts(): Wrong arg type! (#{urls.class} instead of Array)"
      raise(Puppet::ParseError, e)
    end

    unless urls.empty?
      urls.collect! { |u| Hash['AuthenticateAsLoginUserShortName', true,
        'Hide', false, 'URL', u] }
    end

    Hash['PayloadType', 'com.apple.loginitems.managed',
      'AutoLaunchedApplicationDictionary-managed',
      [urls].flatten
    ]
  end
end
