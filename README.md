# managedmac

Copyright 2015, Simon Fraser University.

## Overview

A comprehensive collection of Puppet classes and types for managing OS X.

---
#### Puppet Version 4.x is not currently supported

---

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
* Puppet 3.x (No Puppet Version 4 support at this time)
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

## What can I do with this thing?

Good question. [Here are 1700 lines of heavily commented YAML you can peruse to get an idea!](https://github.com/dayglojesus/managedmac/blob/master/files/sample.yaml)

It should give you good overview of what the module can do.

## Classes

There are a number of classes included in this module; each one groups a specific set of configuration options.

[Documentation on classes is available on the Github project page.](http://dayglojesus.github.io/managedmac/classes)

## Custom Types

There are a few custom types used in this module. Naturally, once you have installed the module, these types will be available to use in your own Puppet code if you don't fancy using any of the builtin classes.

[Documentation on custom types and providers is available on the Github project page.](http://dayglojesus.github.io/managedmac/types)

## More Documentation

[For more docs, tutorials, and how-tos, see the project page on Github.](http://dayglojesus.github.io/managedmac/)
