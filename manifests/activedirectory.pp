# Class: managedmac::activedirectory
#
#
class managedmac::activedirectory ($options) {

  validate_hash   ($options)
  validate_string ($options[HostName])
  validate_string ($options[UserName])
  validate_string ($options[Password])
  validate_string ($options[ADOrganizationalUnit])
  validate_string ($options[ADMountStyle])
  validate_string ($options[ADDefaultUserShell])
  validate_string ($options[ADMapUIDAttribute])
  validate_string ($options[ADMapGIDAttribute])
  validate_string ($options[ADMapGGIDAttribute])
  validate_string ($options[ADPreferredDCServer])
  validate_string ($options[ADRestrictDDNS])
  validate_string ($options[ADNamespace])
  validate_array  ($options[ADDomainAdminGroupList])
  validate_bool   ($options[ADPacketSign])
  validate_bool   ($options[ADPacketEncrypt])
  validate_bool   ($options[ADCreateMobileAccountAtLogin])
  validate_bool   ($options[ADWarnUserBeforeCreatingMA])
  validate_bool   ($options[ADForceHomeLocal])
  validate_bool   ($options[ADUseWindowsUNCPath])
  validate_bool   ($options[ADAllowMultiDomainAuth])

  unless is_integer($options[ADTrustChangePassIntervalDays]) {
    fail("max_offset not an Integer: ${options[max_offset]}")
  }

  $options[PayloadType] = 'com.apple.DirectoryService.managed'

  mobileconfig { 'managedmac.activedirectory.alacarte':
    ensure       => present,
    displayname  => 'Managed Mac: Active Directory',
    description  => 'Active Directory configuration. Installed by Puppet.',
    organization => 'Simon Fraser University',
    content      => [$options],
  }

}