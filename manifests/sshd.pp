# == Class: managedmac::sshd
#
# Activates and controls the OS X SSH daemon.
#
# === Parameters
#
# [*enable*]
#   Whether to enable the service or not, true or false.
#   Type: Bool
#   Default: undef
#
# [*sshd_config*]
#   Path to file on your Puppet master or a local system.
#   Type: String
#   Default: undef
#
# [*sshd_banner*]
#   Path to file on your Puppet master or a local system.
#   Type: String
#   Default: undef
#
# [*users*]
#   A list of user accounts permitted to access the service.
#   Type: Array
#   Default: []
#
# [*groups*]
#   A list of user groups permitted to access the service.
#   Type: Array
#   Default: ['admin']
#
# [*strict*]
#   How to handle membership in the users and nestedgroups arrays. Informs the
#   provider whether to merge the specified members into the record, or replace
#   them outright. See the Macgroup documentation for details.
#   Type: Boolean
#
# === Variables
#
# None
#
# === Examples
#
# This class was designed to be used with Hiera. As such, the best way to pass
# options is to specify them in your Hiera datadir:
#
#  # Example: defaults.yaml
#  ---
#  managedmac::sshd::enable: true
#  managedmac::sshd::sshd_config: puppet:///modules/your_module/sshd_config
#  managedmac::sshd::sshd_banner: puppet:///modules/your_module/sshd_banner
#  managedmac::sshd::users:
#      - leela
#      - bender
#  managedmac::sshd::groups:
#      - robotmafia
#
# Then simply, create a manifest and include the class...
#
#  # Example: my_manifest.pp
#  include managedmac::sshd
#
# If you just wish to test the functionality of this class, you could also do
# something along these lines:
#
#  class { 'managedmac::sshd':
#    enable => true,
#    users => ['bender', 'fry']
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
class managedmac::sshd (

  $enable      = undef,
  $sshd_config = undef,
  $sshd_banner = undef,
  $users       = [],
  $groups      = ['ABCDEFAB-CDEF-ABCD-EFAB-CDEF00000050'],
  $strict      = true,

) {

  unless $enable == undef {

    $service_label      = 'com.openssh.sshd'
    $acl_group          = 'com.apple.access_ssh'
    $acl_group_disabled = 'com.apple.access_ssh-disabled'
    $admin_guid         = 'ABCDEFAB-CDEF-ABCD-EFAB-CDEF00000050'

    validate_bool ($enable)

    unless $sshd_config == undef {
      validate_re ($sshd_config, '\A(puppet:\/\/)?(\/.+)+\z')
      file { 'sshd_config':
        ensure => file,
        owner  => 'root',
        group  => 'wheel',
        mode   => '0644',
        path   => '/etc/sshd_config',
        source => $sshd_config,
        backup => '.puppet-bak',
      }
    }

    unless $sshd_banner == undef {
      validate_re ($sshd_banner, '\A(puppet:\/\/)?(\/.+)+\z')
      file { 'sshd_banner':
        ensure => file,
        owner  => 'root',
        group  => 'wheel',
        mode   => '0644',
        path   => '/etc/sshd_banner',
        source => $sshd_banner,
        backup => '.puppet-bak',
      }
    }

    validate_array ($users)
    validate_array ($groups)

    $users_attr = $enable ? {
      true  => $users,
      false => [],
    }

    $groups_attr = $enable ? {
      true  => $groups,
      false => [$admin_guid],
    }

    # Workaround for OS X SSHD ACL group resource conflict
    # https://github.com/dayglojesus/managedmac/issues/41
    macgroup { $acl_group_disabled:
      ensure => absent,
      gid    => 399,
    }

    macgroup { $acl_group:
      ensure       => present,
      gid          => 399,
      users        => $users_attr,
      nestedgroups => $groups_attr,
      strict       => $strict,
      require      => Macgroup[$acl_group_disabled],
    }

    service { $service_label:
      ensure  => $enable,
      enable  => true,
      require => Macgroup[$acl_group],
    }

  }

}
