# == Class: managedmac::filevault
#
# Leverages the Mobileconfig type to deploy a FileVault 2 profile. It provides
# only a subset of the options available to the profile and does not conform to
# the Apple defaults. Read the documentation.
#
# === Parameters
#
# [*enable*]
#   --> Whether to enable FileVault or not.
#   Type: Boolean
#
# [*use_recovery_key*]
#   Set to true to create a personal recovery key.
#   Type: Boolean
#
# [*show_recovery_key*]
#   Set to true to display the personal recovery key to the user after
#   FileVault is enabled.
#   Type: Boolean
#
# [*output_path*]
#   Path to the location where the recovery key and computer information
#   plist will be stored.
#   Type: String
#
# [*use_keychain*]
#   If set to true and no certificate information is provided in this
#   payload, the keychain already created at
#   /Library/Keychains/FileVaultMaster.keychain will be used when the
#   institutional recovery key is added.
#   Type: Boolean
#
# [*keychain_file*]
#   An absolute path or puppet:/// style URI from whence to gather an FVMI.
#   It will install and manage /Library/Keychains/FileVaultMaster.keychain.
#   Only works when $use_keychain is true.
#   Type: String
#
# [*destroy_fv_key_on_standby*]
#   Prevent saving the key across standby modes.
#   Type: Boolean
#
# [*dont_allow_fde_disable*]
#   Prevent users from disabling FDE.
#   Type: Boolean
#
# [*remove_fde*]
#   Removes FDE if $enable is false and the disk is encrypted.
#   Type: Boolean
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
# managedmac::filevault::enable: true
# managedmac::filevault::use_recovery_key: true
# managedmac::filevault::show_recovery_key: true
#
# Then simply, create a manifest and include the class...
#
#  # Example: my_manifest.pp
#  include managedmac::filevault
#
# If you just wish to test the functionality of this class, you could also do
# something along these lines:
#
#  class { 'managedmac::filevault':
#    enable => true,
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
class managedmac::filevault (

  $enable                     = undef,
  $use_recovery_key           = undef,
  $show_recovery_key          = undef,
  $output_path                = undef,
  $use_keychain               = undef,
  $keychain_file              = undef,
  $destroy_fv_key_on_standby  = undef,
  $dont_allow_fde_disable     = undef,
  $remove_fde                 = undef,

){

  unless $enable == undef {

    validate_bool ($enable)

    unless $use_recovery_key == undef {
      validate_bool ($use_recovery_key)
    }

    unless $show_recovery_key == undef {
      validate_bool ($show_recovery_key)
    }

    unless $use_keychain == undef {
      validate_bool ($use_keychain)
    }

    unless $destroy_fv_key_on_standby == undef {
      validate_bool ($destroy_fv_key_on_standby)
    }

    unless $dont_allow_fde_disable == undef {
      validate_bool ($dont_allow_fde_disable)
    }

    unless $remove_fde == undef {
      validate_bool ($remove_fde)
    }

    unless $output_path == undef {
      validate_absolute_path ($output_path)
    }

    if $use_keychain == true {
      if $keychain_file =~ /^puppet:/ {
        validate_re ($keychain_file,
          'puppet:(\/{3}(\w+\/)+\w+|\/{2}(\w+\.)+(\w+\/)+\w+)')
      } else {
        validate_absolute_path ($keychain_file)
      }

      file { 'filevault_master_keychain':
        ensure => file,
        owner  => root,
        group  => wheel,
        mode   => '0644',
        path   => '/Library/Keychains/FileVaultMaster.keychain',
        source => $keychain_file;
      }
    }

    $params = {
      'com.apple.MCX.FileVault2' => {
        'Enable'          => 'On',
        'Defer'           => true,
        'UseRecoveryKey'  => $use_recovery_key,
        'ShowRecoveryKey' => $show_recovery_key,
        'OutputPath'      => $output_path,
        'UseKeychain'     => $use_keychain,
      },
      'com.apple.MCX' => {
        'DestroyFVKeyOnStandby' => $destroy_fv_key_on_standby,
        'dontAllowFDEDisable'   => $dont_allow_fde_disable,
      },
    }

    $content = process_mobileconfig_params($params)

    $organization = hiera('managedmac::organization',
      'Simon Fraser University')

    $ensure = $enable ? {
      true     => present,
      default  => absent,
    }

    mobileconfig { 'managedmac.filevault.alacarte':
      ensure       => $ensure,
      content      => $content,
      displayname  => 'Managed Mac: FileVault 2',
      description  => 'FileVault 2 configuration. Installed by Puppet.',
      organization => $organization,
    }

    if ($enable == false) and ($::filevault_active == true) and
($remove_fde == true)  {
      exec { 'decrypt_the_disk':
        command => '/usr/bin/fdesetup disable',
        returns => [0,1],
      }
    }

  }

}
