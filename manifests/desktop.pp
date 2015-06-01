# == Class: managedmac::desktop
#
# Leverages the Mobileconfig type to deploy a Desktop Picture profile.
#
# All of the parameter defaults are 'undef' so including/containing the class
# is not sufficient for confguration. You must activate the params by giving
# them a value.
#
# Note: Currently there is a bug with this profile setting that does
# not allow users to change the desktop picture regardless of the
# 'locked' setting.
#
# === Parameters
#
# [*override_picture_path*]
#   Set the path of the default desktop picture on OS X.
#   Type: String
#   Default: undef
#
# [*locked*]
#   This locks the value of the desktop picture so that users can
#   select their own picture or not (read Note above).
#   Type: Boolean
#   Default: undef
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
#  # Example: defaults.yaml
#  ---
#  managedmac::desktop::override_picture_path:
#    "/Library/Desktop Pictures/Abstract.jpg"
#  managedmac::desktop::locked: true
#
# Then simply, create a manifest and include the class...
#
#  # Example: my_manifest.pp
#  include managedmac::desktop
#
# If you just wish to test the functionality of this class, you could also do
# something along these lines:
#
#  class { 'managedmac::desktop':
#    override_picture_path  => '/Library/Desktop Pictures/Abstract.jpg',
#    locked                 => true,
#  }
#
# === Authors
#
# Clayton Burlison <clburlison@gmail.com>
# Brian Warsing <bcw@sfu.ca>
#
# === Copyright
#
# Copyright 2015 Simon Fraser University, unless otherwise noted.
#
class managedmac::desktop (

  $override_picture_path  = undef,
  $locked                 = undef,

) {

  unless $override_picture_path == undef {
    validate_absolute_path ($override_picture_path)
  }

  unless $locked == undef {
    validate_bool ($locked)
  }

  $params = {
    'com.apple.desktop' => {
      'override-picture-path' => $override_picture_path,
      'locked'                => $locked,
    },
  }

  # Should return Array
  $content = process_mobileconfig_params($params)

  $mobileconfig_ensure = empty($content) ? {
    true  => 'absent',
    false => 'present',
  }

  $organization = hiera('managedmac::organization', 'Simon Fraser University')

  mobileconfig { 'managedmac.desktop.alacarte':
    ensure       => $mobileconfig_ensure,
    content      => $content,
    displayname  => 'Managed Mac: Desktop Picture',
    description  => 'Desktop Picture configuration. Installed by Puppet.',
    organization => $organization,
  }

}
