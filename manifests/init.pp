# == Class: managedmac
#
# Full description of class managedmac here.
#
# === Parameters
#
# Document parameters here.
#
# [*sample_parameter*]
#   Explanation of what this parameter affects and what it defaults to.
#   e.g. "Specify one or more upstream ntp servers as an array."
#
# === Variables
#
# Here you should define a list of variables that this module would require.
#
# [*sample_variable*]
#   Explanation of how this variable affects the funtion of this class and if
#   it has a default. e.g. "The parameter enc_ntp_servers must be set by the
#   External Node Classifier as a comma separated list of hostnames." (Note,
#   global variables should be avoided in favor of class parameters as
#   of Puppet 2.6.)
#
# === Examples
#
#  class { managedmac:
#    servers => [ 'pool.ntp.org', 'ntp.local.company.com' ],
#  }
#
# === Authors
#
# Author Name <author@domain.com>
#
# === Copyright
#
# Copyright 2014 Your name here, unless otherwise noted.
#
class managedmac {

  if $::osfamily != 'Darwin' {
    fail("unsupported osfamily: ${::osfamily}")
  }

  if $::macosx_productversion_major < 10.9 {
    fail("unsupported product version: ${::macosx_productversion_major}")
  }

  if is_hash(hiera('managedmac::ntp::options', false)) {
    contain managedmac::ntp
  }

  if is_hash(hiera('managedmac::activedirectory::options', false)) {
    contain managedmac::activedirectory
  }

  if is_hash(hiera('managedmac::loginwindow::acl', false)) {

    $loginwindow_acl   = hiera('managedmac::loginwindow::acl')
    $loginwindow_group = 'com.apple.access_loginwindow'

    managedmac::acl {'com.apple.access_loginwindow':
      users   => $loginwindow_acl[users],
      groups  => $loginwindow_acl[groups],
      destroy => true,
    }

  } else {

    managedmac::acl {'com.apple.access_loginwindow':
      state   => disabled,
      destroy => true,
    }

  }

  if type(hiera('managedmac::loginhook::enable')) == 'boolean' {
    contain managedmac::loginhook
  }

}
