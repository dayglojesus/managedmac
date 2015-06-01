# == Class: managedmac::loginwindow
#
# Controls various OS X Loginwindow options spanning multiple preference
# domains and resource types.
#
# NOTE: This is not a full implementation of the available controls. Many
# OpenDirectory related controls were removed becuase they were either no
# longer supported in OS X, cumbersome or out of scope.
#
# === Parameters
#
# [*users*]
#   A list of user names allowed to access the machine via the loginwindow.
#   This control is implemented in the com.apple.access_loginwindow ACL
#   group. By default, this group does not exist.
#   Type: Array
#
# [*groups*]
#   A list of groups (names or GUIDs) allowed to access the machine via the
#   loginwindow. This control is implemented in the
#   com.apple.access_loginwindow ACL group. By default, this group does not
#   exist.
#   Type: Array
#
# [*strict*]
#   How to handle membership in the users and nestedgroups arrays. Informs the
#   provider whether to merge the specified members into the record, or replace
#   them outright. See the Macgroup documentation for details.
#   Type: Boolean
#
# [*allow_list*]
#   A list of GUIDs corresponding to allowed users or groups.
#   Corresponds to the AllowList key.
#   Type: Array
#
# [*deny_list*]
#   A list of GUIDs corresponding to denied users or groups.
#   Corresponds to the DenyList key.
#   Type: Array
#
# [*disable_console_access*]
#   Users can access the OS X console by entering the special username:
#   '> console'. Setting this to true will disable this feature.
#   Corresponds to the DisableConsoleAccess key.
#   Type: Boolean
#
# [*enable_external_accounts*]
#   Enable the external accounts feature that allows users to store their home
#   directory and account information on a removable disk.
#   Corresponds to the EnableExternalAccounts key.
#   Type: Boolean
#
# [*hide_admin_users*]
#   Hide administrator accounts when displaying accounts at the loginwindow.
#   Corresponds to the HideAdminUsers key.
#   Type: Boolean
#
# [*hide_local_users*]
#   Hide local user accounts when displaying accounts at the loginwindow.
#   Corresponds to the HideLocalUsers key.
#   Type: Boolean
#
# [*hide_mobile_accounts*]
#   Hide mobile user accounts when displaying accounts at the loginwindow.
#   Corresponds to the HideMobileAccounts key.
#   Type: Boolean
#
# [*show_network_users*]
#   Include network user accounts when displaying accounts at the loginwindow.
#   Corresponds to the IncludeNetworkUser key.
#   Type: Boolean
#
# [*allow_local_only_users*]
#   Allow local-only account users to login.
#   Corresponds to the LocalUserLoginEnabled key.
#   Type: Boolean
#
# [*loginwindow_text*]
#   Specifies a message to post on the loginwindow.
#   Corresponds to the LoginwindowText key.
#   Type: String
#
# [*restart_disabled*]
#   Disable/Remove the Restart button from the loginwindow.
#   Corresponds to the RestartDisabled key.
#   Type: Boolean
#
# [*shutdown_disabled*]
#   Disable/Remove the Shutdown button from the loginwindow.
#   Corresponds to the ShutDownDisabled key.
#   Type: Boolean
#
# [*sleep_disabled*]
#   Disable/Remove the Sleep button from the loginwindow.
#   Corresponds to the SleepDisabled key.
#   Type: Boolean
#
# [*retries_until_hint*]
#   The number of failed login attempts a user gets until they are given a
#   password hint.
#   Corresponds to the RetriesUntilHint key.
#   Type: Integer
#
# [*show_name_and_password_fields*]
#   Use the name and password fields rather than display each account at the
#   loginwindow. Setting this to true will override many other related keys.
#   Corresponds to the SHOWFULLNAME key.
#   Type: Boolean
#
# [*show_other_button*]
#   Show the "Other" button when displaying accounts at the loginwindow.
#   Corresponds to the SHOWOTHERUSERS_MANAGED key.
#   Type: Boolean
#
# [*disable_autologin*]
#   Disable the use of the OS X autologin feature.
#   Corresponds to the com.apple.login.mcx.DisableAutoLoginClient key.
#   Type: Boolean
#
# [*disable_guest_account*]
#   Disable the the OS X Guest login feature.
#   Type: Boolean
#
# [*auto_logout_delay*]
#   Forces a logout after the machine is idle for n seconds.
#   Type: Integer
#
# [*enable_fast_user_switching*]
#   Enable or disable Fast User Switching.
#   Type: Boolean
#
# [*disable_fde_autologin*]
#   Disable autologin after FileVault EFI is unlocked.
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
#  managedmac::loginwindow::users:
#     - fry
#     - bender
#  managedmac::loginwindow::groups:
#     - robothouse
#     - 20EFB92F-4842-4218-8973-9F4738963660
#  managedmac::loginwindow::allow_list:
#     - D2C2107F-CE19-4C9F-9235-688BEB01D8C0
#     - 779A91D0-885B-4066-97FC-BEECB737E6AF
#  managedmac::loginwindow::deny_list:
#     - C3F27BC2-8F89-4D56-9525-95B5133D8F25
#     - F1A496E4-86EB-4387-A4D6-5D6FAD9201E7
#  managedmac::loginwindow::disable_console_access: true
#  managedmac::loginwindow::enable_external_accounts: false
#  managedmac::loginwindow::hide_admin_users: false
#  managedmac::loginwindow::hide_local_users: false
#  managedmac::loginwindow::hide_mobile_accounts: false
#  managedmac::loginwindow::show_network_users: false
#  managedmac::loginwindow::allow_local_only_users: true
#  managedmac::loginwindow::loginwindow_text: "Some message..."
#  managedmac::loginwindow::restart_disabled: false
#  managedmac::loginwindow::retries_until_hint: 1000000
#  managedmac::loginwindow::show_name_and_password_fields: true
#  managedmac::loginwindow::show_other_button: false
#  managedmac::loginwindow::shutdown_disabled: false
#  managedmac::loginwindow::sleep_disabled: false
#  managedmac::loginwindow::disable_autologin: true
#  managedmac::loginwindow::disable_guest_account: true
#  managedmac::loginwindow::auto_logout_delay: 3600
#  managedmac::loginwindow::enable_fast_user_switching: false
#  managedmac::loginwindow::disable_fde_autologin: true

