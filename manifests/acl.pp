# == Definition: managedmac::acl
#
# This class abstracts the Macgroup tyep to provide management of groups
# that represent access control lists.
#
# === Parameters
#
# [*state*]
#   The activation status of the ACL.
#   Type: String
#   Accepts: enabled or disabled
#   Default: enabled
#
# [*destroy*]
#   Whether or not to destroy the group when deactivating the ACL.
#   Type: Bool
#   Default: false
#
# [*users*]
#   The list of user accounts to add to the ACL.
#   Type: Array
#   Default: empty
#
# [*groups*]
#   The list of groups to add to the ACL.
#   Type: Array
#   Default: empty
#
# Actions:
# - Install or remove the ACL
#
# Sample Usage:
# managedmac::acl {'com.apple.access_loginwindow':
#   users   => ['foo', 'bar'],
#   groups  => ['admin'],
# }
#
# === Authors
#
# Brian Warsing <bcw@sfu.ca>
#
# === Copyright
#
# Copyright 2014 Simon Fraser University, unless otherwise noted.
#
define managedmac::acl (

  $state   = 'enabled',
  $destroy = false,
  $users   = [],
  $groups  = [],

) {

  $admin_guid = 'ABCDEFAB-CDEF-ABCD-EFAB-CDEF00000050'

  $acl = {}
  $all_params = {}

  validate_string ($state)
  validate_bool   ($destroy)
  validate_array  ($users)
  validate_array  ($groups)

  if $state == 'enabled' {

    $all_params[users]        = $users
    $all_params[nestedgroups] = $groups

  } elsif $state == 'disabled' {

    if $destroy == false {

      $all_params[users]        = []
      $all_params[nestedgroups] = [$admin_guid]

    } else {

      $all_params[ensure] = absent

    }

  } else {
    fail("Parameter Error: invalid value for :state, ${state}")
  }

  $acl[$name] = $all_params
  create_resources(macgroup, $acl)

}
