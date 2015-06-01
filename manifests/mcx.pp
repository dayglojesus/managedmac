# == Class: managedmac::mcx
#
# Leverages the Puppet MCX type to deploy some options not available in
# Configuration Profiles. If any parameters for this class are defined...
#
#   - Creates a new computer record in the DSLocal node, "mcx_puppet"
#   - Applies the specified settings to the new computer record
#
#  By itself this class will force a refresh of MCX policy on each Puppet run.
#
# === Parameters
#
# [*bluetooth*]
#   Enable or disable Bluetooth power and administrative controls.
#   Accepts values: on/off, true/false, enable/disable. Values are enforced, so
#   if you set it to on/true/enable, users will not be able to turn off the
#   service.
#   Type: String or Boolean
#
# [*wifi*]
#   Enable or disable Airport power and administrative controls.
#   Accepts values: on/off, true/false, enable/disable. Values are enforced, so
#   if you set it to on/true/enable, users will not be able to turn off the
#   service.
#   Type: String or Boolean
#
# [*logintiems*]
#   Accepts a list of items you want launched at login time. Paths are NOT
#   validated.
#   Type: Array
#
# [*suppress_icloud_setup*]
#   Suppress iCloud Setup dialogue for new users.
#   Type: Boolean
#
# [*hidden_preference_panes*]
#   A list of hidden System Preferences panes. Prefernce pane names MUST be
#   specified by their reverse domain ID. (Eg. com.apple.preferences.icloud)
#   Type: Array
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
#  managedmac::mcx::bluetooth: on
#  managedmac::mcx::wifi: off
#  managedmac::mcx::loginitems:
#     - /Applications/Chess.app
#  managedmac::mcx::suppress_icloud_setup: true
#  managedmac::mcx::hidden_preference_panes:
#     - com.apple.preferences.icloud
#
# Then simply, create a manifest and include the class...
#
#  # Example: my_manifest.pp
#  include managedmac::mcx
#
# If you just wish to test the functionality of this class, you could also do
# something along these lines:
#
# class { 'managedmac::mcx':
#   bluetooth   => on,
#   wifi        => off,
#   loginitems  => ['/path/to/some/file'],
# }
#
# === Authors
#
# Brian Warsing <bcw@sfu.ca>
#
# === Copyright
#
# Copyright 2015 Simon Fraser University, unless otherwise noted.
#
class managedmac::mcx (

  $bluetooth                  = undef,
  $wifi                       = undef,
  $loginitems                 = [],
  $suppress_icloud_setup      = undef,
  $hidden_preference_panes    = [],

){

  $bluetooth_state = $bluetooth ? {
    /on|true|enable/    => false,
    /off|false|disable/ => true,
    undef               => undef,
    default             => "Parameter Error: invalid value for :bluetooth, \
${bluetooth}",
  }

  $wifi_state = $wifi ? {
    /on|true|enable/    => false,
    /off|false|disable/ => true,
    undef               => undef,
    default             => "Parameter Error: invalid value for :wifi, ${wifi}",
  }

  unless $bluetooth_state == undef {
    validate_bool ($bluetooth_state)
  }

  unless $wifi_state == undef {
    validate_bool ($wifi_state)
  }

  validate_array ($loginitems)

  unless $suppress_icloud_setup == undef {
    validate_bool ($suppress_icloud_setup)
  }

  validate_array ($hidden_preference_panes)

  $content = process_mcx_options($bluetooth_state,
    $wifi_state, $loginitems, $suppress_icloud_setup, $hidden_preference_panes)

  $ensure = empty($content) ? {
    true    => absent,
    default => present,
  }

  $organization = hiera('managedmac::organization', 'Simon Fraser University')

  mobileconfig { 'managedmac.mcx.alacarte':
    ensure            => $ensure,
    content           => $content,
    description       => 'Custom MCX Settings',
    displayname       => 'Managed Mac: Custom MCX',
    organization      => $organization,
    removaldisallowed => false,
  }

}
