# == Class: managedmac::loginwindow
class managedmac::loginwindow ($ensure = present, $options = {}) {

  # Only validate required variables if we are activating the resource
  if $ensure == present {

    validate_hash ($options)
    if empty($options) {
      fail('Missing Options: the options Hash is empty')
    }

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
    content      => [$options],
  }

}