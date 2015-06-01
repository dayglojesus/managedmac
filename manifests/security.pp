# == Class: managedmac::security
#
# Leverages the Mobileconfig type to deploy a Security profile.
#
# All of the parameter defaults are 'undef' so including/containing the class
# is not sufficient for confguration. You must activate the params by giving
# them a value.
#
# === Parameters
#
# [*ask_for_password*]
#   --> Require a password after sleep or screensaver begins
#   Type: Boolean
#   Default: undef
#
# [*ask_for_password_delay*]
#   --> The interval in seconds before the screensaver demands a password.
#   Type: Integer
#   Default: undef
#
# [*disable_autologin*]
#   --> Prevent users from using autologin during startup.
#   Type: Boolean
#   Default: undef
#
# [*gatekeeper_enable_assessment*]
#   --> Only allow apps and packages from Mac App Store and identified
#   developers. If this value is false, Gatekeeper will allow unsigned apps and
#   packages to be installed. This equates to the 'Anywhere' UI setting. True
#   means only allow trusted apps/packages.
#   Type: Boolean
#   Default: undef
#
# [*gatekeeper_allow_identified_developers*]
#   --> Allow apps/packages from 'Mac App Store' or 'Mac App Store and
#   identified developers'. This toggles the Gatekeeper UI: 'Mac App Store' and
#   'Mac App Store and identified developers'. False is Mac App Store ONLY.
#   True is both.
#   Type: Boolean
#   Default: undef
#
# [*gatekeeper_disable_override*]
#   --> Control disables the Finder's contextual menu that allows bypass of
#   System Policy restrictions.
#   Type: Boolean
#   Default: undef
#
# [*dont_allow_lock_message_ui*]
#   --> Don't allow user to set lock message
#   Type: Boolean
#   Default: undef
#
# [*dont_allow_password_reset_ui*]
#   --> Don't allow user to change password
#   Type: Boolean
#   Default: undef
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
#  managedmac::security::ask_for_password: true
#  managedmac::security::ask_for_password_delay: 300
#  managedmac::security::disable_autologin: true
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
#    ask_for_password        => true,
#    ask_for_password_delay  => 300,
#    disable_autologin       => true,
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
class managedmac::security (

  $ask_for_password                       = undef,
  $ask_for_password_delay                 = undef,
  $disable_autologin                      = undef,
  $gatekeeper_enable_assessment           = undef,
  $gatekeeper_allow_identified_developers = undef,
  $gatekeeper_disable_override            = undef,
  $dont_allow_lock_message_ui             = undef,
  $dont_allow_password_reset_ui           = undef,

) {

  unless $ask_for_password == undef {
    validate_bool ($ask_for_password)
  }

  unless $ask_for_password_delay == undef {
    unless is_integer($ask_for_password_delay) {
      fail("ask_for_password_delay not an Integer: ${ask_for_password_delay}")
    }
  }

  unless $disable_autologin == undef {
    validate_bool ($disable_autologin)
  }

  unless $gatekeeper_enable_assessment == undef {
    validate_bool ($gatekeeper_enable_assessment)
  }

  unless $gatekeeper_allow_identified_developers == undef {
    validate_bool ($gatekeeper_allow_identified_developers)
  }

  unless $gatekeeper_enable_assessment == undef {
    validate_bool ($gatekeeper_enable_assessment)
  }

  unless $dont_allow_lock_message_ui == undef {
    validate_bool ($dont_allow_lock_message_ui)
  }

  unless $dont_allow_password_reset_ui == undef {
    validate_bool ($dont_allow_password_reset_ui)
  }

  $params = {
    'com.apple.systempolicy.managed' => {
      'DisableOverride' => $gatekeeper_disable_override,
    },
    'com.apple.systempolicy.control' => {
      'AllowIdentifiedDevelopers' => $gatekeeper_allow_identified_developers,
      'EnableAssessment'          => $gatekeeper_enable_assessment,
    },
    'com.apple.loginwindow' => {
      'ChangePasswordDisabled'                     =>
        $dont_allow_password_reset_ui,
      'com.apple.login.mcx.DisableAutoLoginClient' => $disable_autologin,
    },
    'com.apple.preference.security' => {
      'dontAllowLockMessageUI'   => $dont_allow_lock_message_ui,
      'dontAllowPasswordResetUI' => $dont_allow_password_reset_ui,
    },
    'com.apple.screensaver' => {
      'askForPassword'      => $ask_for_password,
      'askForPasswordDelay' => $ask_for_password_delay
    },
  }

  # Should return Array
  $content = process_mobileconfig_params($params)

  $mobileconfig_ensure = empty($content) ? {
    true  => 'absent',
    false => 'present',
  }

  $organization = hiera('managedmac::organization', 'Simon Fraser University')

  mobileconfig { 'managedmac.security.alacarte':
    ensure       => $mobileconfig_ensure,
    content      => $content,
    displayname  => 'Managed Mac: Security',
    description  => 'Security configuration. Installed by Puppet.',
    organization => $organization,
  }

}