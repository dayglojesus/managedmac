# == Class: managedmac::softwareupdate
class managedmac::softwareupdate (

  $ensure       = present,
  $catalog_url  = '',
  $options      = {}

) {

  $all_params = {}

  # Only validate required variables if we are activating the resource
  if $ensure == present {

    validate_hash ($options)

    unless empty($catalog_url) {
      validate_re ($catalog_url, '\Ahttp:\/\/(\w+\.)+\w+\/')
      $all_params[CatalogURL] = $catalog_url
    }

    if empty($options) and empty($all_params) {
      fail('Missing Options: you have specified no params and the options
        Hash is empty')
    }

    # Merge the parameters into the options Hash
    # - parameters trump options
    $compiled_options = merge($options, $all_params)
    $compiled_options[PayloadType] = 'com.apple.SoftwareUpdate'

  } else {
    unless $ensure == 'absent' {
      fail("Parameter Error: invalid value for :ensure, ${ensure}")
    }
  }

  mobileconfig { 'managedmac.softwareupdate.alacarte':
    ensure       => $ensure,
    displayname  => 'Managed Mac: Software Update',
    description  => 'Software Update configuration. Installed by Puppet.',
    organization => 'Simon Fraser University',
    content      => [$compiled_options],
  }

}