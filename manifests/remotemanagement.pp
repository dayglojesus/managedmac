# == Class: managedmac::remotemanagement
#
# Leverages the Remotemanagement type to manage and configure the Apple Remote
# Desktop service.
#
# === Parameters
#
# [*enable*]
#   Whether to enable the service or not.
#   Type: Boolean
#
# [*allow_all_users*]
#   Whether to enable access for ALL local users or not.
#   Type: Boolean
#
# [*all_users_privs*]
#   The privileges granted to connected users when the allow_all_users param
#   is true. Privileges are are represented using a signed integer stored as a
#   string. Yes, confusing. Use this Bit map chart to figure it out:
#
#    64 Bit Hex Int Bit Decimal Checkbox Item
#    ================================================================
#    FFFFFFFFC0000000 0 -1073741824 enabled but nothing set
#    FFFFFFFFC0000001 1 -1073741823 send text msgs
#    FFFFFFFFC0000002 2 -1073741822 control and observe, show when observing
#    FFFFFFFFC0000004 3 -1073741820 copy items
#    FFFFFFFFC0000008 4 -1073741816 delete and replace items
#    FFFFFFFFC0000010 5 -1073741808 generate reports
#    FFFFFFFFC0000020 6 -1073741792 open and quit apps
#    FFFFFFFFC0000040 7 -1073741760 change settings
#    FFFFFFFFC0000080 8 -1073741696 restart and shutdown
#
#    FFFFFFFF80000002 -2147483646 control and observe don't show when observing
#    FFFFFFFFC00000FF -1073741569 all enabled
#    FFFFFFFFC00000FF -2147483648 all disabled
#
#   Type: String
#
# [*enable_menu_extra*]
#   Whether or not to activate the ARD menu extra.
#   Type: Boolean
#
# [*enable_dir_logins*]
#   Whether or not to enable the Open Directory group ACLs.
#   Type: Boolean
#
# [*allowed_dir_groups*]
#   The list of directory groups to use as ARD ACLs.
#   Type: Array
#
# [*enable_legacy_vnc*]
#   Whether or not to allow legacy VNC connections.
#   Type: Boolean
#
# [*vnc_password*]
#   The VNC plain text password for connecting. I highly recommend not
#   using this.
#   Type: String
#
# [*allow_vnc_requests*]
#   Whether or not to allow_webm_requests incoming VNC requests.
#   Type: Boolean
#
# [*allow_webm_requests*]
#   Whether or not to allow_webm_requests incoming WBEM requests.
#   Type: Boolean
#
# [*users*]
#   A Hash mapping user names to respective ARD privs. Keys are user names
#   as String, values are privs as String.
#   Example:
#   {'fred' => -1073741569, 'daphne' => -2147483646, 'velma' => -1073741822 },
#   Type: Hash
#
# [*strict*]
#   Controls the exclusivity of the user list. When true, only the listed
#   users will be allowed access to ARD. Other users with existing rights will
#   have their privs revoked.
#   Type: Boolean
#
# === Variables
#
# Not applicable
#
# === Examples
#
# This class was designed to be used with Hiera. As such, the best way to pass
# options is to specify them in your Hiera datadir:
#
#  # Example: defaults.yaml
#  ---
#  managedmac::remotemanagement::enable: true
#  managedmac::remotemanagement::users:
#    user_a: -1073741569
#    user_b: -1073741569
#  managedmac::remotemanagement::enable_dir_logins: true
#  managedmac::remotemanagement::allowed_dir_groups:
#    - com.apple.local.ard_admin
#    - com.apple.local.ard_interact
#    - com.apple.local.ard_manage
#    - com.apple.local.ard_reports
#
# Then simply, create a manifest and include the class...
#
#  # Example: my_manifest.pp
#  include managedmac::remotemanagement
#
# If you just wish to test the functionality of this class, you could also do
# something along these lines:
#
#  class { 'managedmac::remotemanagement':
#    enable           => true,
#    allow_all_users  => false,
#    users            => {'fred' => -1073741569,
#       'daphne' => -2147483646, 'velma' => -1073741822 },
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
class managedmac::remotemanagement (

  $enable               = undef,
  $allow_all_users      = false,
  $all_users_privs      = '-2147483648',
  $enable_menu_extra    = true,
  $enable_dir_logins    = false,
  $allowed_dir_groups   = [],
  $enable_legacy_vnc    = false,
  $vnc_password         = undef,
  $allow_vnc_requests   = false,
  $allow_webm_requests  = false,
  $users                = {},
  $strict               = true,

){

  unless $enable == undef {

    validate_bool ($enable)

    validate_bool   ($allow_all_users)
    validate_string ($all_users_privs)
    validate_bool   ($enable_menu_extra)
    validate_bool   ($enable_dir_logins)
    validate_array  ($allowed_dir_groups)
    validate_bool   ($enable_legacy_vnc)
    validate_string ($vnc_password)
    validate_bool   ($allow_vnc_requests)
    validate_bool   ($allow_webm_requests)
    validate_hash   ($users)
    validate_bool   ($strict)

    $ensure = $enable ? {
      true     => running,
      default  => stopped,
    }

    remotemanagement { 'apple_remote_desktop':
      ensure               => $ensure,
      allow_all_users      => $allow_all_users,
      all_users_privs      => $all_users_privs,
      enable_menu_extra    => $enable_menu_extra,
      enable_dir_logins    => $enable_dir_logins,
      allowed_dir_groups   => $allowed_dir_groups,
      enable_legacy_vnc    => $enable_legacy_vnc,
      vnc_password         => $vnc_password,
      allow_vnc_requests   => $allow_vnc_requests,
      allow_wbem_requests  => $allow_webm_requests,
      users                => $users,
      strict               => $strict,
    }

  }

}
