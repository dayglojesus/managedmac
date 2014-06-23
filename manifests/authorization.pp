# == Class: managedmac::authorization
#
# Unlock select System Preferences panes by setting a bool.
#
# So far, the only panes we're controlling are: Energy Saver, Date & Time,
# and Time Machine.
#
# === Parameters
#
# There 3 parameters, all are BOOLS.
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
# === Variables
#
# Not applicable
#
# === Examples
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
#    allow_datetime => true,
#    allow_timemachine => true,
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
class managedmac::authorization (

  $allow_energysaver = false,
  $allow_datetime    = false,
  $allow_timemachine = false,

) {

  validate_bool ($allow_energysaver)
  validate_bool ($allow_datetime)
  validate_bool ($allow_timemachine)

  $sum = (bool2num($allow_energysaver) + bool2num($allow_datetime) +
    bool2num($allow_timemachine)) > 0

  $sys_prefs_group = $sum ? {
    true    => 'everyone',
    default => 'admin',
  }

  $preferences = {

    'system.preferences' => {
      group   => $sys_prefs_group,
      comment => 'Checked by the Admin framework when making changes to certain System Preferences.',
    },

    'system.preferences.energysaver' => {
      group => $allow_energysaver ? {
        true    => 'everyone',
        default => 'admin',
      },
      comment => 'Checked by the Admin framework when making changes to the Energy Saver preference pane.',
    },

    'system.preferences.datetime' => {
      group => $allow_datetime ? {
        true    => 'everyone',
        default => 'admin',
      },
      comment => 'Checked by the Admin framework when making changes to the Date & Time preference pane.',
    },

    'system.preferences.timemachine' => {
      group => $allow_timemachine ? {
        true    => 'everyone',
        default => 'admin',
      },
      comment => 'Checked by the Admin framework when making changes to the Time Machine preference pane.',
    },

  }

  $defaults = {
    allow_root        => 'true',
    auth_class        => 'user',
    auth_type         => 'right',
    authenticate_user => 'true',
    shared            => 'true',
    timeout           => '2147483647',
    tries             => '10000',
  }

  create_resources(macauthdb, $preferences, $defaults)

}