# == Class: managedmac::authorization
#
# Controls various system authorization keys, granting users access to system
# resources otherwise only accessible by administrators.
#
# === Parameters
#
# [*allow_energysaver*]
#   Allow 'everyone' access to the Energy Saver settings pane, true or false.
#   Default: false
#   Type: Bool
#
# [*allow_datetime*]
#   Allow 'everyone' access to the Date & Time settings pane, true or false.
#   Default: false
#   Type: Bool
#
# [*allow_timemachine*]
#   Allow 'everyone' access to the Time Machine settings pane, true or false.
#   Default: false
#   Type: Bool
#
# [*allow_printers*]
#   Allow 'everyone' access to the Printers settings pane, true or false.
#   Default: false
#   Type: Bool
#
# [*allow_dvd_setregion_initial*]
#   Allow 'everyone' to set the inital DVD region code, true or false.
#   Default: false
#   Type: Bool
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
# # Example: defaults.yaml
# ---
# managedmac::authorization::allow_energysaver true
# managedmac::authorization::allow_datetime true
# managedmac::authorization::allow_timemachine true
#
# Then simply, create a manifest and include the class...
#
#  # Example: my_manifest.pp
#  include managedmac::authorization
#
# If you just wish to test the functionality of this class, you could also do
# something along these lines:
#
#  class { 'managedmac::authorization':
#    allow_energysaver => true,
#    allow_datetime    => true,
#    allow_timemachine => true,
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
class managedmac::authorization (

  $allow_energysaver            = false,
  $allow_datetime               = false,
  $allow_timemachine            = false,
  $allow_printers               = false,
  $allow_dvd_setregion_initial  = false,

) {

  # System Preference Panes
  validate_bool ($allow_energysaver)
  validate_bool ($allow_datetime)
  validate_bool ($allow_timemachine)
  validate_bool ($allow_printers)

  # Other options
  validate_bool ($allow_dvd_setregion_initial)

  # Getting System Preference panes unlocked for non-admins requires us to
  # first change the parent right 'system.preferences'. To know whether or not
  # this needs to happen, we convert all the System Prefs related bool values
  # into Integers, add them up, and if the $sum is greater than zero, the
  # 'system.preferences' right is changed to 'everyone' to match the others.
  #
  # If you are adding new controls fro System Preferences panes, be sure and
  # include the new bool value in this calculation.
  #
  $sum = (bool2num($allow_energysaver) + bool2num($allow_datetime) +
    bool2num($allow_timemachine)) + bool2num($allow_printers) > 0

  $sys_prefs_group = $sum ? {
    true    => 'everyone',
    default => 'admin',
  }

  $preferences = {

    'system.preferences' => {
      group   => $sys_prefs_group,
      comment => "Checked by the Admin framework when making changes to \
certain System Preferences.",
    },

    'system.preferences.energysaver' => {
      group => $allow_energysaver ? {
        true    => 'everyone',
        default => 'admin',
      },
      comment => "Checked by the Admin framework when making changes to the \
Energy Saver preference pane.",
    },

    'system.preferences.datetime' => {
      group => $allow_datetime ? {
        true    => 'everyone',
        default => 'admin',
      },
      shared  => false,
      comment => "Checked by the Admin framework when making changes to the \
Date & Time preference pane.",
    },

    'system.preferences.timemachine' => {
      group => $allow_timemachine ? {
        true    => 'everyone',
        default => 'admin',
      },
      comment => "Checked by the Admin framework when making changes to the \
Time Machine preference pane.",
    },

    'system.preferences.printing' => {
      group => $allow_printers ? {
        true    => 'everyone',
        default => 'admin',
      },
      comment => "Checked by the Admin framework when making changes to the \
Printing preference pane.",
    },

    'system.device.dvd.setregion.initial' => {
      allow_root => false,
      group      => $allow_dvd_setregion_initial ? {
        true    => 'everyone',
        default => 'admin',
      },
      comment => "Used by the DVD player to set the region code the first \
time.  Note that changing the region code after it has been set requires a \
different right (system.device.dvd.setregion.change).",
    },

  }

  $defaults = {
    allow_root        => true,
    auth_class        => 'user',
    auth_type         => 'right',
    authenticate_user => true,
    session_owner     => false,
    shared            => true,
    timeout           => '2147483647',
    tries             => '10000',
  }

  create_resources(macauthdb, $preferences, $defaults)

}
