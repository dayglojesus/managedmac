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
# Copyright 2014 Simon Fraser University, unless otherwise noted.
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

  $ask_for_password_delay_as_bool = $ask_for_password_delay ? {
    undef   => false,
    default => true
  }

  $enable = num2bool(
    bool2num($ask_for_password) +
    bool2num($ask_for_password_delay_as_bool) +
    bool2num($disable_autologin) +
    bool2num($gatekeeper_enable_assessment) +
    bool2num($gatekeeper_allow_identified_developers) +
    bool2num($gatekeeper_disable_override) +
    bool2num($dont_allow_lock_message_ui) +
    bool2num($dont_allow_password_reset_ui)
  )

  validate_bool ($enable)

  # Puppet Selectors cannot deal with Hashes, so populate an empty one
  # https://projects.puppetlabs.com/issues/14301

  $an_empty_hash = {}

  #######################################################################
  # Handle System Policy Managed Payload
  #######################################################################

  $systempolicy_managed_01 = $gatekeeper_disable_override ? {
    /true|false/ => hash('DisableOverride', $gatekeeper_disable_override),
    default      => $an_empty_hash,
  }
  $systempolicy_managed_payload = merge(
    {'PayloadType' => 'com.apple.systempolicy.managed'},
    $systempolicy_managed_01
  )

  #######################################################################
  # Handle System Policy Control Payload
  #######################################################################

  $systempolicy_control_01 = $gatekeeper_allow_identified_developers ? {
    /true|false/ => hash('AllowIdentifiedDevelopers', $gatekeeper_allow_identified_developers),
    default      => $an_empty_hash,
  }
  $systempolicy_control_02 = $gatekeeper_enable_assessment ? {
    /true|false/ => hash('AllowIdentifiedDevelopers', $gatekeeper_enable_assessment),
    default      => $an_empty_hash,
  }
  $systempolicy_control_payload = merge(
    {'PayloadType' => 'com.apple.systempolicy.control'},
    $systempolicy_control_01,
    $systempolicy_control_02
  )

  #######################################################################
  # Handle Loginwindow Payload
  #######################################################################

  $loginwindow_01 = $dont_allow_password_reset_ui ? {
    /true|false/ => hash('ChangePasswordDisabled', $dont_allow_password_reset_ui),
    default      => $an_empty_hash,
  }
  $loginwindow_02 = $disable_autologin ? {
    /true|false/ => hash('com.apple.login.mcx.DisableAutoLoginClient', $disable_autologin),
    default      => $an_empty_hash,
  }
  $loginwindow_payload = merge(
    {'PayloadType' => 'com.apple.loginwindow'},
    $loginwindow_01,
    $loginwindow_02
  )

  #######################################################################
  # Handle Security Preferences Payload
  #######################################################################

  $security_preference_01 = $dont_allow_lock_message_ui ? {
    /true|false/ => hash('dontAllowLockMessageUI', $dont_allow_lock_message_ui),
    default      => $an_empty_hash,
  }
  $security_preference_02 = $dont_allow_password_reset_ui ? {
    /true|false/ => hash(['dontAllowPasswordResetUI', $dont_allow_password_reset_ui]),
    default      => $an_empty_hash,
  }
  $security_preference_payload = merge(
    {'PayloadType' => 'com.apple.preference.security'},
    $security_preference_01,
    $security_preference_02
  )

  #######################################################################
  # Handle Screensaver and Sleep Security Payload
  #######################################################################

  $screensaver_option_01 = $ask_for_password ? {
    /true|false/ => hash(['askForPassword', $ask_for_password]),
    default      => $an_empty_hash,
  }
  $screensaver_option_02 = $ask_for_password_delay ? {
    /\d+/   => hash(['askForPasswordDelay', $ask_for_password_delay]),
    default => $an_empty_hash,
  }
  $screensaver_payload = merge(
    {'PayloadType' => 'com.apple.screensaver'},
    $screensaver_option_01,
    $screensaver_option_02
  )

  #######################################################################
  # Compile the content Array
  #######################################################################

  $content = [ $systempolicy_managed_payload,
    $systempolicy_control_payload,
    $loginwindow_payload,
    $screensaver_payload,
    $security_preference_payload,
  ]

  #######################################################################
  # All this for a single resource
  #######################################################################

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