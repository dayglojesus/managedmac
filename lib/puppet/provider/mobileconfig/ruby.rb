require 'puppet/provider/mobileconfig'

Puppet::Type.type(:mobileconfig).provide(:ruby, :parent => Puppet::Provider::MobileConfig) do
  
  commands :profiles => '/usr/bin/profiles'
  
  mk_resource_methods
  
end