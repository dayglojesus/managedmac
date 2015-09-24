# == Class: managedmac::mobileconfigs
#
# Dynamically create Puppet Mobileconfig resources using the Puppet built-in
# 'create_resources' function.
#
# We do some validation of data, but the usual caveats apply: garbage in,
# garbage out.
#
# === Parameters
#
# [*payloads*]
#   This is a Hash of Hashes.
#   The hash should be in the form { title => { parameters } }.
#   See http://tinyurl.com/7783b9l, and the examples below for details.
#   Type: Hash
#
# [*defaults*]
#   A Hash that defines the default values for the resources created.
#   See http://tinyurl.com/7783b9l, and the examples below for details.
#   Type: Hash
#
# === Variables
#
# Not applicable
#
# === Examples
# This class was designed to be used with Hiera. As such, the best way to pass
# options is to specify them in your Hiera datadir:
#
# # Example: defaults.yaml
# ---
# managedmac::mobileconfigs::defaults:
#   description:  'Installed by Puppet.'
#   organization: 'Puppet Labs'
# managedmac::mobileconfigs::payloads:
#   'managedmac.dock.alacarte':
#     content:
#       largesize: 128
#       orientation: left
#       tilesize: 128
#       autohide: true
#       PayloadType: 'com.apple.dock'
#     displayname: 'Managed Mac: Dock Settings'
#
# Then simply, create a manifest and include the class...
#
#  # Example: my_manifest.pp
#  include managedmac::mobileconfigs
#
# If you just wish to test the functionality of this class, you could also do
# something along these lines:
#
# # Create some Hashes
# $defaults = { 'organization' => 'Puppet Labs'}
# $payloads = {
#   'managedmac.dock.alacarte' => {
#     'content' => { 'orientation' => 'left',
#        'PayloadType' => 'com.apple.dock'
#      },
#     'displayname' => 'My Custom Dock',
#   },
# }
#
# class { 'managedmac::mobileconfigs':
#   payloads => $payloads,
#   defaults => $defaults,
# }
#
# === Authors
#
# Brian Warsing <bcw@sfu.ca>
#
# === Copyright
#
# Copyright 2015 Simon Fraser University, unless otherwise noted.
#
class managedmac::mobileconfigs (

  $payloads = {},
  $defaults = {}

) {

  unless empty ($payloads) {

    validate_raw_constructor ($payloads)
    validate_hash ($defaults)
    create_resources(mobileconfig, $payloads, $defaults)

  }

}