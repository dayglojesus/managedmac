# == Class: managedmac::softwareupdate
#
# Abstracts com.apple.SoftwareUpdate PayloadType using Mobileconfig type
# and controls keys in global com.apple.SoftwareUpdate and com.apple.storeagent
# prefs domain.
#
# === Parameters
#
# [*catalog_url*]
#   The URL for your Apple Software Update server. This will be validated using
#   regex, so it needs to at least have the appearnce of being a URL.
#   Corresponds to CatalogURL. Managed as a profile.
#   Type: String
#   e.g. "http://swscan.apple.com/content/catalogs/index-1.sucatalog"
#
# [*allow_pre_release_installation*]
#   When false, Macs can no longer install pre-release versions of
#   OS X Yosemite from the OS X Beta Program. Corresponds to
#   AllowPreReleaseInstallation. Managed as a profile.
#   Type: Boolean
#
# [*automatic_update_check*]
#   Whether or not to automatically check for Apple Software Updates.
#   Corresponds to AutomaticCheckEnabled. Managed in global preferences by
#   directly modifying the property list.
#   Type: Boolean
#
# [*auto_update_apps*]
#   Whether or not to automatically install App Store app updates.
#   Corresponds to AutoUpdate. Managed in global preferences by
#   directly modifying the com.apple.storeagent property list.
#   Type: Boolean
#
# [*automatic_download*]
#   Whether or not to automatically download required Apple Software Updates.
#   Corresponds to AutomaticDownload. Managed in global preferences by
#   directly modifying the property list.
#   Type: Boolean
#
# [*config_data_install*]
#   Whether or not to automatically download and install updated system data
#   files and security updates (Eg. XProtect).
#   Corresponds to ConfigDataInstall. Managed in global preferences by
#   directly modifying the property list.
#   Type: Boolean
#
# [*critical_update_install*]
#   Whether or not to automatically download and install critical system
#   and security updates (Eg. Security Update 2014-002).
#   Corresponds to CriticalUpdateInstall. Managed in global preferences by
#   directly modifying the property list.
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
#  managedmac::softwareupdate::catalog_url: http://foo.bar.com/whatever.dude
#  managedmac::softwareupdate::automatic_update_check: true
#  managedmac::softwareupdate::auto_update_apps: true
#  managedmac::softwareupdate::automatic_download: false
#  managedmac::softwareupdate::config_data_install: false
#  managedmac::softwareupdate::critical_update_install: false
#
# Then simply, create a manifest and include the class...
#
#  # Example: my_manifest.pp
#  include managedmac::softwareupdate
#
# If you just wish to test the functionality of this class, you could also do
# something along these lines:
#
#  class { 'managedmac::softwareupdate':
#    catalog_url =>'http://swscan.apple.com/content/catalogs/index-1.sucatalog',
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
class managedmac::softwareupdate (

  $catalog_url                    = undef,
  $allow_pre_release_installation = undef,
  $automatic_update_check         = undef,
  $auto_update_apps               = undef,
  $automatic_download             = undef,
  $config_data_install            = undef,
  $critical_update_install        = undef,

) {

  unless $allow_pre_release_installation == undef {
    validate_bool ($allow_pre_release_installation)
  }

  unless $automatic_update_check == undef {
    validate_bool ($automatic_update_check)
  }

  unless empty($catalog_url) {
    validate_re ($catalog_url, '\Ahttp:\/\/(\w+\.)+\w+\/')
  }

  unless $automatic_download == undef {
    validate_bool ($automatic_download)
  }

  unless $auto_update_apps == undef {
    validate_bool ($auto_update_apps)
  }

  unless $config_data_install == undef {
    validate_bool ($config_data_install)
  }

  unless $critical_update_install == undef {
    validate_bool ($critical_update_install)
  }

  $store_plist_content = {
    'AutoUpdate' => $auto_update_apps,
  }

  $store_plist_ensure = inline_template("<%= @store_plist_content.delete_if {
    |k,v| (v.respond_to?(:empty?) and v.empty?) or v == :undef } %>")

  unless empty($store_plist_content) {
    propertylist { '/Library/Preferences/com.apple.storeagent.plist':
      ensure   => present,
      content  => $store_plist_content,
      owner    => 'root',
      group    => 'wheel',
      mode     => '0644',
      method   => insert,
      provider => defaults,
    }
  }

  $swup_plist_content = {
    'AutomaticCheckEnabled' => $automatic_update_check,
    'AutomaticDownload'     => $automatic_download,
    'ConfigDataInstall'     => $config_data_install,
    'CriticalUpdateInstall' => $critical_update_install,
  }

  $swup_plist_ensure = inline_template("<%= @swup_plist_content.delete_if {
    |k,v| (v.respond_to?(:empty?) and v.empty?) or v == :undef } %>")

  unless empty($swup_plist_content) {
    propertylist { '/Library/Preferences/com.apple.SoftwareUpdate.plist':
      ensure   => present,
      content  => $swup_plist_content,
      owner    => 'root',
      group    => 'wheel',
      mode     => '0644',
      method   => insert,
      provider => defaults,
    }
  }

  $params = {
    'com.apple.SoftwareUpdate' => {
      'CatalogURL'                  => $catalog_url,
      'AllowPreReleaseInstallation' => $allow_pre_release_installation,
    }
  }

  $mobileconfig_content = process_mobileconfig_params($params)

  $mobileconfig_ensure = empty($mobileconfig_content) ? {
    true  => 'absent',
    false => 'present',
  }

  $organization = hiera('managedmac::organization', 'Simon Fraser University')

  mobileconfig { 'managedmac.softwareupdate.alacarte':
    ensure       => $mobileconfig_ensure,
    displayname  => 'Managed Mac: Software Update',
    description  => 'Software Update configuration. Installed by Puppet.',
    organization => $organization,
    content      => $mobileconfig_content,
  }

}
