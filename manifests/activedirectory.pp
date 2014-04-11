# == Class: managedmac::activedirectory
#
# Leverages the Mobileconfig type and Activedirectory provider to configure and
# bind a Mac to Active Directory.
#
# === Parameters
#
# This class takes a two parameters:
# [*ensure*]
#   Whether to apply the resource or remove it. Valid values: present or
#   absent. Pass a Symbol or a String.
#   Default: 'present'
#
# [*options*]
#   Within the options Hash, there are three required keys:
#     HostName (String): the name of the domain you are binding to
#     UserName (String): the account that performs the bind operation
#     Password (String): the password for UserName
#
#   All other Hash keys are optional:
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
# This class was designed to be used with Hiera. As such, the best way to pass
# options is to specify them in your Hiera datadir:
#
#  # Example: defaults.yaml
#  ---
#  managedmac::activedirectory::options:
#    HostName: ad.apple.com
#    UserName: some_account
#    Password: some_password
#    ADMountStyle: afp
#    ADCreateMobileAccountAtLogin: true
#    ADWarnUserBeforeCreatingMA: false
#    ADForceHomeLocal: true
#    ADDomainAdminGroupList:
#      - APPLE\Domain Admins
#      - APPLE\Enterprise Admins
#    ADTrustChangePassIntervalDays: 0
#
# Then simply, create a manifest and include the class...
#
#  # Example: my_manifest.pp
#  include managedmac::activedirectory
#
# If you just wish to test the functionality of this class, you could also do
# something along these lines:
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
class managedmac::activedirectory ($ensure = present, $options) {

  # Only validate to required variables if we are activating the resource
  if $ensure == present {

    validate_hash ($options)

    # HostName
    validate_string ($options[HostName])
    if empty($options[HostName]) {
      fail('Missing Option: HostName')
    }

    # UserName
    validate_string ($options[UserName])
    if empty($options[UserName]) {
      fail('Missing Option: UserName')
    }

    # Password
    validate_string ($options[Password])
    if empty($options[Password]) {
      fail('Missing Option: Password')
    }
  } else {
    unless $ensure == 'absent' {
      fail("Parameter Error: invalid value for :ensure, ${ensure}")
    }
  }

  $options[PayloadType] = 'com.apple.DirectoryService.managed'

  mobileconfig { 'managedmac.activedirectory.alacarte':
    ensure       => $ensure,
    provider     => activedirectory,
    displayname  => 'Managed Mac: Active Directory',
    description  => 'Active Directory configuration. Installed by Puppet.',
    organization => 'Simon Fraser University',
    content      => [$options],
  }

}
