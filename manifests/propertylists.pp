# == Class: managedmac::propertylists
#
# Dynamically create Puppet Propertylist resources using the Puppet built-in
# 'create_resources' function.
#
# We do some validation of data, but the usual caveats apply: garbage in,
# garbage out.
#
# === Parameters
#
# [*files*]
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
# managedmac::propertylists::defaults:
#   owner: root
#   group: wheel
#   format: xml
# managedmac::propertylists::files:
#   '/path/to/a/file.plist':
#     content:
#       - 'A string.'
#       - a_hash_key: 1
#       - 42
#   '/path/to/another/file.plist':
#     content:
#       0: 1
#       foo: bar
#       bar: baz
#       an_array:
#          - 99
#
# Then simply, create a manifest and include the class...
#
#  # Example: my_manifest.pp
#  include managedmac::propertylists
#
# If you just wish to test the functionality of this class, you could also do
# something along these lines:
#
# # Create some Hashes
# $defaults = { owner => 'root', method => insert, }
# $files = {
#   '/this/is/a/file.plist' => {
#     'content' => { 'some_key' => 'some_value'},
#     format => xml,
#   },
# }
#
# class { 'managedmac::propertylists':
#   files    => $files,
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
class managedmac::propertylists (

  $files    = {},
  $defaults = {},

) {

  unless empty ($files) {

    validate_raw_constructor ($files)
    validate_hash ($defaults)
    create_resources(propertylist, $files, $defaults)

  }

}