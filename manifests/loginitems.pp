# == Class: managedmac::softwareupdate
#
# Uses Mobileconfig type to define Login Items in a profile.
#
# === Parameters
#
# There are 2 parameters.
#
# [*filesandfolders*]
#   A list of absolute paths to files, folder or Apps to automatically open at
#   login time. Profile variables liek %short_name% do not appear to work in
#   this context.
#   Type: Array
#   Default: empty
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
#  managedmac::loginitems::filesandfolders:
#    - /Applications/Chess.app
#    - /Users/Shared
#  managedmac::loginitems::urls:
#    - 'https://some.dav.com/web/personal/%short_name%'
#    - 'smb://some.windows.com/%short_name%'
#
# Then simply, create a manifest and include the class...
#
#  # Example: my_manifest.pp
#  include managedmac::loginitems
#
# If you just wish to test the functionality of this class, you could also do
# something along these lines:
#
#  # Create an URLs Array
#  $urls = ['afp://some.server.com/some/volume']
#
#  class { 'managedmac::loginitems':
#    urls => $urls,
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
class managedmac::loginitems (

  $filesandfolders = [],
  $urls            = [],

) {

  validate_array ($filesandfolders)
  validate_array ($urls)

  $params_are_set = empty($filesandfolders) and empty($urls)

  # Only validate required variables if we are activating the resource
  $ensure = $params_are_set ? {
    true    => absent,
    default => present,
  }

  $compiled_options = process_loginitems($filesandfolders, $urls)

  mobileconfig { 'managedmac.loginitems.alacarte':
    ensure       => $ensure,
    displayname  => 'Managed Mac: Login Items',
    description  => 'Login Items. Installed by Puppet.',
    organization => 'Simon Fraser University',
    content      => [$compiled_options],
  }

}