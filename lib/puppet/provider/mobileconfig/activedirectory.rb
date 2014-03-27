require 'puppet/provider/mobileconfig'

Puppet::Type.type(:mobileconfig).provide(:activedirectory, 
  :parent => Puppet::Provider::MobileConfig) do
  
  commands :profiles => '/usr/bin/profiles'
  
  mk_resource_methods
  
  # Override the #content getter so that we can interecept any
  # any Password key/values.
  #
  # This has to do with the manner which we determine whether or not a profile
  # is actually installed. When /usr/bin/profiles returns the list of 
  # installed profiles, it scrubs passwords, so we can never know the real
  # value. This isn;t such a problem for a bind operation, but it does mean 
  # that this value is NOT idempotent (ie. changes to this value, will not
  # trigger a puppet apply).
  #
  def content
    if @resource[:content]
      return @property_hash[:content].each_with_index.map do |hash, i|
        if hash.key?('Password')
          hash['Password'] = @resource[:content][i]['Password']
          hash
        end
      end
    end
    @property_hash[:content]
  end
  
end