# Class: managedmac::ntp
#
#
class managedmac::ntp ($options) {

  validate_hash  ($options)
  validate_array ($options[servers])

  unless is_integer($options[max_offset]) {
    fail("max_offset not an Integer: ${options[max_offset]}")
  }

  $ntp_conf_template = "<%= (@options['servers'].collect {
    |x| ['server', x].join('\s') }).join('\n') %>"

  $ntp_service_label = 'org.ntp.ntpd'

  file { 'ntp_conf':
    ensure  => present,
    owner   => 'root',
    group   => 'wheel',
    mode    => '0644',
    path    => '/private/etc/ntp.conf',
    content => inline_template($ntp_conf_template),
    notify  => Service[$ntp_service_label],
  }

  service { $ntp_service_label:
    ensure  => running,
    enable  => true,
    require => File['ntp_conf'],
  }

  if $::ntp_offset > $options[max_offset] {
    exec { 'ntp_sync':
      command => "/bin/launchctl stop ${ntp_service_label}",
      notify  => Service[$ntp_service_label],
      require => File['ntp_conf'],
    }
  }

}