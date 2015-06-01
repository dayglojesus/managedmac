# == Class: managedmac::ntp
#
# Activates and configures NTP synchronization.
#
# === Parameters
#
# This class takes a two parameters:
#
# [*enable*]
#   Whether to enable to ntp client or not.
#   Type: Bool
#   Default: undef
#
# [*servers*]
#   A list of NTP servers to use.
#   Type: Array
#   Default: ['time.sfu.ca']
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
#  managedmac::ntp::enable: true
#  managedmac::ntp::servers:
#    - time.apple.com
#    - time1.google.com
#
# Then simply, create a manifest and include the class...
#
#  # Example: my_manifest.pp
#  include managedmac::ntp
#
# If you just wish to test the functionality of this class, you could also do
# something along these lines:
#
#  class { 'managedmac::ntp':
#   enable  => true,
#   servers => ['time.apple.com', 'time1.google.com'],
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
class managedmac::ntp (

  $enable  = undef,
  $servers = ['time.apple.com']

) {

  unless $enable == undef {

    validate_bool  ($enable)
    validate_array ($servers)

    $ntp_service_label = 'org.ntp.ntpd'
    $ntp_conf_default  = 'server time.apple.com'
    $ntp_conf_template = inline_template("<%= (@servers.collect {
      |x| ['server', x].join('\s') }).join('\n') %>")

    $content = $enable ? {
      true  => $ntp_conf_template,
      false => $ntp_conf_default,
    }

    $ensure = $enable ? {
      true  => 'running',
      false => 'stopped',
    }

    file { 'ntp_conf':
      ensure  => file,
      owner   => 'root',
      group   => 'wheel',
      mode    => '0644',
      path    => '/private/etc/ntp.conf',
      content => $content,
      before  => Service[$ntp_service_label],
    }

    service { $ntp_service_label:
      ensure  => $ensure,
      enable  => true,
      require => File['ntp_conf'],
    }

  }
}
