---
layout: classes
title: Puppet Classes
---
## Puppet Classes

A basic overview of the classes and their purpose.

---
### Core Classes

These classes comprise the essential functionality of the module. Each class represents an aspect of configuration.

Some group configuration options together under a single heading, others activate services or specific features of the OS X platform.

<a id="managedmac"></a>
#### managedmac

Module initializer. Accepts no parameters.

The parent class is simply here to `contain` the other classes. When you create a manifest that stipulates:

{% highlight Puppet %}
include managedmac
{% endhighlight %}

The classes contained by the parent class are essentially *dormant* until they receive configuration parameters from Hiera.

Example:

The init.pp file contains the managedmac::security class.

{% highlight Puppet %}
contain managedmac::security
{% endhighlight %}

But until a parameter is passed to the class (from Hiera or another source) the net effect of the class will be zero.

---
<a id="managedmac::activedirectory"></a>
#### managedmac::activedirectory

This class leverages the Mobileconfig type to bind of Macs to an Active Directory using an [advanced Active Directory OS X configuration profile](http://support.apple.com/kb/HT5981?viewlocale=en_US&locale=en_US).

Example:

{% highlight YAML %}
---
managedmac::activedirectory::enable: true
managedmac::activedirectory::hostname: ad.apple.com
managedmac::activedirectory::username: some_account
managedmac::activedirectory::password: some_password
{% endhighlight %}

For a complete list of parameters, see the [managedmac::activedirectory](https://github.com/dayglojesus/managedmac/blob/master/manifests/activedirectory.pp) documentation.

---
<a id="managedmac::authorization"></a>
#### managedmac::authorization

Primitive class for managing a few common customizations in the OS X authorization database.

At present, this class only controls a few of the System Preferences panes.

Example:

{% highlight YAML %}
---
# Allow 'everyone' access to the Energy Saver settings pane
managedmac::authorization::allow_energysaver: true
{% endhighlight %}

For a complete list of parameters, see the [managedmac::authorization](https://github.com/dayglojesus/managedmac/blob/master/manifests/authorization.pp) documentation.

---
<a id="managedmac::energysaver"></a>
#### managedmac::energysaver

Enables control of Energy Saver settings for Desktops and Portables using an OS X profile.

This class can be a little confusing because the data you need to pass in is fairly complicated.

Example:

{% highlight YAML %}
---
managedmac::energysaver::desktop:
  ACPower:
    'Automatic Restart On Power Loss': true
    'Disk Sleep Timer-boolean': true
    'Display Sleep Timer': 15
    'Sleep On Power Button': false
    'Wake On LAN': true
    'System Sleep Timer': 30
  Schedule:
    RepeatingPowerOff:
      eventtype: sleep
      time: 1410
      weekdays: 127
    RepeatingPowerOn:
      eventtype: wakepoweron
      time: 480
      weekdays: 127
managedmac::energysaver::portable:
  ACPower:
    'Automatic Restart On Power Loss': true
    'Disk Sleep Timer-boolean': true
    'Display Sleep Timer': 15
    'Wake On LAN': true
    'System Sleep Timer': 30
  BatteryPower:
    'Automatic Restart On Power Loss': false
    'Disk Sleep Timer-boolean': true
    'Display Sleep Timer': 5
    'System Sleep Timer': 10
    'Wake On LAN': true
{% endhighlight %}

For a complete list of parameters, see the [managedmac::energysaver](https://github.com/dayglojesus/managedmac/blob/master/manifests/energysaver.pp) documentation.

---
<a id="managedmac::filevault"></a>
#### managedmac::filevault

Manages FDE using an OS X profile.

As a bonus, this class exposes some features not available via the Profile Manger interface.

Example:
{% highlight YAML %}
---
managedmac::filevault::enable: true
managedmac::filevault::use_recovery_key: true
managedmac::filevault::show_recovery_key: true
{% endhighlight %}

For a complete list of parameters, see the [managedmac::filevault](https://github.com/dayglojesus/managedmac/blob/master/manifests/filevault.pp) documentation.

---
<a id="managedmac::loginhook"></a>
#### managedmac::loginhook

Enables the installation of a master loginhook and allows configuration of a directory child scripts.

When you activate this class, Puppet installs a master loginhook. This script then looks for the directory you specified and executes any viable code in that directory.

Example:
{% highlight YAML %}
---
managedmac::loginhook::enable: true
managedmac::loginhook::scripts: /path/to/your/scripts
{% endhighlight %}

For a complete list of parameters, see the [managedmac::loginhook](https://github.com/dayglojesus/managedmac/blob/master/manifests/loginhook.pp) documentation.

---
<a id="managedmac::loginwindow"></a>
#### managedmac::loginwindow

Controls Loginwindow ACL (com.apple.access_loginwindow) and various loginwindow options.

This class combines group management and an OS X profile to create a comprehensive feature set for controlling loginwindow.

Example:

{% highlight YAML %}
---
# Controlling access via com.apple.access_loginwindow
managedmac::loginwindow::users:
  - fry
  - bender
managedmac::loginwindow::groups:
  - robothouse
  - 20EFB92F-4842-4218-8973-9F4738963660
# Controlling access via allow/deny lists
managedmac::loginwindow::allow_list:
  - D2C2107F-CE19-4C9F-9235-688BEB01D8C0
  - 779A91D0-885B-4066-97FC-BEECB737E6AF
managedmac::loginwindow::deny_list:
  - C3F27BC2-8F89-4D56-9525-95B5133D8F25
  - F1A496E4-86EB-4387-A4D6-5D6FAD9201E7
# Configuring options
managedmac::loginwindow::loginwindow_text: "Some message..."
managedmac::loginwindow::show_name_and_password_fields: true
managedmac::loginwindow::disable_console_access: true
managedmac::loginwindow::enable_external_accounts: false
managedmac::loginwindow::hide_admin_users: false
managedmac::loginwindow::hide_local_users: false
{% endhighlight %}

For a complete list of parameters, see the [managedmac::loginwindow](https://github.com/dayglojesus/managedmac/blob/master/manifests/loginwindow.pp) documentation.

---
<a id="managedmac::logouthook"></a>
#### managedmac::logouthook

Corollary to managedmac::loginhook.

When you activate this class, Puppet installs a master logouthook. This script then looks for the directory you specified and executes any viable code in that directory.

Example:

{% highlight YAML %}
---
managedmac::logouthook::enable: true
managedmac::logouthook::scripts: /path/to/your/scripts
{% endhighlight %}

For a complete list of parameters, see the [managedmac::logouthook](https://github.com/dayglojesus/managedmac/blob/master/manifests/logouthook.pp) documentation.

---
<a id="managedmac::mcx"></a>
#### managedmac::mcx

Embeds select MCX policy in an OS X profile using the Mobileconfig type.

Used to control policy fragments not directly supported by OS X profiles.

Example:

{% highlight YAML %}
---
managedmac::mcx::bluetooth: on
managedmac::mcx::wifi: off
managedmac::mcx::loginitems:
  - /Applications/Chess.app
managedmac::mcx::suppress_icloud_setup: true
managedmac::mcx::hidden_preference_panes:
  - com.apple.preferences.icloud
{% endhighlight %}

For a complete list of parameters, see the [managedmac::mcx](https://github.com/dayglojesus/managedmac/blob/master/manifests/mcx.pp) documentation.

---
<a id="managedmac::mounts"></a>
#### managedmac::mounts

Simple class for configuring a list of shares you want mounted at login.

Dynamically creates an OS X profile containg the list of mounts. Uses OS X Finder, so prompts for authentication as required.

NOTE: [Payload variables](https://help.apple.com/profilemanager/mac/3.0/#apd073333AA-30C6-4FD2-B2E0-E0C95658A2C4) do not work. What Apple's documentation fails to distinguish is that Payload variables are not a feature of the client, but the Profile Manager service. This means that the variable substitution is performed at download time, not when the policy is being parsed.

Example:

{% highlight YAML %}
---
managedmac::mounts::urls:
 - 'https://some.dav.com/web/personal'
 - 'smb://some.windows.com/some_share'
 - 'afp://mac.server.com/some_share'
{% endhighlight %}

For a complete list of parameters, see the [managedmac::mounts](https://github.com/dayglojesus/managedmac/blob/master/manifests/mounts.pp) documentation.

---
<a id="managedmac::ntp"></a>
#### managedmac::ntp

Activates and configures NTP synchronization.

Allows you to set a list of network time servers and ensure the activation of the NTP client.

Example:

{% highlight YAML %}
---
managedmac::ntp::enable: true
managedmac::ntp::servers:
 - time.apple.com
 - time1.google.com
{% endhighlight %}

For a complete list of parameters, see the [managedmac::ntp](https://github.com/dayglojesus/managedmac/blob/master/manifests/ntp.pp) documentation.

---
<a id="managedmac::portablehomes"></a>
#### managedmac::portablehomes

Leverages the Mobileconfig type to deploy a Mobility profile capable of supporting Portable Home Directory synchronization.

This class accepts a bewildering array of parameters -- mainly because it is a option-for-option implementation of the OS X Mobility feature set.

It can be complicated to configure, but anybody who actually uses adavanced Portable Home Directory synchronization should be comfortable enough with the interface.

Some special attention was given to the design of filters so that it they are easy to control using Hiera. Also, parameters for this class do not follow normal Puppet naming conventions. This was a conscious design choice. The accpetable parameters are simply too numerous to transpose.

Example:

{% highlight YAML %}
---
managedmac::portablehomes::enable: true
managedmac::portablehomes::menuextra: on
managedmac::portablehomes::backgroundConflictResolution: mobileHomeWins
managedmac::portablehomes::backgroundSuppressErrors: true
managedmac::portablehomes::periodicSyncOn: true
managedmac::portablehomes::syncPeriodSeconds: 720
{% endhighlight %}

For a complete list of parameters, see the [managedmac::portablehomes](https://github.com/dayglojesus/managedmac/blob/master/manifests/portablehomes.pp) documentation.

---
<a id="managedmac::remotemanagement"></a>
#### managedmac::remotemanagement

Abstracts the OS X `kickstart` utility and allows control and configuration of the builtin Remote Management service.

NOTE: User ACLs use a strange notation. See the class documentation for details.

Example:

{% highlight YAML %}
---
managedmac::remotemanagement::enable: true
managedmac::remotemanagement::users:
  user_a: -1073741569
  user_b: -1073741569
managedmac::remotemanagement::enable_dir_logins: true
managedmac::remotemanagement::allowed_dir_groups:
  - com.apple.local.ard_admin
  - com.apple.local.ard_interact
  - com.apple.local.ard_manage
  - com.apple.local.ard_reports
{% endhighlight %}

For a complete list of parameters, see the [managedmac::remotemanagement](https://github.com/dayglojesus/managedmac/blob/master/manifests/remotemanagement.pp) documentation.

---
<a id="managedmac::screensharing"></a>
#### managedmac::screensharing

Controls Screen Sharing ACL (com.apple.access_screensharing) and and service options.

Combines group management and service management into a single Puppet class.

NOTE: when both `managedmac::screensharing::enable` and `managedmac::remotemanagement::enable` are true, managedmac::remotemanagement takes precedence and Screen Sharing is not activated.

Example:

{% highlight YAML %}
---
managedmac::screensharing::enable: true
managedmac::screensharing::users:
   - leela
   - bender
managedmac::screensharing::groups:
   - robotmafia
{% endhighlight %}

For a complete list of parameters, see the [managedmac::screensharing](https://github.com/dayglojesus/managedmac/blob/master/manifests/screensharing.pp) documentation.

---
<a id="managedmac::security"></a>
#### managedmac::security

Collection of various OS X Security options, applied as an OS X profile.

Example:

{% highlight YAML %}
---
managedmac::security::ask_for_password: true
managedmac::security::ask_for_password_delay: 300
managedmac::security::disable_autologin: true
{% endhighlight %}

For a complete list of parameters, see the [managedmac::security](https://github.com/dayglojesus/managedmac/blob/master/manifests/security.pp) documentation.

---
<a id="managedmac::softwareupdate"></a>
#### managedmac::softwareupdate

Manages Software Update options using an OS X profile and global preference domains.

Abstracts com.apple.SoftwareUpdate PayloadType using Mobileconfig type and controls keys in global com.apple.SoftwareUpdate and com.apple.storeagent prefs domain.

NOTE: Control of the preferences in com.apple.SoftwareUpdate and com.apple.storeagent are subject to change by Administrators. If you are managing these settings and another administrator makes a chnage on the localk workstation, Puppet will revert the change, but they cannot belocked out entirely.

Example:
{% highlight YAML %}
---
managedmac::softwareupdate::catalog_url: http://my.reposado.com/reposado/html/content/catalogs/index.sucatalog
managedmac::softwareupdate::automatic_update_check: true
managedmac::softwareupdate::auto_update_apps: true
managedmac::softwareupdate::automatic_download: false
managedmac::softwareupdate::config_data_install: false
managedmac::softwareupdate::critical_update_install: false
{% endhighlight %}

For a complete list of parameters, see the [managedmac::softwareupdate](https://github.com/dayglojesus/managedmac/blob/master/manifests/softwareupdate.pp) documentation.

---
<a id="managedmac::sshd"></a>
#### managedmac::sshd

Controls SSHD ACL (com.apple.access_sshd) and and service options.

If you need to augment the service with extra configuration files, you can local paths or puppet:/// style UNC paths.

Example:

{% highlight YAML %}
---
managedmac::sshd::enable: true
managedmac::sshd::sshd_config: puppet:///modules/your_module/sshd_config
managedmac::sshd::sshd_banner: puppet:///modules/your_module/sshd_banner
managedmac::sshd::users:
   - leela
   - bender
managedmac::sshd::groups:
   - robotmafia
{% endhighlight %}

For a complete list of parameters, see the [managedmac::sshd](https://github.com/dayglojesus/managedmac/blob/master/manifests/sshd.pp) documentation.

---
### Raw Constructors

Raw constructors are a special group of classes. They leverage Puppet's builtin [`create_resources`](http://docs.puppetlabs.com/references/latest/function.html#createresources) function to enable you to add new resources without authoring any Puppet code.

To create new resources, you simply pass in data as per the Core Classes.

The provides a simple way to extend the managedmac module without resorting to forking, editing or modifying the existing code.

---
<a id="managedmac::execs"></a>
#### managedmac::execs

Create new Puppet Exec resources.

Example:

{% highlight YAML %}
---
managedmac::execs::commands:
  who_dump:
    command: '/usr/bin/who > /tmp/who.dump'
  ps_dump:
    command: '/bin/ps aux > /tmp/ps.dump'
{% endhighlight %}

For a complete list of parameters, see the [managedmac::execs](https://github.com/dayglojesus/managedmac/blob/master/manifests/execs.pp) documentation.

---
<a id="managedmac::files"></a>
#### managedmac::files

Create new Files.

Example:

{% highlight YAML %}
---
managedmac::files::defaults:
  ensure: file
  owner: root
  group: admin
  mode: 0644
managedmac::files::objects:
  /Users/Shared/example_file_a.txt:
    content: "This is an example of how to create a file using the content parameter."
  /Users/Shared/example_file_b.txt:
    source: puppet:///modules/my_module/example_file_b.txt
  /Users/Shared/example_directory:
    ensure: directory
    owner: root
    group: admin
    mode: 0755
{% endhighlight %}

For a complete list of parameters, see the [managedmac::files](https://github.com/dayglojesus/managedmac/blob/master/manifests/files.pp) documentation.

---
<a id="managedmac::groups"></a>
#### managedmac::groups

Create new OS X user groups.

Example:

{% highlight YAML %}
---
managedmac::groups::defaults:
  ensure: present
managedmac::groups::accounts:
  foo_group:
    gid: 998
    users:
      - foo
      - bar
  bar_group:
    gid: 999
    nestedgroups:
      - foo_group
{% endhighlight %}

For a complete list of parameters, see the [managedmac::groups](https://github.com/dayglojesus/managedmac/blob/master/manifests/groups.pp) documentation.

---
<a id="managedmac::mobileconfigs"></a>
#### managedmac::mobileconfigs

Create new OS X profiles.

Example:

{% highlight YAML %}
---
managedmac::mobileconfigs::defaults:
  description:  'Installed by Puppet.'
  organization: 'Puppet Labs'
managedmac::mobileconfigs::payloads:
  'managedmac.dock.alacarte':
    content:
      largesize: 128
      orientation: left
      tilesize: 128
      autohide: true
      PayloadType: 'com.apple.dock'
    displayname: 'Managed Mac: Dock Settings'
{% endhighlight %}

For a complete list of parameters, see the [managedmac::mobileconfigs](https://github.com/dayglojesus/managedmac/blob/master/manifests/mobileconfigs.pp) documentation.

---
<a id="managedmac::propertylists"></a>
#### managedmac::propertylists

Create new OS X Property Lists or Preference domains.

Example:

{% highlight YAML %}
---
managedmac::propertylists::defaults:
  owner: root
  group: wheel
  format: xml
managedmac::propertylists::files:
  '/path/to/a/file.plist':
    content:
      - 'A string.'
      - a_hash_key: 1
      - 42
  '/path/to/another/file.plist':
    content:
      0: 1
      foo: bar
      bar: baz
      an_array:
         - 99
{% endhighlight %}

For a complete list of parameters, see the [managedmac::propertylists](https://github.com/dayglojesus/managedmac/blob/master/manifests/propertylists.pp) documentation.

---
<a id="managedmac::users"></a>
#### managedmac::users

Create new OS X user accounts.

Example:

{% highlight YAML %}
---
managedmac::users::defaults:
  ensure: present
  gid: 20
managedmac::users::accounts:
  foo:
    uid: 505
    iterations: 32786
    password: 4f5942e989e7566955d42421dc4b80c0fa45f6fb2ecbc1026b2183060c8ecbec38582b1a8a6459574ebe1a2d7884d9e8d2a460e8ea3fcf179964a6325a688d7ee7cc60bbb8b8abf252c6a6a799760da0b0fe6e4562f506b2355b03f272580ed9bdbbae55152dfbac066d9c62a799ee184f9904da153a3c20d66657cf3b60d5c8
    salt: 77586e8902d744f650758b402b44e174d7943b10b145c921b3b71affbaf9a32d
  bar:
    uid: 506
    iterations: 32786
    password: a85ea7ce2df74b13be298d6584edbb35558b74616a70e579252416a6b76d0a615c88b7d566280fa5e035e8db7b1a0c4e3ee4b8cd6204652dcb6c89e6e450a60ca7ed0cc9fa545326ca25211e6f600835f50642ab9d407fa30999c68c05b92d9281eff4a66c67f44ed2f8b8eaf8b62283db202bc98e21c0df9a95cf9abb359b69
    salt: 9ab79307a7bfbb293b4f015ae748d227423481bcd4e5801f450697d15fb67144
{% endhighlight %}

For a complete list of parameters, see the [managedmac::users](https://github.com/dayglojesus/managedmac/blob/master/manifests/users.pp) documentation.

