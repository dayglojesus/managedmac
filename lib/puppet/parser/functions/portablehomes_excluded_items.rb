module Puppet::Parser::Functions
  newfunction(:portablehomes_excluded_items, :type => :rvalue, :doc => <<-EOS
Returns a Array of properly formatted excludeItems Hashes.
    EOS
  ) do |args|

    if args.size != 1
      e = "portablehomes_excluded_items(): Too many args! (#{args.size} instead of 1)"
      raise(Puppet::ParseError, e)
    end

    unless args[0].is_a? Hash
      e = "portablehomes_excluded_items(): Wrong arg type! (#{args[0].class} instead of Hash)"
      raise(Puppet::ParseError, e)
    end

    args[0].inject([]) do |memo,(k,v)|
      v.each do |p|
        memo << {'comparison' => k, 'value' => p}
      end
      memo
    end

  end
end