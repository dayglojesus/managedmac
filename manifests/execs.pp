# == Class: managedmac::execs
#
# Dynamically create Puppet Exec resources using the Puppet built-in
# 'create_resources' function.
#
# We do some validation of data, but the usual caveats apply: garbage in,
# garbage out.
#
# === Parameters
#
# [*commands*]
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
#
# This class was designed to be used with Hiera. As such, the best way to pass
# options is to specify them in your Hiera datadir:
#
# # Example: defaults.yaml
# ---
# managedmac::execs::commands:
#   who_dump:
#     command: '/usr/bin/who > /tmp/who.dump'
#   ps_dump:
#     command: '/bin/ps aux > /tmp/ps.dump'
#
# Then simply, create a manifest and include the class...
#
#  # Example: my_manifest.pp
#  include managedmac::execs
#
# If you just wish to test the functionality of this class, you could also do
# something along these lines:
#
#  # Create some Hashes
#  #defaults = { 'returns' => [0,1], }
#  $commands = {
#     'who_dump' => { 'command' => '/usr/bin/who > /tmp/who.dump' },
#     'ps_dump'  => { 'command' => '/bin/ps aux  > /tmp/ps.dump' },
#  }
#
#  class { 'managedmac::execs':
#    commands  => $commands,
#    defaults => $defaults,
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
class managedmac::execs (

  $commands = {},
  $defaults = {},

) {

  unless empty ($commands) {

    validate_raw_constructor ($commands)
    validate_hash ($defaults)
    create_resources(exec, $commands, $defaults)

  }

}