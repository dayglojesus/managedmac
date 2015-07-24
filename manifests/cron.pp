# == Class: managedmac::cron
#
# Dynamically create Puppet Cron resources using the Puppet built-in
# 'create_resources' function.
#
# We do some validation of data, but the usual caveats apply: garbage in,
# garbage out.
#
# === Parameters
#
# [*jobs*]
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
# managedmac::cron::jobs:
#  logrotate:
#    command: '/usr/sbin/logrotate'
#    user:    'root'
#    hour:    2
#    minute:  0
#
# Then simply, create a manifest and include the class...
#
#  # Example: my_manifest.pp
#  include managedmac::cron
#
# If you just wish to test the functionality of this class, you could also do
# something along these lines:
#
#  # Create some Hashes
#  $defaults = { user => 'root', hour => 2, minute => 0 }
#  $jobs = {
#     'logrotate' => { 'command' => '/usr/bin/who > /tmp/who.dump' },
#  }
#
#  class { 'managedmac::cron':
#    jobs     => $jobs,
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
class managedmac::cron (

  $jobs     = {},
  $defaults = {},

) {

  unless empty ($jobs) {

    validate_raw_constructor ($jobs)
    validate_hash ($defaults)
    create_resources(cron, $jobs, $defaults)

  }

}