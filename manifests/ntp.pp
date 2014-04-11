# == Class: managedmac::ntp
#
# Activates and strictly enforces NTP synchronization.
#
# === Parameters
#
# This class takes a two parameters:
#
# [*ensure*]
#   Whether to apply the resource or remove it. Accepts values: present or
#   absent. Pass a Symbol or a String.
#   Default: present
#
# [*options*]
#   Within the options Hash, there are two required keys:
#     servers (Array): a list of NTP servers to use
#     max_offset (Integer): the max +/- allowable clock skew
#
# === Variables
#
# [*ntp_offset*]
#   Custom Facter fact: calculated clock skew.
#
# === Examples
#
# This class was designed to be used with Hiera. As such, the best way to pass
# options is to specify them in your Hiera datadir:
#
#  # Example: defaults.yaml
#  ---
#  managedmac::ntp::options:
#    servers:
#      - time.apple.com
#      - time1.google.com
#    max_offset: 200
#
# Then simply, create a manifest and include the class...
#
#  # Example: my_manifest.pp
#  include managedmac::ntp
#
# If you just wish to test the functionality of this class, you could also do
# something along these lines:
#
#  # Create an options Hash
#  $options = {
#   'servers' => ['time.apple.com', 'time1.google.com'],
#   'max_offset' => 200,
#  }
#
#  class { 'managedmac::ntp':
#    options => $options,
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
class managedmac::ntp ($ensure = present, $options = {}) {

  # Only validate varaiables if ensure=present
  if $ensure == present {

    validate_hash ($options)
    # servers
    validate_array ($options[servers])
    # max_offset
    unless is_integer($options[max_offset]) {
      fail("max_offset not an Integer: ${options[max_offset]}")
    }

    $service_state = running
    $enabled = true
    $ntp_conf_template = inline_template("<%= (@options['servers'].collect {
      |x| ['server', x].join('\s') }).join('\n') %>")

  } else {

    unless $ensure == 'absent' {
      fail("Parameter Error: invalid value for :ensure, ${ensure}")
    }

    $service_state = stopped
    $enabled = false
    $ntp_conf_template = 'time.apple.com'
  }

  $ntp_service_label = 'org.ntp.ntpd'

  file { 'ntp_conf':
    ensure  => file,
    owner   => 'root',
    group   => 'wheel',
    mode    => '0644',
    path    => '/private/etc/ntp.conf',
    content => $ntp_conf_template,
    notify  => Service[$ntp_service_label],
  }

  service { $ntp_service_label:
    ensure  => $service_state,
    enable  => $enabled,
    require => File['ntp_conf'],
  }

  if $ensure == present {
    if abs($::ntp_offset) > $options[max_offset] {
      exec { 'ntp_sync':
        command => "/bin/launchctl stop ${ntp_service_label}",
        notify  => Service[$ntp_service_label],
        require => [File['ntp_conf'], Service[$ntp_service_label]]
      }
    }
  }

}