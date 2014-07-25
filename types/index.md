---
layout: types
title: Custom Types
---
## Custom Types

There are a few custom types used in this module. Naturally, once you've installed the module, these types will be available to use in your own Puppet code if you don't fancy using any of the builtin classes.

---
<a id="Macauthdb"></a>
### Macuthdb

This is an alternative to the native Puppet _Macauthorization_ type.

If you've used Puppet on your Macs before, you probably know that the builtin type is used for managing authorization not supported under Mavericks because it operates by modifying /etc/authorization.

To workaround this, many folks have been using Puppet Exec statements. This is a satisfactory solution in most cases, but if need more granular control, Macauthdb returns the ability to manage the multitude of settings available in the OS X authdb. It does this by making changes to /var/db/authdb directly.

For those who were using _Macauthorization_, the interface will be very similar.

    macauthdb { 'system.preferences':
      ensure            => default,
      allow_root        => true,
      auth_class        => user,
      authenticate_user => true,
      comment           => 'Checked by the Admin framework when making changes to certain System Preferences.',
      group             => 'admin',
      shared            => true,
      timeout           => 2147483647,
      tries             => 10000,
      version           => '1',
    }

---
<a id="Macgroup"></a>
### Macgroup

This is an alternative to the native Puppet _Group_ type.

This type was implemented with the express purpose of making nestedgroups (groups-in-groups) possible. The Puppet native type does not support this; _Macgroups_ does. It also has the ability strictly enforce group membership or simply ensure that the defined members are present in the list of users or nestedgroups. This is useful if you don't want group control to be overly rigid.

    macgroup { 'foo':
      ensure       => present,
      realname     => 'FooGroup',
      comment      => 'Installed by Puppet',
      users        => ['foo', 'bar', 'baz'],
      nestedgroups => ["ABCDEFAB-CDEF-ABCD-EFAB-CDEF00000050", 'group_two'],
      strict       => true,
    }

#### IMPORTANT:
A word of caution about using _names_ when specifying a `nestedgroup`...

When you provide a list of group names, the _Macgroup_ type will attempt to resolve the record to its associated GeneratedUID. This is IMPORTANT to keep in mind when referring to external node records (ie. LDAP or AD) or ANY record that may not already be resolvable.

If it cannot resolve the record name to GeneratedUID, the _Macgroup_ type will generate a warning and _skip_ configuration of the unresolvable record.

---
<a id="Mobileconfig"></a>
### Mobileconfig

This type is unique to this module and is very much at the center of what it does. It's pretty straightforward.

_Mobileconfig_ is capable of dynamically creating and managing the installation and removal of OS X profiles. Example:

    $content = { 'PayloadType' => 'com.apple.dock',
      'autohide'    => 'true',
      'largesize'   => '128',
      'orientation' => 'left',
      'tilesize'    => '128'
    }

    mobileconfig { 'managedmac.dock.alacarte':
      ensure            => present,
      content           => [$content],
      description       => 'Installed by Puppet',
      displayname       => 'Managed Mac: Dock Settings',
      organization      => 'Simon Fraser University',
      removaldisallowed => false,
    }

#### IMPORTANT:

Before you get caught off-guard, there are some limitations to this custom type that you need to know about. Simply put, the limitations are borne of the utility on which it relies, `/usr/bin/profiles`. This utility, while extremely useful, is also the sole purveyor of information about profile installations and it has some quirks.

There are 3 known edge cases:

- Profiles that contain Passwords (fixed in 0.4.5)
- Profiles that contain MCX
- Profiles that contain Embedded Certificates

In first case, *Passwords*, _this problem is solved by using MD5 hashing_. However, these other cases are pesky.

For example, if you install a profile that contains a `com.apple.ManagedClient.preferences` payload and run `/usr/bin/profiles -P -o ~/Desktop/all_profiles.plist` the resulting file will contain no trace of the MCX settings you placed in the payload.

*If you think this is dumb, file a radar and reference #17252001.*

Another interesting no-show in `profiles` are embedded certificates -- `profiles` will display the profile, but the certificate payloads will NOT be displayed. Unlike the MCX payload, this one is almost certainly a conscious effort to conceal vital security details. Moreover, profiles that contain embedded certs (probably) have the certs stripped and added to the System.keychain. The information regarding which profile installed which certificate is SOMEWHERE on the system, but `profiles` does not return any authoritative link between the profile and the certs.

####[If you discover another edge case, please file a bug report.](https://github.com/dayglojesus/managedmac/issues)

---
<a id="Propertylist"></a>
### Propertylist

There have been a few good Puppet modules that provide support for managing OS X Property Lists, most notably @glarizza's [property\_list\_key](https://forge.puppetlabs.com/glarizza/property_list_key). This type takes its cue from Gary's module but introduces some new features:

* management of a plist as a file
* plist management whole or in part
* management of the plist as a preference domain

Like Gary's type/provider, _Propertylist_ leverages @ckruse's awesome CFPropertyList gem -- which enables Ruby to read and write Apple Property Lists natively. Also like Gary's module, it will _require_ you to install a working copy of it because [the one that ships with Mavericks has a bug](https://github.com/glarizza/puppet-property_list_key#the-cfpropertylist-provider).

Example 1:

You can transpose a PropertyList file into a Puppet resource.

    `sudo puppet resource propertylist /Library/Preferences/com.apple.loginwindow.plist `

    propertylist { '/Library/Preferences/com.apple.loginwindow.plist':
      ensure  => 'present',
      content => {'MCXLaunchAfterUserLogin' => 'true',
                  'OptimizerLastRunForBuild' => '27396096',
                  'OptimizerLastRunForSystem' => '168362496',
                  'lastUser' => 'loggedIn',
                  'lastUserName' => 'foo'},
      format  => 'binary',
      group   => 'wheel',
      mode    => '0644',
      owner   => 'root',
    }

Example 2:

By default, plist content is managed as a whole. If you only want to manage one or two keys, change the `method` param to `insert`.

    $content = { LoginwindowText => 'A message to you, Rudy.' }

    propertylist { '/Library/Preferences/com.apple.loginwindow.plist':
      ensure  => present,
      method  => insert,
      content => $content,
    }

Example 3:

Use the `defaults` provider to manage a plist like a preferences domain.

Avoid problems with `cfprefsd` and preference domain synchronization by
setting the provider parameter to :defaults.

    $content = { LoginwindowText => 'A message to you, Rudy.' }

    propertylist { '/Library/Preferences/com.apple.loginwindow.plist':
      ensure   => present,
      method   => insert,
      content  => $content,
      provider => defaults,
    }

The defaults provider will not write directly to disk. Instead, it uses the /usr/bin/defaults utility to sync the data so that the changes are picked up by cfprefsd.

#### IMPORTANT:

When you use the `defaults` provider, the content property MUST be a Hash (Dictionary) because that is what OS X `defaults` demands. If you attempt to use another primitive, Puppet will raise an exception.

---
<a id="Remotemanagement"></a>
### Remotemanagement

This is a direct port of the remotemanagement type from [x_types](https://github.com/dayglojesus/x_types) with a few improvements.

It basically abstracts the OS X `kickstart` utility and manages user ACLs/permissions.

    remotemanagement { 'apple_remote_desktop':
      ensure            => 'running',
      allow_all_users   => false,
      enable_menu_extra => false,
      users             => {'fry' => -1073741569, 'bender' => -2147483646, 'leela' => -1073741822 },
    }

There is a good example of usage in manifests/remotemanagement.pp.
