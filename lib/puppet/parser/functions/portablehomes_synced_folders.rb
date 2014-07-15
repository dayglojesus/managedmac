module Puppet::Parser::Functions
  newfunction(:portablehomes_synced_folders, :type => :rvalue, :doc => <<-EOS
Returns a Array of properly formatted syncedFolder Hashes.
    EOS
  ) do |args|

    if args.size != 1
      e = "portablehomes_synced_folders(): Too many args! (#{args.size} instead of 1)"
      raise(Puppet::ParseError, e)
    end

    unless args[0].is_a? Array
      e = "portablehomes_synced_folders(): Wrong arg type! (#{args[0].class} instead of Array)"
      raise(Puppet::ParseError, e)
    end

    args[0].inject([]) do |memo,e|
      memo << {'path' => e}
      memo
    end

  end
end