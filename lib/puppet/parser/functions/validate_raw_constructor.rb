module Puppet::Parser::Functions
  newfunction(:validate_raw_constructor, :doc => <<-EOS
Specialized function used to validate raw constructor class resource hashes.
Expects the value of each key in the resource param to be Hash. If the value is
not a Hash it's rejected. If the the Hash is exhausted, the resource is
"validated".
    EOS
  ) do |args|

    e = "validate_raw_constructor(): Wrong number of args: #{args.size} for 1"
    raise(Puppet::ParseError, e) if args.size != 1

    resources = args.first.dup
    resources.reject! { |k,v| v.respond_to? :key }

    e = "one or more invalid resources: #{resources}"
    raise(Puppet::ParseError, e) unless resources.empty?
  end
end