# Then simply, create a manifest and include the class...
#
#  # Example: my_manifest.pp
#  include managedmac::loginwindow
#
# If you just wish to test the functionality of this class, you could also do
# something along these lines:
#
#  class { 'managedmac::loginwindow':
#    loginwindow_text => 'Planet Express Employees Only',
#    disable_console_access => true,
#    show_name_and_password_fields => true,
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
class managedmac::loginwindow (

  $users                         = [],
  $groups                        = [],
  $strict                        = true,
  $allow_list                    = [],
  $deny_list                     = [],
  $disable_console_access        = undef,
  $enable_external_accounts      = undef,
  $hide_admin_users              = undef,
  $hide_local_users              = undef,
  $hide_mobile_accounts          = undef,
  $show_network_users            = undef,
  $allow_local_only_users        = undef,
  $loginwindow_text              = undef,
  $restart_disabled              = undef,
  $shutdown_disabled             = undef,
  $sleep_disabled                = undef,
  $retries_until_hint            = undef,
  $show_name_and_password_fields = undef,
  $show_other_button             = undef,
  $disable_autologin             = undef,
  $disable_guest_account         = undef,
  $auto_logout_delay             = undef,
  $enable_fast_user_switching    = undef,
  $disable_fde_autologin         = undef,

) {

  validate_array ($users)
  validate_array ($groups)

  validate_array ($allow_list)
  validate_array ($deny_list)

  unless $disable_console_access == undef {
    validate_bool ($disable_console_access)
  }

  unless $enable_external_accounts == undef {
    validate_bool ($enable_external_accounts)
  }

  unless $hide_admin_users == undef {
    validate_bool ($hide_admin_users)
  }

  unless $hide_local_users == undef {
    validate_bool ($hide_local_users)
  }

  unless $hide_mobile_accounts == undef {
    validate_bool ($hide_mobile_accounts)
  }

  unless $show_network_users == undef {
    validate_bool ($show_network_users)
  }

  unless $allow_local_only_users == undef {
    validate_bool ($allow_local_only_users)
  }

  if $loginwindow_text {
    validate_string ($loginwindow_text)
  }

  unless $restart_disabled == undef {
    validate_bool ($restart_disabled)
  }

  unless $shutdown_disabled == undef {
    validate_bool ($shutdown_disabled)
  }

  unless $sleep_disabled == undef {
    validate_bool ($sleep_disabled)
  }

  unless $retries_until_hint == undef {
    unless is_integer($retries_until_hint) {
      fail("retries_until_hint not an Integer: ${retries_until_hint}")
    }
  }

  unless $show_name_and_password_fields == undef {
    validate_bool ($show_name_and_password_fields)
  }

  unless $show_other_button == undef {
    validate_bool ($show_other_button)
  }

  unless $disable_autologin == undef {
    validate_bool ($disable_autologin)
  }

  unless $disable_guest_account == undef {
    validate_bool ($disable_guest_account)
  }

  unless $auto_logout_delay == undef {
    unless is_integer($auto_logout_delay) {
      fail("retries_until_hint not an Integer: ${auto_logout_delay}")
    }
  }

  unless $enable_fast_user_switching == undef {
    validate_bool ($enable_fast_user_switching)
  }

  unless $disable_fde_autologin == undef {
    validate_bool ($disable_fde_autologin)
  }

  $params = {
    'com.apple.loginwindow' => {
      'AllowList'                                  => $allow_list,
      'DenyList'                                   => $deny_list,
      'DisableConsoleAccess'                       =>
        $disable_console_access,
      'EnableExternalAccounts'                     =>
        $enable_external_accounts,
      'HideAdminUsers'                             => $hide_admin_users,
      'HideLocalUsers'                             => $hide_local_users,
      'HideMobileAccounts'                         => $hide_mobile_accounts,
      'IncludeNetworkUser'                         => $show_network_users,
      'LocalUserLoginEnabled'                      => $allow_local_only_users,
      'LoginwindowText'                            => $loginwindow_text,
      'RestartDisabled'                            => $restart_disabled,
      'ShutDownDisabled'                           => $shutdown_disabled,
      'SleepDisabled'                              => $sleep_disabled,
      'RetriesUntilHint'                           => $retries_until_hint,
      'SHOWFULLNAME'                               =>
        $show_name_and_password_fields,
      'SHOWOTHERUSERS_MANAGED'                     => $show_other_button,
      'com.apple.login.mcx.DisableAutoLoginClient' => $disable_autologin,
      'DisableFDEAutoLogin'                        => $disable_fde_autologin,
    },
    'com.apple.MCX' => {
      'DisableGuestAccount' => $disable_guest_account,
      'EnableGuestAccount'  => $disable_guest_account ? {
        undef => undef,
        true  => false,
        false => true,
      },
    },
    '.GlobalPreferences' => {
      'com.apple.autologout.AutoLogOutDelay' => $auto_logout_delay,
      'MultipleSessionEnabled'               => $enable_fast_user_switching,
    },
  }

  # Should return Array
  $content = process_mobileconfig_params($params)

  $mobileconfig_ensure = empty($content) ? {
    true  => 'absent',
    false => 'present',
  }

  $acl_inactive = empty($users) and empty($groups)

  $acl_ensure = $acl_inactive ? {
    true  => absent,
    false => present,
  }

  macgroup { 'com.apple.access_loginwindow':
    ensure       => $acl_ensure,
    users        => $users,
    nestedgroups => $groups,
    strict       => $strict,
  }

  $organization = hiera('managedmac::organization', 'Simon Fraser University')

  mobileconfig { 'managedmac.loginwindow.alacarte':
    ensure       => $mobileconfig_ensure,
    displayname  => 'Managed Mac: Loginwindow',
    description  => 'Loginwindow configuration. Installed by Puppet.',
    organization => $organization,
    content      => $content,
  }

}
