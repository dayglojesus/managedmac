# == Class: managedmac::groups
#
# Dynamically create Puppet Macgroup resources using the Puppet built-in
# 'create_resources' function.
#
# We do some validation of data, but the usual caveats apply: garbage in,
# garbage out.
#
# === Parameters
#
# [*accounts*]
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
# managedmac::groups::defaults:
#   ensure: present
# managedmac::groups::accounts:
#   foo_group:
#     gid: 998
#     users:
#       - foo
#       - bar
#   bar_group:
#     gid: 999
#     nestedgroups:
#       - foo_group
#
# Then simply, create a manifest and include the class...
#
# # Example: my_manifest.pp
# include managedmac::groups
#
# If you just wish to test the functionality of this class, you could also do
# something along these lines:
#
# # Create some Hashes
# $defaults = { 'ensure' => 'present', }
# $accounts = {
#   'foo_group' => { 'gid' => 511, 'users'        => ['foo'] },
#   'bar_group' => { 'gid' => 522, 'nestedgroups' => ['foo_group'] },
# }
#
# class { 'managedmac::groups':
#   accounts => $accounts,
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
class managedmac::groups (

  $accounts = undef,
  $defaults = {}

) {

  if is_hash(hiera('managedmac::activedirectory::enable', false)) {
    require managedmac::activedirectory
  }

  unless $accounts == undef {

    if empty ($accounts) {

      fail('Parameter Error: $accounts is empty')

    } else {

      validate_raw_constructor ($accounts)
      validate_hash ($defaults)
      create_resources(macgroup, $accounts, $defaults)

    }
  }
}
