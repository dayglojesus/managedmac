# == Class: managedmac::screensharing
#
# Activates and controls the OS X ScreenSharing service.
#
# IMPORTANT: You cannot enable RemoteManagement and ScreenSharing. If the
# catalog contains resources for both these services, the RemoteManagement
# service will trump ScreenSharing.
#
# === Parameters
#
# [*enable*]
#   Whether to enable the service or not, true or false.
#   Type: Bool
#   Default: undef
#
# [*users*]
#   A list of user accounts permitted to access the service.
#   Type: Array
#   Default: []
#
# [*groups*]
#   A list of user groups permitted to access the service.
#   Type: Array
#   Default: ['admin']
#
# [*strict*]
#   How to handle membership in the users and nestedgroups arrays. Informs the
#   provider whether to merge the specified members into the record, or replace
#   them outright. See the Macgroup documentation for details.
#   Type: Boolean
#
# === Variables
#
# None
#
# === Examples
#
# This class was designed to be used with Hiera. As such, the best way to pass
# options is to specify them in your Hiera datadir:
#
#  # Example: defaults.yaml
#  ---
#  managedmac::screensharing::enable: true
#  managedmac::screensharing::users:
#      - leela
#      - bender
#  managedmac::screensharing::groups:
#      - robotmafia
#
# Then simply, create a manifest and include the class...
#
#  # Example: my_manifest.pp
#  include managedmac::screensharing
#
# If you just wish to test the functionality of this class, you could also do
# something along these lines:
#
#  class { 'managedmac::screensharing':
#    enable => true,
#    users => ['bender', 'fry']
#  }
#
# === Authors
#
# Brian Warsing <bcw@sfu.ca>
#
# === Copyright
#
# Copyright 2015 Simon Fraser University, unless otherwise noted.
#
class managedmac::screensharing (

  $enable = undef,
  $users  = [],
  $groups = ['ABCDEFAB-CDEF-ABCD-EFAB-CDEF00000050'],
  $strict = true,

) {

  unless $enable == undef {

    if ! defined_with_params(Remotemanagement['apple_remote_desktop'],
      {'ensure' => 'running' })
    {
      $service_label = 'com.apple.screensharing'
      $acl_group     = 'com.apple.access_screensharing'
      $admin_guid    = 'ABCDEFAB-CDEF-ABCD-EFAB-CDEF00000050'

      validate_bool ($enable)

      validate_array ($users)
      validate_array ($groups)

      $users_attr = $enable ? {
        true  => $users,
        false => [],
      }

      $groups_attr = $enable ? {
        true  => $groups,
        false => [$admin_guid],
      }

      macgroup { $acl_group:
        ensure       => present,
        gid          => 398,
        users        => $users_attr,
        nestedgroups => $groups_attr,
        strict       => $strict,
      }

      service { $service_label:
        ensure  => $enable,
        enable  => true,
        require => Macgroup[$acl_group],
      }

    } else {
      $msg = 'Cannot activate ScreenSharing while RemoteManagement is running.'
      notice($msg)
    }
  }

}
