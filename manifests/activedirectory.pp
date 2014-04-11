# == Class: managedmac::activedirectory
#
# Leverages the Mobileconfig type and Activedirectory provider to configure and
# bind a Mac to Active Directory.
#
# === Parameters
#
# This class takes a single compound parameter (Hash): options
#
# [*options*]
#   Within the options Hash, there are three required keys:
#     HostName (String): the name of the domain you are binding to
#     UserName (String): the account that performs the bind operation
#     Password (String): the password for UserName
#
#   All other keys are optional:
#     ADOrganizationalUnit (String)
#     ADMountStyle (String)
#     ADDefaultUserShell (String)
#     ADMapUIDAttribute (String)
#     ADMapGIDAttribute (String)
#     ADMapGGIDAttribute (String)
#     ADPreferredDCServer (String)
#     ADRestrictDDNS (String)
#     ADNamespace (String)
#     ADDomainAdminGroupList (Array)
#     ADPacketSign (bool)
#     ADPacketEncrypt (bool)
#     ADCreateMobileAccountAtLogin (bool)
#     ADWarnUserBeforeCreatingMA (bool)
#     ADForceHomeLocal (bool)
#     ADUseWindowsUNCPath (bool)
#     ADAllowMultiDomainAuth (bool)
#     ADTrustChangePassIntervalDays (Integer)
#
# === Variables
#
# Not applicable
#
# === Examples
#
#  # Create an options Hash
#  $options = {
#   'HostName' => 'foo.ad.com',
#   'UserName' => 'some_account',
#   'Password' => 'some_password',
#   'ADMountStyle' => 'afp',
#   'ADTrustChangePassIntervalDays' => 0,
#  }
#
#  class { 'managedmac::activedirectory':
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
class managedmac::activedirectory ($options) {

  validate_hash   ($options)
  validate_string ($options[HostName])
  validate_string ($options[UserName])
  validate_string ($options[Password])

  $options[PayloadType] = 'com.apple.DirectoryService.managed'

  mobileconfig { 'managedmac.activedirectory.alacarte':
    ensure       => present,
    provider     => activedirectory,
    displayname  => 'Managed Mac: Active Directory',
    description  => 'Active Directory configuration. Installed by Puppet.',
    organization => 'Simon Fraser University',
    content      => [$options],
  }

}

