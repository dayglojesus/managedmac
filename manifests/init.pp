# == Class: managedmac
#
# Module initializer.
#
# This module only supports OS X 10.9 or greater.
#
# === Parameters
#
# None
#
# === Variables
#
# [*osfamily*]
#   The osfamily must be Darwin. If not, Puppet will fail.
#
# [*macosx_productversion_major*]
#   The macosx_productversion_major must be 10.9 or greate. If not, Puppet
#   will fail.
#
# === Examples
#
#  include managedmac
#
#  class { managedmac: }
#
# === Authors
#
# Brian Warsing <bcw@sfu.ca>
#
# === Copyright
#
# Copyright 2015 Simon Fraser University, unless otherwise noted.
#
class managedmac {

  if $::osfamily != 'Darwin' {
    fail("unsupported osfamily: ${::osfamily}")
  }

  $min_os_version = '10.9'

  if version_compare($::macosx_productversion_major, $min_os_version) < 0 {
    fail("unsupported product version: ${::macosx_productversion_major}")
  }

  contain managedmac::ntp
  contain managedmac::activedirectory
  contain managedmac::security
  contain managedmac::desktop
  contain managedmac::mcx
  contain managedmac::filevault
  contain managedmac::loginwindow
  contain managedmac::softwareupdate
  contain managedmac::authorization
  contain managedmac::energysaver
  contain managedmac::portablehomes
  contain managedmac::mounts
  contain managedmac::loginhook
  contain managedmac::logouthook
  contain managedmac::sshd
  contain managedmac::remotemanagement
  contain managedmac::screensharing
  contain managedmac::mobileconfigs
  contain managedmac::propertylists
  contain managedmac::execs
  contain managedmac::files
  contain managedmac::users
  contain managedmac::groups
  contain managedmac::cron

}
