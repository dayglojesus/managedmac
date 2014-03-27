require 'puppet/provider/mobileconfig'

Puppet::Type.type(:mobileconfig).provide(:basic, 
  :parent => Puppet::Provider::MobileConfig) do
  
  defaultfor :operatingsystem  => :darwin
  commands   :profiles         => '/usr/bin/profiles'
  
  mk_resource_methods
  
end