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

  def accounts_users
    {
      'foo' => {
                 'ensure'     => 'present',
                 'comment'    => 'Created by Puppet',
                 'gid'        => 20,
                 'groups'     => ['_appserveradm', '_appserverusr', '_lpadmin', 'admin', 'com.apple.sharepoint.group.1'],
                 'home'       => '/Users/bar',
                 'iterations' => 33682,
                 'password'   => '6e849409877191dd5b28bcbda2e0619dbe7ee6c6fc30620eb2508df6cbfcf5b57cac66da5a65812aa50970510f72a45b690402325d5cb736095780ef288f5c2be85ea70a49006b94835c8bbf66445656a1f4c3f1c2ec2c89666aaace545d2b2e88de634a779b9d909b6f62e8e182d4dd843b5952fb2913bdfa6a0e824e6c3cea',
                 'salt'       => '4b07f6938c5774751b2d794d5b18200584a0fbd1b23b62a43491f5f7aeb9e174',
                 'shell'      => '/bin/bash',
                 'uid'        => 501,
               },

      'bar' => {
                 'ensure'     => 'present',
                 'comment'    => 'Created by Puppet',
                 'gid'        => 20,
                 'groups'     => ['_appserveradm', '_appserverusr', '_lpadmin', 'admin', 'com.apple.sharepoint.group.1'],
                 'home'       => '/Users/bar',
                 'iterations' => 31260,
                 'password'   => '6e849409877191dd5b28bcbda2e0619dbe7ee6c6fc30620eb2508df6cbfcf5b57cab66da5a65812aa50970510f72a45b690402325d5cb736095780ef288f5c2be85ea70a49006b94835c8bbf66445656a1f4c3f1c2ec2c89666aaace545d2b2e88de634a779b9d909b6f62e8e182d4dd843b5952fb2913bdfa6a0e824e6c3cea',
                 'salt'       => '4b07f6938c4774751b2d794d5b18200584a0fbd1b23b62a43491f5f7aeb9e174',
                 'shell'      => '/bin/bash',
                 'uid'        => 502,
               }
    }
  end

  def accounts_groups
    {
      'foo_group' => {
        'gid'          => 554,
        'users'        => ['root', 'nobody', 'daemon',],
        'nestedgroups' => ['admin', 'staff',],
      },

      'bar_group' => {
        'gid'          => 555,
        'users'        => ['root', 'nobody', 'daemon',],
        'nestedgroups' => ['admin', 'staff',],
      },

    }
  end

  def mobileconfigs_payloads
    {
      'managedmac.dock.alacarte' => {
        'content' => {
          'largesize' => 128,
          'orientation' => 'left',
          'tilesize' => 128,
          'autohide' => true,
          'PayloadType' => 'com.apple.dock',
        },
        'displayname' => 'Managed Mac: Dock Settings',
      }
    }
  end

  def acl_loginwindow
    { 'users' => ['foo', 'bar'], 'groups' => ['FooGroup', 'BarGroup'] }
  end

  def content_propertylists
    {
      '/path/to/a/file.plist' => {
        'content' => ['A string', { 'a_hash_key' => 1 }, 42],
      },
      '/path/to/b/file.plist' => {
        'content' => [{ 0 => 1 }, ['foo', 'bar', 'baz'], 99],
      },
    }
  end

  def files_objects
    {
      '/path/to/a/file.txt' => {
        'ensure'  => 'file',
        'owner'   => 'root',
        'group'   => 'admin',
        'mode'    => '0644',
        'content' => "This is an exmaple.",
      },
      '/path/to/a/directory' => {
        'ensure'  => 'directory',
        'owner'   => 'root',
        'group'   => 'admin',
        'mode'    => '0755',
      },
    }
  end

  def execs_cmds
    {
      'who_dump' => {
        'command' => '/usr/bin/who > /tmp/who.dump',
      },
      'ps_dump' => {
        'command' => '/bin/ps aux > /tmp/ps.dump',
      },
    }
  end

  def cron_jobs
    {
      'who_dump' => {
        'command' => '/usr/bin/who > /tmp/who.dump',
      },
      'ps_dump' => {
        'command' => '/bin/ps aux > /tmp/ps.dump',
      },
    }
  end

end
