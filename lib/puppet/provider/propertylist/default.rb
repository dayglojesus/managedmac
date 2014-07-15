require 'puppet/provider/propertylist'

Puppet::Type.type(:propertylist).provide(:default,
  :parent => Puppet::Provider::PropertyList) do

  defaultfor :operatingsystem  => :darwin

  mk_resource_methods

end