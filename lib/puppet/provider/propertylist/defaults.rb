require 'puppet/provider/propertylist'

Puppet::Type.type(:propertylist).provide(:defaults,
  :parent => Puppet::Provider::PropertyList) do

  commands :defaults => '/usr/bin/defaults'

  mk_resource_methods

  class << self

    # Override the write_plist method
    # In order to get preferences to sync, we need to use `defaults` or
    # HUP cfprefsd. Using defaults is preferred, and we trigger a sync
    # by writing a simple value to the prefs domain. This is silly, but it
    # appears to work. However, in cases where none of the desired values are
    # "simple", we just HUP cfprefsd. It's a bit dirty, but Apple isn't
    # really giving us any options when it comes to bulk editing preferences.
    def write_plist(path, content, format)
      super
      flag_map = {
        String     => '-string',
        Fixnum     => '-integer',
        Float      => '-float',
        TrueClass  => '-bool',
        FalseClass => '-bool',
      }
      content.each do |key, value|
        case value
        when String, Fixnum, Float, TrueClass, FalseClass
          flag = flag_map[value.class]
          return defaults 'write', path, key, flag, value
        else
        end
      end
      system('/usr/bin/killall cfprefsd')
    end

  end

end