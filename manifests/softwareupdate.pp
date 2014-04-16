# == Class: managedmac::softwareupdate
#
# Abstracts com.apple.SoftwareUpdate preference domain using Mobileconfig type.
#
# NOTE: Parameters trump matching keys in the options Hash. If you specify one
# of the defined parameters (ie. $catalog_url) and you also set the
# corresponding key somewhere in the options Hash, the value of the parameter
# will take precedence.
#
# === Parameters
#
# There 3 parameters. An exception will be raised if you do not specify at
# least one parameter.
#
# [*ensure*]
#   Whether the resources defined in this class should be applied or not.
#   Type: String
#   Accepts: present or absent
#   Default: present
#
# [*catalog_url*]
#   The URL for your Apple Software Update server. This will be validated using
#   regex, so it needs to at least have the appearnce of being a URL.
#   Type: String
#   e.g. "http://swscan.apple.com/content/catalogs/index-1.sucatalog"
#
# [*options*]
#   Raw com.apple.SoftwareUpdate pref keys. (See examples below)
#   Type: Hash
#   Default: empty
#
# === Variables
#
# Not applicable
#
# === Examples
# This class was designed to be used with Hiera. As such, the best way to pass
# options is to specify them in your Hiera datadir:
#
#  # Example: defaults.yaml
#  ---
#  managedmac::softwareupdate::catalog_url: http://foo.bar.com/whatever.dude
#  managedmac::softwareupdate::options:
#    CatalogURL: "http://swscan.apple.com/content/catalogs/index-1.sucatalog"
#
# Then simply, create a manifest and include the class...
#
#  # Example: my_manifest.pp
#  include managedmac::loginwindow
#
# If you just wish to test the functionality of this class, you could also do
# something along these lines:
#
#  # Create an options Hash
#  # - this will get trumped by the parameter we pass into the class!!!
#  $options = {
#   'CatalogURL' => 'YOU WILL NEVER SEE THIS',
#  }
#
#  class { 'managedmac::activedirectory':
#    catalog_url =>'http://swscan.apple.com/content/catalogs/index-1.sucatalog',
#    options => $options,
#  }
#
# === Authors
#
# Brian Warsing <bcw@sfu.ca>
#
# === Copyright
#
# Copyright 2014 Simon Fraser University, unless otherwise noted.
#
class managedmac::softwareupdate (

  $ensure       = present,
  $catalog_url  = '',
  $options      = {}

) {

  $all_params = {}

  # Only validate required variables if we are activating the resource
  if $ensure == present {

    validate_hash ($options)

    unless empty($catalog_url) {
      validate_re ($catalog_url, '\Ahttp:\/\/(\w+\.)+\w+\/')
      $all_params[CatalogURL] = $catalog_url
    }

    if empty($options) and empty($all_params) {
      fail('Missing Options: you have specified no params and the options
        Hash is empty')
    }

    # Merge the parameters into the options Hash
    # - parameters trump options
    $compiled_options = merge($options, $all_params)
    $compiled_options[PayloadType] = 'com.apple.SoftwareUpdate'

  } else {
    unless $ensure == 'absent' {
      fail("Parameter Error: invalid value for :ensure, ${ensure}")
    }
  }

  mobileconfig { 'managedmac.softwareupdate.alacarte':
    ensure       => $ensure,
    displayname  => 'Managed Mac: Software Update',
    description  => 'Software Update configuration. Installed by Puppet.',
    organization => 'Simon Fraser University',
    content      => [$compiled_options],
  }

}