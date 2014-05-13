# == Class: managedmac::energysaver
#
# Leverages the Mobileconfig type and provider to configure Energy Saver
# settings for Desktops and Laptops.
#
# This class is extremely primitive. It is little more than a wrapper
# for Mobileconfig. To get it to work correctly, you must pass it properly
# formatted data. In other words, you need to know what you are doing.
#
# Read the examples below!
#
# It's not difficult to do, but if you pass it garbage, it may not complain. We
# do SOME validation of the data, but we cannot validate optional values.
#
# These shortcomings have to do with the fact that the params for Energy Saver
# settings are have a fairly complicated structure and that Apple actually
# abstracts these settings in a profile using the com.apple.MCX preference
# domain. They are not set using a proper profile/mobileconfig in the strictest
# sense. You could just as easily be using plain MCX.
#
# Still, abstracting it into a Puppet class allows you to use Hiera to specify
# the settings. Fun!
#
# === Parameters
#
# This class takes a two parameters:
# [*ensure*]
#   Whether to apply the resource or remove it. Valid values: present or
#   absent. Pass a Symbol or a String.
#   Default: 'present'
#
# [*options*]
#   Within the options Hash, you may specify one or more keys:
#     desktop  (String): the settings for Desktop machines
#     portable (String): the settings for Portable machines
#
#   Each of these Hash keys, has it's own acceptable data structures. See the
#   documentation below for a more complete example.
#
# === Variables
#
# [*productname*]
#   Built-in Facter fact: the common name for the machine model (ie. iMac12,2)
#
# === Examples
#
# This class was designed to be used with Hiera. As such, the best way to pass
# options is to specify them in your Hiera datadir:
#
#  # Example: defaults.yaml
#  ---
# managedmac::energysaver::options:
#   desktop:
#     ACPower:
#       'Automatic Restart On Power Loss': true
#       'Disk Sleep Timer-boolean': true
#       'Display Sleep Timer': 15
#       'Sleep On Power Button': false
#       'Wake On LAN': true
#       'System Sleep Timer': 30
#     Schedule:
#       RepeatingPowerOff:
#         eventtype: sleep
#         time: 1410
#         weekdays: 127
#       RepeatingPowerOn:
#         eventtype: wakepoweron
#         time: 480
#         weekdays: 127
#   laptop:
#     ACPower:
#       'Automatic Restart On Power Loss': true
#       'Disk Sleep Timer-boolean': true
#       'Display Sleep Timer': 15
#       'Wake On LAN': true
#       'System Sleep Timer': 30
#     BatteryPower:
#       'Automatic Restart On Power Loss': false
#       'Disk Sleep Timer-boolean': true
#       'Display Sleep Timer': 5
#       'System Sleep Timer': 10
#       'Wake On LAN': true
#
# Then simply, create a manifest and include the class...
#
#  # Example: my_manifest.pp
#  include managedmac::activedirectory
#
# If you just wish to test the functionality of this class, you could also do
# something along these lines:
#
#  # Create an options Hash
#  $options = {"desktop"=>
#     {"ACPower"=>
#       {"Automatic Restart On Power Loss"=>true,
#        "Disk Sleep Timer-boolean"=>true,
#        "Display Sleep Timer"=>15,
#        "Sleep On Power Button"=>false,
#        "Wake On LAN"=>true,
#        "System Sleep Timer"=>30},
#      "Schedule"=>
#       {"RepeatingPowerOff"=>
#         {"eventtype"=>"sleep", "time"=>1410, "weekdays"=>127},
#        "RepeatingPowerOn"=>
#         {"eventtype"=>"wakepoweron", "time"=>480, "weekdays"=>127}}},
#    "laptop"=>
#     {"ACPower"=>
#       {"Automatic Restart On Power Loss"=>true,
#        "Disk Sleep Timer-boolean"=>true,
#        "Display Sleep Timer"=>15,
#        "Wake On LAN"=>true,
#        "System Sleep Timer"=>30},
#      "BatteryPower"=>
#       {"Automatic Restart On Power Loss"=>false,
#        "Disk Sleep Timer-boolean"=>true,
#        "Display Sleep Timer"=>5,
#        "System Sleep Timer"=>10,
#        "Wake On LAN"=>true}}}
#
#  class { 'managedmac::energysaver':
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
class managedmac::energysaver ($ensure = present, $options = {}) {

  $machine_type = $::productname ? {
    /MacBook/ => 'portable',
    default   => 'desktop',
  }

  $compiled_options = {}

  # Only validate required variables if we are activating the resource
  if $ensure == present {

    validate_hash ($options)

    $mcx_prefs_domain          = 'com.apple.EnergySaver'
    $desktop_schedule_key      = "${mcx_prefs_domain}.${machine_type}.Schedule"
    $ac_power_key              = "${mcx_prefs_domain}.${machine_type}.ACPower"
    $batt_power_key            = "${mcx_prefs_domain}.${machine_type}.BatteryPower"
    $desktop_ac_profile_num    = "${mcx_prefs_domain}.${machine_type}.ACPower-ProfileNumber"
    $portable_ac_profile_num   = "${mcx_prefs_domain}.${machine_type}.ACPower-ProfileNumber"
    $portable_batt_profile_num = "${mcx_prefs_domain}.${machine_type}.BatteryPower-ProfileNumber"
    $profile_number            = -1

    case $machine_type {

      # PORTABLE
      'portable': {

        validate_hash ($options[portable])

        unless empty($options[portable][ACPower]) {
          validate_hash ($options[portable][ACPower])
          $compiled_options[$ac_power_key] = $options[portable][ACPower]
          $compiled_options[$portable_ac_profile_num] = $profile_number
        }

        unless empty($options[portable][BatteryPower]) {
          validate_hash ($options[portable][BatteryPower])
          $compiled_options[$batt_power_key] = $options[portable][BatteryPower]
          $compiled_options[$portable_batt_profile_num] = $profile_number
        }

      }

      # DESKTOP
      'desktop':    {
        validate_hash ($options[desktop])

        unless empty($options[desktop][ACPower]) {
          validate_hash ($options[desktop][ACPower])
          $compiled_options[$ac_power_key] = $options[desktop][ACPower]
        }

        unless empty($options[desktop][Schedule]) {
          validate_hash ($options[desktop][Schedule])
          $compiled_options[$desktop_schedule_key] = $options[desktop][Schedule]
        }

      }

      # OTHER
      default:      {
        fail("Unknown machine_type: ${machine_type}")
      }

    }

  } else {
    unless $ensure == 'absent' {
      fail("Parameter Error: invalid value for :ensure, ${ensure}")
    }
  }

  $compiled_options[PayloadType] = 'com.apple.MCX'

  mobileconfig { 'managedmac.energysaver.alacarte':
    ensure       => $ensure,
    displayname  => 'Managed Mac: Energy Saver',
    description  => 'Energy Saver configuration. Installed by Puppet.',
    organization => 'Simon Fraser University',
    content      => [$compiled_options],
  }

}