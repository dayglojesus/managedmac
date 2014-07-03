# == Class: managedmac::activedirectory
#
# Leverages the Mobileconfig type and Activedirectory provider to configure and
# bind a Mac to Active Directory.
#
# === Parameters
#
# [*enable*]
#   Whether to apply the resource or remove it. Pass a Symbol or a String.
#   Type: Boolean
#   Default: undef
#
# [*hostname*]
#   The Active Directory domain to join. This parameter is required when
#   :enabled is true.
#   Type: String
#   Default: undef
#
# [*username*]
#   User name of the account used to join the domain. This parameter is
#   required when :enabled is true.
#   Type: String
#   Default: undef
#
# [*password*]
#   Password of the account used to join the domain. This parameter is
#   required when :enabled is true.
#   Type: String
#   Default: undef
#
# [*organizational_unit*]
#   The organizational unit (OU) where the joining computer object is added
#   Type: String
#   Default: undef
#
# [*mount_style*]
#   Network home protocol to use: "afp" or "smb"
#   Type: String
#   Default: undef
#
# [*default_user_shell*]
#   Default user shell; e.g. /bin/bash
#   Type: String
#   Default: undef
#
# [*map_uid_attribute*]
#   Map UID to attribute
#   Type: String
#   Default: undef
#
# [*map_gid_attribute*]
#   Map user GID to attribute
#   Type: String
#   Default: undef
#
# [*map_ggid_attribute*]
#   Map group GID to attribute
#   Type: String
#   Default: undef
#
# [*preferred_dc_server*]
#   Prefer this domain server
#   Type: String
#   Default: undef
#
# [*restrict_ddns*]
#   Restrict Dynamic DNS updates to the specified interfaces (e.g. en0,
#   en1, etc)
#   Type: String
#   Default: undef
#
# [*namespace*]
#   Set primary user account naming convention: "forest" or "domain";
#   "domain" is default
#   Type: String
#   Default: undef
#
# [*domain_admin_group_list*]
#   Allow administration by specified Active Directory groups
#   Type: Array
#   Default: []
#
# [*packet_sign*]
#   Packet signing: "allow", "disable" or "require"; "allow" is default
#   Type: String
#   Default: undef
#
# [*packet_encrypt*]
#   Packet encryption: "allow", "disable", "require" or "ssl"; "allow"
#   is default
#   Type: String
#   Default: undef
#
# [*create_mobile_account_at_login*]
#   Create mobile account at login
#   Type: Boolean
#   Default: undef
#
# [*warn_user_before_creating_ma*]
#   Warn user before creating a Mobile Account
#   Type: Boolean
#   Default: undef
#
# [*force_home_local*]
#   Force local home directory
#   Type: Boolean
#   Default: undef
#
# [*use_windows_unc_path*]
#   Use UNC path from Active Directory to derive network home location
#   Type: Boolean
#   Default: undef
#
# [*allow_multi_domain_auth*]
#   Allow authentication from any domain in the forest
#   Type: Boolean
#   Default: undef
#
# [*trust_change_pass_interval_days*]
#   How often to require change of the computer trust account password in
#   days; "0" is disabled
#   Type: Integer
#   Default: undef
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
#  managedmac::activedirectory::enable: true
#  managedmac::activedirectory::hostname: ad.apple.com
#  managedmac::activedirectory::username: some_account
#  managedmac::activedirectory::password: some_password
#  managedmac::activedirectory::mount_style: afp
#  managedmac::activedirectory::create_mobile_account_at_login: true
#  managedmac::activedirectory::warn_user_before_creating_ma: false
#  managedmac::activedirectory::force_home_local: true
#  managedmac::activedirectory::domain_admin_group_list:
#     - APPLE\Domain Admins
#     - APPLE\Enterprise Admins
#  managedmac::activedirectory::trust_change_pass_interval_days: 0
#
# Then simply, create a manifest and include the class...
#
#  # Example: my_manifest.pp
#  include managedmac::activedirectory
#
# If you just wish to test the functionality of this class, you could also do
# something along these lines:
#
#  class { 'managedmac::activedirectory':
#     hostname                        => 'foo.ad.com',
#     username                        => 'some_account',
#     password                        => 'some_password',
#     mount_style                     => 'afp',
#     trust_change_pass_interval_days => 0,
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
class managedmac::activedirectory (

  $enable                          = undef,
  $hostname                        = undef,
  $username                        = undef,
  $password                        = undef,
  $organizational_unit             = undef,
  $mount_style                     = undef,
  $default_user_shell              = undef,
  $map_uid_attribute               = undef,
  $map_gid_attribute               = undef,
  $map_ggid_attribute              = undef,
  $preferred_dc_server             = undef,
  $namespace                       = undef,
  $domain_admin_group_list         = [],
  $restrict_ddns                   = undef,
  $packet_sign                     = undef,
  $packet_encrypt                  = undef,
  $create_mobile_account_at_login  = undef,
  $warn_user_before_creating_ma    = undef,
  $force_home_local                = undef,
  $use_windows_unc_path            = undef,
  $allow_multi_domain_auth         = undef,
  $trust_change_pass_interval_days = undef,

) {

  # If the ntp class is enabled, let's get the time synchronized first
  if hiera('managedmac::ntp::enable', false) {
    require managedmac::ntp
  }

  unless $enable == undef {

    validate_bool ($enable)

    unless $enable == false {

      if $hostname == undef {
        fail("You must specify a :hostname param!")
      }

      if $username == undef {
        fail("You must specify a :username param!")
      }

      if $password == undef {
        fail("You must specify a :password param!")
      }

      unless $organizational_unit == undef {
        validate_string ($organizational_unit)
      }

      unless $mount_style == undef {
        unless $mount_style =~ /\Aafp\z|\Asmb\z/ {
          fail("Parameter :mount_style must be \'afp\' or \'smb\', [${mount_style}]")
        }
      }

      unless $default_user_shell == undef {
        validate_string ($default_user_shell)
      }

      unless $map_uid_attribute == undef {
        validate_string ($map_uid_attribute)
      }

      unless $map_gid_attribute == undef {
        validate_string ($map_gid_attribute)
      }

      unless $map_ggid_attribute == undef {
        validate_string ($map_ggid_attribute)
      }

      unless $preferred_dc_server == undef {
        validate_string ($preferred_dc_server)
      }

      unless $namespace == undef {
        unless $namespace =~ /\Aforest\z|\Adomain\z/ {
          fail("Parameter :namespace must be \'forest\' or \'domain\', [${namespace}]")
        }
      }

      unless empty($domain_admin_group_list) {
        validate_array ($domain_admin_group_list)
      }

      unless $restrict_ddns == undef {
        validate_string ($restrict_ddns)
      }

      unless $packet_sign == undef {
        unless $packet_sign =~ /\Aallow\z|\Adisable\z|\Arequire\z/ {
          fail("Parameter :packet_sign must be \'allow\', \'disable\' or \'require\', [${packet_sign}]")
        }
      }

      unless $packet_encrypt == undef {
        unless $packet_encrypt =~ /\Aallow\z|\Adisable\z|\Arequire\z|\Assl\z/ {
          fail("Parameter :packet_encrypt must must be \'allow\', \'disable\', \'require\' or \'ssl\', ${packet_encrypt}")
        }
      }

      unless $create_mobile_account_at_login == undef {
        validate_bool ($create_mobile_account_at_login)
      }

      unless $warn_user_before_creating_ma == undef {
        validate_bool ($warn_user_before_creating_ma)
      }

      unless $force_home_local == undef {
        validate_bool ($force_home_local)
      }

      unless $use_windows_unc_path == undef {
        validate_bool ($use_windows_unc_path)
      }

      unless $allow_multi_domain_auth == undef {
        validate_bool ($allow_multi_domain_auth)
      }

      unless $trust_change_pass_interval_days == undef {
        unless is_integer($trust_change_pass_interval_days) {
          fail("trust_change_pass_interval_days not an Integer: ${trust_change_pass_interval_days}")
        }
      }
    }

    $params = {
      'com.apple.DirectoryService.managed' => {
        'HostName'                       => $hostname,
        'UserName'                       => $username,
        'Password'                       => $password,
        'ADOrganizationalUnit'           => $organizational_unit,
        'ADMountStyle'                   => $mount_style,
        'ADDefaultUserShell'             => $default_user_shell,
        'ADMapUIDAttribute'              => $map_uid_attribute,
        'ADMapGIDAttribute'              => $map_gid_attribute,
        'ADMapGGIDAttribute'             => $map_ggid_attribute,
        'ADPreferredDCServer'            => $preferred_dc_server,
        'ADNamespace'                    => $namespace,
        'ADDomainAdminGroupList'         => $domain_admin_group_list,
        'ADRestrictDDNS'                 => $restrict_ddns,
        'ADPacketSign'                   => $packet_sign,
        'ADPacketEncrypt'                => $packet_encrypt,
        'ADCreateMobileAccountAtLogin'   => $create_mobile_account_at_login,
        'ADWarnUserBeforeCreatingMA'     => $warn_user_before_creating_ma,
        'ADForceHomeLocal'               => $force_home_local,
        'ADUseWindowsUNCPath'            => $use_windows_unc_path,
        'ADAllowMultiDomainAuth'         => $allow_multi_domain_auth,
        'ADTrustChangePassIntervalDays'  => $trust_change_pass_interval_days,
      },
    }

    $options = process_mobileconfig_params($params)

    mobileconfig { 'managedmac.activedirectory.alacarte':
      ensure       => $enable ? {
        true  => present,
        false => absent,
      },
      provider     => activedirectory,
      displayname  => 'Managed Mac: Active Directory',
      description  => 'Active Directory configuration. Installed by Puppet.',
      organization => 'Simon Fraser University',
      content      => $options,
    }

  }
}
