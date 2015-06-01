# == Class: managedmac::activedirectory
#
# Binds an OS X machine to Active Directory and manages that configuration.
#
# ********* IMPORTANT: USING PROVIDERS *********
#
# This class can leverage TWO different providers to configure Active
# Directory binding:
#
# ************************************
# 1. Dsconfigad (default)
# ************************************
#
# This provider abstracts Apple's '/usr/sbin/dsconfigad' utility and passes
# the specified parameters to it.
#
# As such, the Dsconfigad provider WILL NOT destroy an Active Directory
# binding when changing simple AD plugin configuration values.
#
# NOTE: You *must* specify a $computer parameter when using the Dsconfigad
# provider. See https://github.com/dayglojesus/managedmac/issues/72
#
# ************************************
# 2. Mobileconfig (DEPRECATED)
# ************************************
#
# This provider is deprecated. DO NOT use it, it is slated for removal...
# YOU HAVE BEEN WARNED.
#
# This is the simplest provider, but it is also the dumbest. All we do is
# install a 'com.apple.DirectoryService.managed' profile that will bind to
# the specified Active Directory.
#
# Binding in this manner has the benefit of being very easy to troubleshoot.
# For instance, if a client is experiencing Active Directory problems, you
# could direct them to remove the profile and then trigger a Puppet run to
# re-apply it. However, this methodology has one critical flaw...
#
# If you change ANY setting while using this provider, the entire profile
# will be removed and reinstalled. This is simply the way profiles behave.
# Unfortunately, it also implies that the Active Directory bind will be
# destoyed and recreated. This can be disastrous if the bind is never
# re-established successfully.
#
# === Parameters
#
# *********** IMPORTANT *************
#
# The following parameters are ONLY used by the Dsconfigad provider:
#
#   * force
#   * leave (broken -- see below)
#   * computer (required)
#   * sharepoint
#   * authority
#
# The Mobileconfig provider will ignore them.
#
# ************************************
#
# [*enable*]
#   Whether to apply the resource or remove it. Pass a Symbol or a String.
#   Type: Boolean
#   Default: undef
#
# [*evaluate*]
#   A seatbelt intended to prevent the Active Directory configuration
#   from being removed or modified. Any administrator defined condition
#   can serve as the basis for comparison.
#   Pass: 'yes', 'no', 'true' or 'false'
#   If 'no' or 'false', the mobileconfig resource is not evaluated and a
#   warning is produced. Useful in conjunction with a custom Facter fact.
#   Type: String
#   Default: undef
#
# [*provider*]
#   String representation of the provider type. Accepts: dsconfigad and
#   mobileconfig.
#   Type: String
#   Default: dsconfigad
#
# [*force*]
#   *** DSCONFIGAD ONLY! ***
#   Force the process (i.e., join the existing account or remove the
#   binding. Accepts: enable or disable
#   Type: String
#   Default: enable
#
# [*leave*]
#   *** BROKEN! (DSCONFIGAD ONLY!) ***
#   * Using this feature will procude a Segmentation Fault error in the
#   * dsconfigad utility. This is an Apple bug. If it were to work it would
#   * perform the following function...
#   **************************************
#   Leaves the current domain (preserving the computer record in the
#   directory). Accepts: enable or disable
#   Type: String
#   Default: disable
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
# [*computer*]
#   *** DSCONFIGAD ONLY! ***
#   The "computerid" to add the specified Domain. Required parameter.
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
# [*sharepoint*]
#   *** DSCONFIGAD ONLY! ***
#   Enable or disable mounting of the network home as a sharepoint.
#   Accepts: enable or disable
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
# [*authority*]
#   *** DSCONFIGAD ONLY! ***
#   This feature is not described in the man page. Enable or disable
#   generation of Kerberos authority
#   Accepts: enable or disable
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
#   Type: Array
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
#   Default: undef
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
#  managedmac::activedirectory::provider: dsconfigad
#  managedmac::activedirectory::hostname: ad.apple.com
#  managedmac::activedirectory::username: some_account
#  managedmac::activedirectory::password: some_password
#  managedmac::activedirectory::computer: some_computer
#  managedmac::activedirectory::evaluate: "%{::domain_available?}"
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
#     provider                        => 'dsconfigad',
#     evaluate                        => $::domain_available?,
#     hostname                        => 'foo.ad.com',
#     username                        => 'some_account',
#     password                        => 'some_password',
#     computer                        => 'some_computer',
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
# Copyright 2015 Simon Fraser University, unless otherwise noted.
#
class managedmac::activedirectory (

  $enable                           = undef,
  $evaluate                         = undef,
  $provider                         = dsconfigad,
  $force                            = 'enable',
  $leave                            = 'disable',
  $hostname                         = undef,
  $username                         = undef,
  $password                         = undef,
  $computer                         = undef,
  $organizational_unit              = undef,
  $mount_style                      = undef,
  $sharepoint                       = undef,
  $default_user_shell               = undef,
  $map_uid_attribute                = undef,
  $map_gid_attribute                = undef,
  $map_ggid_attribute               = undef,
  $authority                        = undef,
  $preferred_dc_server              = undef,
  $namespace                        = undef,
  $domain_admin_group_list          = undef,
  $restrict_ddns                    = undef,
  $packet_sign                      = undef,
  $packet_encrypt                   = undef,
  $create_mobile_account_at_login   = undef,
  $warn_user_before_creating_ma     = undef,
  $force_home_local                 = undef,
  $use_windows_unc_path             = undef,
  $allow_multi_domain_auth          = undef,
  $trust_change_pass_interval_days  = undef,

) {

  # If the ntp class is enabled, let's get the time synchronized first
  if hiera('managedmac::ntp::enable', false) {
    require managedmac::ntp
  }

  unless $enable == undef {

    unless $provider =~ /\Amobileconfig\z|\Adsconfigad\z/ {
      fail("Parameter :provider must be \'mobileconfig\' or \'dsconfigad\', \
[${provider}]")
    }

    validate_bool ($enable)

    unless $evaluate == undef {
      unless $evaluate =~ /\Ayes\z|\Ano\z|\Atrue\z|\Afalse\z/ {
        fail("Parameter :evaluate must be \'yes\', \'no\', \'true\' or \
\'false\' [${evaluate}]")
      }
    }

    unless $enable == false {

      unless $force =~ /\Aenable\z|\Adisable\z/ {
        fail("Parameter :force must be \'enable\' or \'disable\', \
[${force}]")
      }

      unless $leave =~ /\Aenable\z|\Adisable\z/ {
        fail("Parameter :leave must be \'enable\' or \'disable\', \
[${leave}]")
      }

      if $hostname == undef {
        fail('You must specify a :hostname param!')
      }

      if $username == undef {
        fail('You must specify a :username param!')
      }

      if $password == undef {
        fail('You must specify a :password param!')
      }

      unless $computer == undef {
        validate_string ($computer)
      }

      unless $organizational_unit == undef {
        validate_string ($organizational_unit)
      }

      unless $mount_style == undef {
        unless $mount_style =~ /\Aafp\z|\Asmb\z/ {
          fail("Parameter :mount_style must be \'afp\' or \'smb\', \
[${mount_style}]")
        }
      }

      unless $sharepoint == undef {
        unless $sharepoint =~ /\Aenable\z|\Adisable\z/ {
          fail("Parameter :sharepoint must be \'enable\' or \'disable\', \
[${sharepoint}]")
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

      unless $authority == undef {
        unless $authority =~ /\Aenable\z|\Adisable\z/ {
          fail("Parameter :authority must be \'enable\' or \'disable\', \
[${authority}]")
        }
      }

      unless $preferred_dc_server == undef {
        validate_string ($preferred_dc_server)
      }

      unless $namespace == undef {
        unless $namespace =~ /\Aforest\z|\Adomain\z/ {
          fail("Parameter :namespace must be \'forest\' or \'domain\', \
[${namespace}]")
        }
      }

      unless $domain_admin_group_list == undef {
        unless empty($domain_admin_group_list) {
          validate_array ($domain_admin_group_list)
        }
      }

      unless $restrict_ddns == undef {
        validate_array ($restrict_ddns)
      }

      unless $packet_sign == undef {
        unless $packet_sign =~ /\Aallow\z|\Adisable\z|\Arequire\z/ {
          fail("Parameter :packet_sign must be \'allow\', \'disable\' or \
\'require\', [${packet_sign}]")
        }
      }

      unless $packet_encrypt == undef {
        unless $packet_encrypt =~ /\Aallow\z|\Adisable\z|\Arequire\z|\Assl\z/ {
          fail("Parameter :packet_encrypt must must be \'allow\', \'disable\',\
\'require\' or \'ssl\', ${packet_encrypt}")
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
          fail("trust_change_pass_interval_days not an Integer: \
${trust_change_pass_interval_days}")
        }
      }
    }

    $ensure = $enable ? {
      true  => present,
      false => absent,
    }

    # If it's safe to evaluate the state of the resource, or if we are only
    # interested in unbinding, do so. Otherwise, just produce a warning.
    $safe = $evaluate ? {
      /yes|true/ => true,
      /no|false/ => false,
      default    => true,
    }

    if $provider == mobileconfig {

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

      $organization = hiera('managedmac::organization',
        'Simon Fraser University')

      if $safe {

        mobileconfig { 'managedmac.activedirectory.alacarte':
          ensure       => $ensure,
          displayname  => 'Managed Mac: Active Directory',
          description  => "Active Directory configuration. Installed by \
Puppet.",
          organization => $organization,
          content      => $options,
        }

      }

    } else {

      if $safe {

        $dsconfigad_params = {
          ensure          => $ensure,
          force           => $force,
          leave           => $leave,
          username        => $username,
          password        => $password,
          computer        => $computer,
          ou              => $organizational_unit,
          mobile          => $create_mobile_account_at_login,
          mobileconfirm   => $warn_user_before_creating_ma,
          localhome       => $force_home_local,
          useuncpath      => $use_windows_unc_path,
          protocol        => $mount_style,
          sharepoint      => $sharepoint,
          shell           => $default_user_shell,
          uid             => $map_uid_attribute,
          gid             => $map_gid_attribute,
          ggid            => $map_ggid_attribute,
          authority       => $authority,
          preferred       => $preferred_dc_server,
          groups          => $domain_admin_group_list,
          alldomains      => $allow_multi_domain_auth,
          packetsign      => $packet_sign,
          packetencrypt   => $packet_encrypt,
          namespace       => $namespace,
          passinterval    => $trust_change_pass_interval_days,
          restrictddns    => $restrict_ddns,
        }

        $dsconfigad_hash = process_dsconfigad_params($dsconfigad_params)
        create_resources(dsconfigad, { "${hostname}" => $dsconfigad_hash })

      }

    }

    unless $safe {
      warning("Active Directory configuration will not be evaluated during \
this run.")
    }

  }

}
