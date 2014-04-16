# == Class: managedmac::loginwindow
#
# Abstracts com.apple.loginwindow preference domain using Mobileconfig type.
#
# NOTE: Parameters trump matching keys in the options Hash. If you specify one
# of the defined parameters (ie. $banner_text) and you also set the
# corresponding key somewhere in the options Hash, the value of the parameter
# will take precedence.
#
# === Parameters
#
# There 5 parameters. An exception will be raised if you do not specify at
# least one parameter.
#
# [*ensure*]
#   Whether the resources defined in this class should be applied or not.
#   Type: String
#   Accepts: present or absent
#   Default: present
#
# [*banner_text*]
#   The banner text for the loginwindow.
#   Type: String
#   e.g. "Please login with your Username and Password..."
#
# [*show_full_name*]
#   Show username and password fields rather than the default push-button style.
#   Type: Boolean
#   Default: undefined
#
# [*show_buttons*]
#   Whether or not the Restart, Shutdown, and Sleep buttons shoudl be displayed.
#   Type: Boolean
#   Default: undefined
#
# [*options*]
#   Raw com.apple.loginwindow pref keys. (See examples below)
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
# managedmac::loginwindow::show_buttons: false
# managedmac::loginwindow::banner_text: "And now for something completely different..."
# managedmac::loginwindow::options:
#   AdminHostInfo: HostName
#   AdminMayDisableMCX: true
#   AlwaysShowWorkgroupDialog: false
#   CombineUserWorkgroups: true
#   DisableConsoleAccess: true
#   EnableExternalAccounts: false
#   FlattenUserWorkgroups: false
#   HideAdminUsers: true
#   HideLocalUsers: true
#   HideMobileAccounts: true
#   IncludeNetworkUser: false
#   LocalUserLoginEnabled: true
#   LocalUsersHaveWorkgroups: false
#   LoginwindowText: "Enter your SFU Computing ID to Login"
#   RestartDisabled: false
#   RetriesUntilHint: 0
#   SHOWFULLNAME: true
#   SHOWOTHERUSERS_MANAGED: false
#   ShutDownDisabled: false
#   SleepDisabled: false
#   UseComputerNameForComputerRecordName: false
#   'com.apple.login.mcx.DisableAutoLoginClient': true
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
#   'BannerText' => 'A loginwindow message in the options hash.',
#  }
#
#  class { 'managedmac::activedirectory':
#    banner_text => 'We are overriding the silly loginwindow message!',
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

class managedmac::loginwindow (

  $ensure          = present,
  $banner_text     = '',
  $show_full_name  = '',
  $show_buttons    = '',
  $options         = {}

) {

  $all_params = {}

  # Only validate required variables if we are activating the resource
  if $ensure == present {

    validate_hash ($options)

    validate_string ($banner_text)
    unless empty($banner_text) {
      $all_params[LoginwindowText] = $banner_text
    }

    unless is_string($show_full_name) and empty($show_full_name) {
      validate_bool ($show_full_name)
      $all_params[SHOWFULLNAME] = $show_full_name
    }

    unless is_string($show_buttons) and empty($show_buttons) {
      validate_bool ($show_buttons)
      $all_params[SleepDisabled]     = $show_buttons
      $all_params[ShutDownDisabled]  = $show_buttons
      $all_params[RestartDisabled]   = $show_buttons
    }

    if empty($options) and empty($all_params) {
      fail('Missing Options: you have specified no params and the options
        Hash is empty')
    }

    # Merge the parameters into the options Hash
    # - parameters trump options
    $compiled_options = merge($options, $all_params)
    $compiled_options[PayloadType] = 'com.apple.loginwindow'

  } else {
    unless $ensure == 'absent' {
      fail("Parameter Error: invalid value for :ensure, ${ensure}")
    }
  }

  mobileconfig { 'managedmac.loginwindow.alacarte':
    ensure       => $ensure,
    displayname  => 'Managed Mac: Loginwindow',
    description  => 'Loginwindow configuration. Installed by Puppet.',
    organization => 'Simon Fraser University',
    content      => [$compiled_options],
  }

}