# managedmac

Author: Brian Warsing bcw@sfu.ca Copyright 2014, Simon Fraser University.

## Overview

A comprehensive collection of Puppet classes and types for managing OS X.

## Description

This is a giant Puppet module. It abstracts all the things. It won't win any awards for being small and portable and pretty, because it does A LOT OF STUFF.

Some of this stuff is very useful, a lot of it is new, all of it is IN ONE PLACE.

* Mobileconfig Type for managing OS X profiles
* Propertylist Type for managing OS X plist and preferences
* Macauthdb Type for managing OS X Authorization DB
* Macgroup Type for managing groups-in-groups
* Manages Login/Logout Hooks globally
* Manages ARD/ScreenSharing service and related ACLs
* Manages Bluetooth/Airport power
* Manages FileVault configuration
* Raw Constructor classes for users, groups, etc.
* Lots more...

## Requirements

* OS X 10.9 or greater
* Puppet 3.x
* puppetlabs-stdlib module
* CFPropertyList gem
* sqlite3 gem

## How does it work?

This module was designed to be a world-engine for OS X.

You fuel it with Hiera data.

By itself, it does nothing, but...

Once, you've installed the components and created a configuration file, you have everything you need to begin terraforming.

Example:

    --
    managedmac::organization: My Organization         # identify yourself
    managedmac::ntp::enable: true                     # turn on the ntp client
    managedmac::ntp::servers:                         # use a list of ntp servers
      - time.apple.com
      - time1.google.com
    managedmac::filevault::enable: true               # turn on FDE
    managedmac::filevault::use_recovery_key: true     # use a recovery key
    managedmac::filevault::show_recovery_key: true    # show the user the key
    managedmac::mobileconfigs::payloads:              # manage the dock, but why?
      'managedmac.dock.alacarte':
        content:
          largesize: 128
          orientation: left
          tilesize: 128
          autohide: true
          PayloadType: 'com.apple.dock'
        displayname: 'Managed Mac: Dock Settings'

For more information about the zillions of options available, see files/sample.yaml.

## Quick Start!

Drink from the firehose demonstration... If you were running masterless Puppet, the setup would be very similar.

### Install Packages

You need to install the following packages:

* [Facter](https://downloads.puppetlabs.com/mac/)
* [Hiera](https://downloads.puppetlabs.com/mac/)
* [Puppet](https://downloads.puppetlabs.com/mac/)

Then, install these gems:

    sudo gem install CFPropertyList sqlite3
    sudo puppet module install sfu-managedmac

### Rig Hiera...

Just create this symlink:

    cd /etc/puppet
    sudo ln -s /etc/hiera.yaml hiera.yaml

### Create Hiera Data

Open your favorite text editor, copy in the YAML below and save it as (requires root):

#### /var/lib/hiera/defaults.yaml

    --
    managedmac::mobileconfigs::payloads:              # manage the dock, but why?
      'managedmac.dock.alacarte':
        content:
          largesize: 128
          orientation: left
          tilesize: 128
          autohide: true
          PayloadType: 'com.apple.dock'
        displayname: 'Managed Mac: Dock Settings'

### Run Puppet...

Here's a simple manifest piped into `puppet apply`

    echo "include managedmac" | sudo puppet apply

In addition to changes in the Dock's appearance you should see a new profile in System Preferences appear called, 'Managed Mac: Dock Settings'.

If you delete this profile and run Puppet again, it will re-appear. Try it.

Now, try running this and inspecting the output...

    sudo puppet resource mobileconfig managedmac.dock.alacarte

What you see is Puppet's representation of the profile you installed using the `managedmac::mobileconfigs` class.

This class belongs to a special group of classes within the module we refer to as _Raw Constructors_.

_Raw Constructors_ provide a means of extending the module by directly adding resources to the catalog without the need to create any new Puppet manifests.

## What else can I do with this thing?

Good question. Here are 1700 lines of heavily commented YAML you can peruse to get an idea!

It should give you good overview of what the module can do with just a little YAML authoring.

## Classes

There are a number of classes included in this module; each one groups a specific set of configuration options.

[Documentation on classes is available on the Github project page.](https://github.com/dayglojesus/managedmac)

## Custom Types

There are a few custom types used in this module. Naturally, once you have installed the module, these types will be available to use in your own Puppet code if you don't fancy using any of the builtin classes.

### Macuthdb

This is an alternative to the native Puppet _Macauthorization_ type.

If you've used Puppet on your Macs before, you probably know that the builtin type is not supported under Mavericks because it operates by modifying /etc/authorization. To workaround this, many folks have been using Puppet Exec statements. This is a satisfactory solution in most cases, but if need more granular control, Macauthdb returns the ability to manage the multitude of settings available in the OS X authdb. It does this by making changes to /var/db/authdb directly.

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

_Mobileconfig_ actually sports two providers:

* _activedirectory_ whose sole purpose is to perform [Advanced Active Directory binding](http://support.apple.com/kb/HT5981?viewlocale=en_US&locale=en_US)
* _default_ which handles everything else

Generally speaking, the default is all you'll need, unless you want to roll your own bind-to-activedirectory Puppet class.

#### IMPORTANT:

Before you get caught off-guard, there are some limitations to this custom type that you need to know about. Simply put, the limitations are borne of the utility on which it relies, `/usr/bin/profiles`. This utility, while extremely useful, is also the sole purveyor of information about profile installations and it has some quirks.

For example, if you install a profile that contains a `com.apple.ManagedClient.preferences` payload and run `/usr/bin/profiles -P -o ~/Desktop/all_profiles.plist` the resulting file will contain no trace of the MCX settings you placed in the payload.

*If you think this is dumb, file a radar and reference #17252001.*

Another interesting no-show in `profiles` are embedded certificates -- `profiles` will display the profile, but the certificate payloads will NOT be displayed. Unlike the MCX payload, this one is almost certainly a conscious effort to conceal vital security details. Moreover, profiles that contain embedded certs (probably) have the certs stripped and added to the System.keychain. The information regarding which profile installed which certificate is SOMEWHERE on the system, but `profiles` does not return any authoritative link between the profile and the certs.

Another example of concealing security details happens with the [Advanced Active Directory configuration profile](http://support.apple.com/kb/HT5981?viewlocale=en_US&locale=en_US). This profile accepts a username and password which it uses to bind to your AD. Of course, exposing the password via `profiles` would likely be a bad idea. This means checking the value of the password you handed Puppet becomes tricky. To deal with this, a separate provider (activedirectory) was created. See manifests/activedirectory.pp for an example of using the activedirectory provider.

*Those are the 3 edge cases I have found -- there may be more...*

### Propertylist

There have been a few good Puppet modules that provide support for managing OS X Property Lists, most notably @glarizza's [property__list__key](https://forge.puppetlabs.com/glarizza/property_list_key). This type takes its cue from Gary's module but introduces some new features:

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

## More Documentation

[For more docs, tutorials, and how-tos, see the project page on Github.](https://github.com/dayglojesus/managedmac)
