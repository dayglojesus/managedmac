# Class: managedmac::ntp
#
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