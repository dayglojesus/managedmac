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
  
  def options_energysaver
    schedule = {
      'RepeatingPowerOff' => { 'eventtype' => 'sleep', 'time' => 1410, 
        'weekdays' => 127},  
      'RepeatingPowerOn'  => { 'eventtype' => 'wakepoweron', 'time' => 480, 
        'weekdays' => 127}
    }
    
    ac_power = { "Automatic Restart On Power Loss" => true,
      "Disk Sleep Timer-boolean" => true,
      "Display Sleep Timer" => 15,
      "Sleep On Power Button" => false,
      "Wake On LAN" => true,
      "System Sleep Timer" => 30,
    }

    battery_power = { "Automatic Restart On Power Loss" => true,
      "Disk Sleep Timer-boolean" => true,
      "Display Sleep Timer" => 15,
      "Sleep On Power Button" => false,
      "Wake On LAN" => true,
      "System Sleep Timer" => 30,
    }
    
    {
      'desktop'  => { 'ACPower' => ac_power, 'Schedule' => schedule },
      'portable' => { 'ACPower' => ac_power, 'BatteryPower' => battery_power }
    }
  end
  
end
