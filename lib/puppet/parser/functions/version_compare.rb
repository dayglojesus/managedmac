module Puppet::Parser::Functions
  newfunction(:version_compare, :type => :rvalue, :doc => <<-EOS
Expects a pair of version strings. Returns Fixnum: -1 (<), 0 (=) or 1 (>)
    EOS
  ) do |args|

    if args.size != 2
      e = "version_compare(): Wrong number of args: #{args.size} for 2"
      raise(Puppet::ParseError, e)
    end

    Puppet::Util::Package.versioncmp(*args.collect(&:to_s))
  end
end
