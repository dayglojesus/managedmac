# Class: managedmac::ntp
#
#
class managedmac::ntp ($options) {

  validate_hash  ($options)
  validate_array ($options[servers])

  unless is_integer($options[max_offset]) {
    fail("max_offset not an Integer: ${options[max_offset]}")
  }

  file { 'ntp_conf':
    ensure  => present,
    owner   => 'root',
    group   => 'wheel',
    mode    => '0644',
    path    => '/private/etc/ntp.conf',
    content => inline_template("<%= @options['servers'].join('\n') %>"),
  }

  service { 'org.ntp.ntpd':
    ensure  => running,
    enable  => true,
    require => File['ntp_conf'],
  }

}