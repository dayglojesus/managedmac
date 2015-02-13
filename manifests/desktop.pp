# == Class: managedmac::desktoppicture
#
# Leverages the Mobileconfig type to deploy a Desktop Picture profile.
#
# All of the parameter defaults are 'undef' so including/containing the class
# is not sufficient for confguration. You must activate the params by giving
# them a value.
#
# Note: Currently there is a bug with this profile setting that does
# not allow users to change the desktop picture regardless of the
# 'desktop_pic_locked' setting.
#
# === Parameters
#
# [*desktop_pic_path*]
#   --> Set the path of the default desktop picture on OS X.
#   Type: String
#   Default: undef
#
# [*desktop_pic_locked*]
#   --> This locks the value of the desktop picture so that users can
#     select their own picture or not (read Note above).
#   Type: Integer
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
#  managedmac::desktoppicture::desktop_pic_path:
#    "/Library/Desktop Pictures/Abstract.jpg"
#  managedmac::desktoppicture::desktop_pic_locked: true
#
# Then simply, create a manifest and include the class...
#
#  # Example: my_manifest.pp
#  include managedmac::desktoppicture
#
# If you just wish to test the functionality of this class, you could also do
# something along these lines:
#
#  class { 'managedmac::desktoppicture':
#    desktop_pic_path        => '/Library/Desktop Pictures/Abstract.jpg',
#    desktop_pic_locked      => true,
#  }
#
# === Authors
#
# Clayton Burlison <clburlison@gmail.com>
# Brian Warsing <bcw@sfu.ca>
#
# === Copyright
#
# Copyright 2014 Simon Fraser University, unless otherwise noted.
#
class managedmac::desktoppicture (

  $desktop_pic_path    = undef,
  $desktop_pic_locked  = undef,

) {

  unless $desktop_pic_path == undef {
    validate_absolute_path ($desktop_pic_path)
  }

  unless $desktop_pic_locked == undef {
    validate_bool ($desktop_pic_locked)
  }

  $params = {
    'com.apple.desktop' => {
      'locked'                => $desktop_pic_locked,
      'override-picture-path' => $desktop_pic_path
    },
  }

  # Should return Array
  $content = process_mobileconfig_params($params)

  $mobileconfig_ensure = empty($content) ? {
    true  => 'absent',
    false => 'present',
  }

  $organization = hiera('managedmac::organization', 'Simon Fraser University')

  mobileconfig { 'managedmac.desktoppicture.alacarte':
    ensure       => $mobileconfig_ensure,
    content      => $content,
    displayname  => 'Managed Mac: Desktop Picture',
    description  => 'Desktop Picture configuration. Installed by Puppet.',
    organization => $organization,
  }

}
