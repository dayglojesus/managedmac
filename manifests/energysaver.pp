# == Class: managedmac::energysaver
class managedmac::energysaver ($ensure = present, $options = {}) {

  $machine_type = $::productname ? {
    /MacBook/ => 'portable',
    default   => 'desktop',
  }

  # Only validate required variables if we are activating the resource
  if $ensure == present {

    validate_hash ($options)

    $compiled_options          = {}
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
          validate_hash ($options[portable][ACPower])
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

  $options[PayloadType] = 'com.apple.MCX'

  mobileconfig { 'managedmac.energysaver.alacarte':
    ensure       => $ensure,
    displayname  => 'Managed Mac: Energy Saver',
    description  => 'Energy Saver configuration. Installed by Puppet.',
    organization => 'Simon Fraser University',
    content      => [$compiled_options],
  }

}