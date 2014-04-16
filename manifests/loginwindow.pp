# == Class: managedmac::loginwindow
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
      $all_params[BannerText] = $banner_text
    }

    unless is_string($show_full_name) and empty($show_full_name) {
      validate_bool ($show_full_name)
      $all_params[SHOWFULLNAME] = $show_full_name
    }

    unless is_string($show_buttons) and empty($show_buttons) {
      validate_bool ($show_buttons)
      $all_params[SleepDisabled]     = $show_buttons
      $all_params[ShutdownpDisabled] = $show_buttons
      $all_params[RestartDisabled]   = $show_buttons
    }

    if empty($options) and empty($all_params) {
      fail('Missing Options: you have specified no params and the options
        Hash is empty')
    }

    # Merge the parameters into the options Hash
    # - parameters trump options
    $compiled_options = merge($options, $all_params)

  } else {
    unless $ensure == 'absent' {
      fail("Parameter Error: invalid value for :ensure, ${ensure}")
    }
  }

  $options[PayloadType] = 'com.apple.loginwindow'

  mobileconfig { 'managedmac.loginwindow.alacarte':
    ensure       => $ensure,
    displayname  => 'Managed Mac: Loginwindow',
    description  => 'Loginwindow configuration. Installed by Puppet.',
    organization => 'Simon Fraser University',
    content      => [$compiled_options],
  }

}