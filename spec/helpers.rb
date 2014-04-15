module Helpers
  
  def options_ntp
    { 'servers' => ['time.apple.com', 'time1.google.com'], 
      'max_offset' => 120, 
    }
  end
  
  def options_activedirectory
    { 'HostName'                      => 'ad.apple.com',
      'UserName'                      => 'some_user',
      'Password'                      => 'some_password',
      'ADOrganizationalUnit'          => 'cn=computers,dc=ad,dc=apple,dc=com',
      'ADMountStyle'                  => 'smb',
      'ADCreateMobileAccountAtLogin'  => true,
      'ADWarnUserBeforeCreatingMA'    => false,
      'ADForceHomeLocal'              => true,
      'ADUseWindowsUNCPath'           => true,
      'ADAllowMultiDomainAuth'        => true,
      'ADDefaultUserShell'            => '/bin/bash',
      'ADMapUIDAttribute'             => 'a_string',
      'ADMapGIDAttribute'             => 'a_string',
      'ADMapGGIDAttribute'            => 'a_string',
      'ADPreferredDCServer'           => 'dc1.ad.apple.com',
      'ADDomainAdminGroupList'        => ['APPLE\Domain Admins', 'APPLE\Enterprise Admins'],
      'ADNamespace'                   => 'forest',
      'ADPacketSign'                  => true,
      'ADPacketEncrypt'               => true,
      'ADRestrictDDNS'                => 'en0',
      'ADTrustChangePassIntervalDays' => 14,
    }
  end
  
  
  def options_softwareupdate
    { 'CatalogURL' => 'http://server.example.com:8088/catalogs.sucatlog' }
  end
  
end
