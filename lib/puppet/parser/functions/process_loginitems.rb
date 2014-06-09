require 'puppet'
module Puppet::Parser::Functions
  newfunction(:process_loginitems, :type => :rvalue, :doc => <<-EOS
Returns a Payload Hash of properly formatted Login Items. Expects Array.
    EOS
  ) do |args|

    if args.size != 2
      e = "process_loginitems(): Wrong number of args: #{args.size} for 2"
      raise(Puppet::ParseError, e)
    end

    filesandfolders, urls = *args

    unless filesandfolders.is_a? Array
      e = "excluded_items(): Wrong arg type! (#{filesandfolders.class} instead of Array)"
      raise(Puppet::ParseError, e)
    end

    unless urls.is_a? Array
      e = "excluded_items(): Wrong arg type! (#{urls.class} instead of Array)"
      raise(Puppet::ParseError, e)
    end

    unless filesandfolders.empty?
      filesandfolders.collect! { |p| Hash['Hide', false, 'Path', p] }
    end

    unless urls.empty?
      urls.collect! { |u| Hash['AuthenticateAsLoginUserShortName', true,
        'Hide', false, 'URL', u] }
    end

    Hash['PayloadType', 'com.apple.loginitems.managed',
      'AutoLaunchedApplicationDictionary-managed',
      [filesandfolders, urls].flatten
    ]
  end
end
