# == Class: managedmac::softwareupdate
class managedmac::softwareupdate ($ensure = present, $options = {}) {

  # Only validate required variables if we are activating the resource
  if $ensure == present {

    validate_hash ($options)

    # CatalogURL
    validate_string ($options[CatalogURL])
    if empty($options[CatalogURL]) {
      fail('Missing Option: CatalogURL')
    }

  } else {
    unless $ensure == 'absent' {
      fail("Parameter Error: invalid value for :ensure, ${ensure}")
    }
  }

  $options[PayloadType] = 'com.apple.SoftwareUpdate'

  mobileconfig { 'managedmac.softwareupdate.alacarte':
    ensure       => $ensure,
    displayname  => 'Managed Mac: Software Update',
    description  => 'Software Update configuration. Installed by Puppet.',
    organization => 'Simon Fraser University',
    content      => [$options],
  }

}