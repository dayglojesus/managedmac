# == Class: managedmac::security
#
# Leverages the Mobileconfig type to deploy a Security profile.
#
# === Parameters
#
# [*enable*]
#   --> Enable this class and install the Security profile.
#   Type: Boolean
#   Default: false
#
# [*ask_for_password*]
#   --> Require a password after sleep or screensaver begins
#   Type: Boolean
#   Default: false
#
# [*ask_for_password_delay*]
#   --> The interval in seconds before the screensaver demands a password.
#   Type: Integer
#   Default: 0
#
# [*disable_autologin*]
#   --> Prevent users from using autologin during startup.
#   Type: Boolean
#   Default: false
#
# [*gatekeeper_enable_assessment*]
#   --> Only allow apps and packages from Mac App Store and identified
#   developers. If this value is false, Gatekeeper will allow unsigned apps and
#   packages to be installed. This equates to the 'Anywhere' UI setting. True
#   means only allow trusted apps/packages.
#   Type: Boolean
#   Default: true
#
# [*gatekeeper_allow_identified_developers*]
#   --> Allow apps/packages from 'Mac App Store' or 'Mac App Store and
#   identified developers'. This toggles the Gatekeeper UI: 'Mac App Store' and
#   'Mac App Store and identified developers'. False is Mac App Store ONLY.
#   True is both.
#   Type: Boolean
#   Default: true
#
# [*gatekeeper_disable_override*]
#   --> Control disables the Finder's contextual menu that allows bypass of
#   System Policy restrictions.
#   Type: Boolean
#   Default: false
#
# [*dont_allow_lock_message_ui*]
#   --> Don't allow user to set lock message
#   Type: Boolean
#   Default: false
#
# [*dont_allow_password_reset_ui*]
#   --> Don't allow user to change password
#   Type: Boolean
#   Default: false
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
#  managedmac::security::enable: true
#  managedmac::security::ask_for_password: true
#
# Then simply, create a manifest and include the class...
#
#  # Example: my_manifest.pp
#  include managedmac::security
#
# If you just wish to test the functionality of this class, you could also do
# something along these lines:
#
#  class { 'managedmac::security':
#    enable            => true,
#    ask_for_password  => true,
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
class managedmac::security (

  $enable                                 = false,
  $ask_for_password                       = false,
  $ask_for_password_delay                 = 0,
  $disable_autologin                      = false,
  $gatekeeper_enable_assessment           = true,
  $gatekeeper_allow_identified_developers = true,
  $gatekeeper_disable_override            = false,
  $dont_allow_lock_message_ui             = false,
  $dont_allow_password_reset_ui           = false,

) {

  validate_bool ($enable)
  validate_bool ($ask_for_password)
  validate_bool ($disable_autologin)
  validate_bool ($gatekeeper_enable_assessment)
  validate_bool ($gatekeeper_allow_identified_developers)
  validate_bool ($gatekeeper_enable_assessment)
  validate_bool ($dont_allow_lock_message_ui)
  validate_bool ($dont_allow_password_reset_ui)

  $systempolicy_managed_payload = {
    'PayloadType'     => 'com.apple.systempolicy.managed',
    'DisableOverride' => $gatekeeper_disable_override,
  }

  $systempolicy_control_payload = {
    'PayloadType'               => 'com.apple.systempolicy.control',
    'AllowIdentifiedDevelopers' => $gatekeeper_allow_identified_developers,
    'EnableAssessment'          => $gatekeeper_enable_assessment,
  }

  $preference_payload = {
    'PayloadType'               => 'com.apple.preference.security',
    'dontAllowLockMessageUI'    => $dont_allow_lock_message_ui,
    'dontAllowPasswordResetUI'  => $dont_allow_password_reset_ui,
  }

  $loginwindow_payload = {
    'PayloadType'                                => 'com.apple.loginwindow',
    'ChangePasswordDisabled'                     => $dont_allow_password_reset_ui,
    'com.apple.login.mcx.DisableAutoLoginClient' => $disable_autologin,
  }

  $screensaver_payload = {
    'PayloadType'         => 'com.apple.screensaver',
    'askForPassword'      => $ask_for_password,
    'askForPasswordDelay' => $ask_for_password_delay,
  }

  $content = [ $systempolicy_managed_payload,
    $systempolicy_control_payload,
    $preference_payload,
    $loginwindow_payload,
    $screensaver_payload,
  ]

  mobileconfig { 'managedmac.security.alacarte':
    ensure => $enable ? {
      true     => 'present',
      default  => 'absent',
    },
    content      => $content,
    displayname  => 'Managed Mac: Security',
    description  => 'Security configuration. Installed by Puppet.',
    organization => 'Simon Fraser University',
  }

}