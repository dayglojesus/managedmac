module Puppet::Parser::Functions
  newfunction(:compact_hash, :type => :rvalue, :doc => <<-EOS
Hash keys with empty or undef values are deleted. Returns resulting Hash.
    EOS
  ) do |args|

    e = "compact_hash(): Wrong number of args: #{args.size} for 1"
    raise(Puppet::ParseError, e) if args.size != 1

    the_hash = args.shift
    raise(Puppet::ParseError, "arg was not a Hash") unless the_hash.is_a? Hash

    the_hash.delete_if do |k,v|
      (v.empty? if v.respond_to? :empty?) or v == :undef or v.nil?
    end
  end
end
