# == Class: managedmac::filevault
#
# Leverages the Mobileconfig type to deploy a Filevault profile. It provides
# only a subset of the options available to the profile and does not conform to
# the Apple defaults. Read the documentation.
#
# === Parameters
#
# This class takes 6 parameters:
#
# [*enable*]
#   --> Set to 'On' to enable FileVault. Set to 'Off' to disable FileVault.
#   This value is required.
#   Type: Boolean
#   Default: false
#
# [*defer*]
#   --> Set to true to defer enabling FileVault until the designated user logs
#   out.
#   Type: Boolean
#   Default: true
#
# [*use_recovery_key*]
#   --> Set to true to create a personal recovery key.
#   Type: Boolean
#   Default: true
#
# [*show_recovery_key*]
#   --> Set to true to display the personal recovery key to the user after
#   FileVault is enabled.
#   Type: Boolean
#   Default: false
#
# [*output_path*]
#   --> Path to the location where the recovery key and computer information
#   plist will be stored.
#   Type: String
#   Default: /private/var/root/fdesetup_output.plist
#
# [*use_keychain*]
#   --> If set to true and no certificate information is provided in this
#   payload, the keychain already created at
#   /Library/Keychains/FileVaultMaster.keychain will be used when the
#   institutional recovery key is added.
#   Type: Boolean
#   Default: true
#
# [*keychain_file*]
#   --> An absolute path or puppet:/// style URI from whence to gather an FVMI.
#   It will install and manage /Library/Keychains/FileVaultMaster.keychain.
#   Only works when $use_keychain is true.
#   Type: String
#   Default: empty
#
# [*destroy_fv_key_on_standby*]
#   --> Prevent saving the key across standby modes.
#   Type: Boolean
#   Default: false
#
# [*dont_allow_fde_disable*]
#   --> Prevent users from disabling FDE.
#   Type: Boolean
#   Default: false
#
# [*remove_fde*]
#   --> Removes FDE if $enable is false and the disk is encrypted.
#   Type: Boolean
#   Default: false
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
# managedmac::filevault::defer: true
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
#    defer  => true,
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
class managedmac::filevault (

  $enable                     = false,
  $defer                      = true,
  $use_recovery_key           = true,
  $show_recovery_key          = false,
  $output_path                = '/private/var/root/fdesetup_output.plist',
  $use_keychain               = false,
  $keychain_file              = '',
  $destroy_fv_key_on_standby  = false,
  $dont_allow_fde_disable     = false,
  $remove_fde                 = false,

){

  validate_bool ($enable)
  validate_bool ($defer)
  validate_bool ($use_recovery_key)
  validate_bool ($show_recovery_key)
  validate_bool ($use_keychain)
  validate_bool ($destroy_fv_key_on_standby)
  validate_bool ($dont_allow_fde_disable)
  validate_absolute_path ($output_path)

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
      mode   => 0644,
      path   => '/Library/Keychains/FileVaultMaster.keychain',
      source => "${keychain_file}";
    }

  }

  $filevault_payload = { 'PayloadType' => 'com.apple.MCX.FileVault2',
    'Enable'          => 'On',
    'Defer'           => $defer,
    'UseRecoveryKey'  => $use_recovery_key,
    'ShowRecoveryKey' => $show_recovery_key,
    'OutputPath'      => $output_path,
    'UseKeychain'     => $use_keychain,
  }

  $mcx_payload = { 'PayloadType' => 'com.apple.MCX',
    'DestroyFVKeyOnStandby' => $destroy_fv_key_on_standby,
    'dontAllowFDEDisable'   => $dont_allow_fde_disable,
  }

  mobileconfig { 'managedmac.filevault.alacarte':
    ensure => $enable ? {
      true     => 'present',
      default  => 'absent',
    },
    content      => [$mcx_payload, $filevault_payload],
    displayname  => 'Managed Mac: FileVault 2',
    description  => 'FileVault 2 configuration. Installed by Puppet.',
    organization => 'Simon Fraser University',
  }

  if ($enable == false) and ($::filevault_active == true) and ($remove_fde == true)  {
    exec { 'decrypt_the_disk':
      command => '/usr/bin/fdesetup disable',
      returns => [0,1],
    }
  }

}
