# == Class: managedmac::mounts
#
# Uses Mobileconfig type to define drives to map at login time.
#
# === Parameters
#
# [*urls*]
#   A list of network mount URIs you wish to open at login. OS X Finder will
#   open these URIs in sequence. You can use afp, smb/cifs or http(s) type URLs.
#   Type: Array
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
#  managedmac::mounts::urls:
#    - 'https://some.dav.com/web/personal/%short_name%'
#    - 'smb://some.windows.com/%short_name%'
#
# Then simply, create a manifest and include the class...
#
#  # Example: my_manifest.pp
#  include managedmac::mounts
#
# If you just wish to test the functionality of this class, you could also do
# something along these lines:
#
#  # Create an URLs Array
#  $urls = ['afp://some.server.com/some/volume']
#
#  class { 'managedmac::mounts':
#    urls => $urls,
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
class managedmac::mounts ($urls = []) {

  validate_array ($urls)

  $params_are_set = empty($urls)

  # Only validate required variables if we are activating the resource
  $ensure = $params_are_set ? {
    true    => absent,
    default => present,
  }

  $compiled_options = process_mounts($urls)

  $organization = hiera('managedmac::organization', 'Simon Fraser University')

  mobileconfig { 'managedmac.mounts.alacarte':
    ensure       => $ensure,
    displayname  => 'Managed Mac: Mounts',
    description  => 'Mounts. Installed by Puppet.',
    organization => $organization,
    content      => [$compiled_options],
  }

}