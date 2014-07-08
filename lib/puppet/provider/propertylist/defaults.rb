require 'puppet/provider/propertylist'

Puppet::Type.type(:propertylist).provide(:defaults,
  :parent => Puppet::Provider::PropertyList) do

  commands :defaults => '/usr/bin/defaults'

  mk_resource_methods

  class << self

    def write_plist(path, content, format)
      super
      defaults_in = `/usr/bin/defaults read #{path}`.chomp
      defaults 'write', path, defaults_in
    end

  end

end