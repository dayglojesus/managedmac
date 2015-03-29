---
layout: types
title: Custom Types
---
## Custom Types

There are a few custom types used in this module. Naturally, once you've installed the module, these types will be available to use in your own Puppet code if you don't fancy using any of the builtin classes.

---
<a id="Dsconfigad"></a>
### Dsconfigad

The _Dsconfigad_ type abstracts Apple's `/usr/sbin/dsconfigad` utility.

It enables you to bind to an Active Directory domain and manage Apple's builtin Active Directory plugin using Puppet. You will find a nearly identical mapping between`dsconfigad`'s utility's CLI options and the type's attributes -- there are quite a few.

{% highlight Puppet %}
dsconfigad { 'some.domain':
  ensure          => present,
  username        => 'some_user',
  password        => 'a_password',
  computer        => 'some_machine',
  ou              => 'CN=Computers',
  force           => 'enable',
  leave           => 'disable',
  mobile          => 'enable',
  mobileconfirm   => 'disable',
  localhome       => 'enable',
  useuncpath      => 'enable',
  protocol        => 'smb',
  sharepoint      => 'enable',
  shell           => '/bin/zsh',
  uid             => 'uidNumber',
  gid             => 'gidNumber',
  ggid            => 'ggidNumber',
  authority       => 'disable',
  preferred       => 'dc.some.domain',
  groups          => ['SOME_DOMAIN\some_group','SOME_DOMAIN\another_group'],
  alldomains      => 'enable',
  packetsign      => 'disable',
  packetencrypt   => 'allow',
  namespace       => 'require',
  passinterval    => '0',
  restrictddns    => ['en0','en1'],
}
{% endhighlight %}

In cases where the CLI options do not present an opportunity to create an exact mapping, there are some simple conventions to follow...

#### "-no" Flags

Rather than using Boolean-like values, some of the CLI flags use the awkward `-no` modifier flag (ie. '-gid' vs. '-nogid'). The [man page](https://developer.apple.com/library/mac/documentation/Darwin/Reference/ManPages/man8/dsconfigad.8.html) has plenty of details about their use.

In these cases, if you wish to _negate_, _remove_, or _un-do_ a setting, passing the attribute's value as an empty String or Array will do the trick.

##### Strings

Quite a few of the "-no" CLI flags accept Strings.

* uid
* gid
* ggid
* preferred

To remove this kind of configuration you need to pass them an empty String.

Example:

{% highlight Puppet %}
dsconfigad { 'ad.sfu.ca':
  preferred => '',
}
{% endhighlight %}

##### Arrays

There are also a couple of CLI flags that accept comma separated lists. In these cases, you should pass the attribute an empty Array.

* groups
* restrictddns

Example:

{% highlight Puppet %}
dsconfigad { 'some.domain':
  groups => [],
}
{% endhighlight %}

---
<a id="Macauthdb"></a>
### Macuthdb

This is an alternative to the native Puppet _Macauthorization_ type.

If you've used Puppet on your Macs before, you probably know that the builtin type is used for managing authorization not supported under Mavericks because it operates by modifying /etc/authorization.

To workaround this, many folks have been using Puppet Exec statements. This is a satisfactory solution in most cases, but if need more granular control, Macauthdb returns the ability to manage the multitude of settings available in the OS X authdb. It does this by making changes to /var/db/authdb directly.

For those who were using _Macauthorization_, the interface will be very similar.

{% highlight Puppet %}
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
{% endhighlight %}

---
<a id="Macgroup"></a>
### Macgroup

This is an alternative to the native Puppet _Group_ type.

This type was implemented with the express purpose of making nestedgroups (groups-in-groups) possible. The Puppet native type does not support this; _Macgroups_ does. It also has the ability strictly enforce group membership or simply ensure that the defined members are present in the list of users or nestedgroups. This is useful if you don't want group control to be overly rigid.

{% highlight Puppet %}
macgroup { 'foo':
  ensure       => present,
  realname     => 'FooGroup',
  comment      => 'Installed by Puppet',
  users        => ['foo', 'bar', 'baz'],
  nestedgroups => ["ABCDEFAB-CDEF-ABCD-EFAB-CDEF00000050", 'group_two'],
  strict       => true,
}
{% endhighlight %}

#### IMPORTANT:
A word of caution about using _names_ when specifying a `nestedgroup`...

When you provide a list of group names, the _Macgroup_ type will attempt to resolve the record to its associated GeneratedUID. This is IMPORTANT to keep in mind when referring to external node records (ie. LDAP or AD) or ANY record that may not already be resolvable.

If it cannot resolve the record name to GeneratedUID, the _Macgroup_ type will generate a warning and _skip_ configuration of the unresolvable record.

---
<a id="Mobileconfig"></a>
### Mobileconfig

This type is unique to this module and is very much at the center of what it does. It's pretty straightforward.

_Mobileconfig_ is capable of dynamically creating and managing the installation and removal of OS X profiles. Example:

{% highlight Puppet %}
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
{% endhighlight %}

#### NOTE:

Running resource abstraction layer queries such as:

    sudo puppet resource mobileconfig

Does not always return conclusive information.

This limitation is borne of the utility on which it relies, `/usr/bin/profiles`.

`/usr/bin/profiles` cannot faithfully render the contents of an installed profile when:

- Profiles contain Passwords
- Profiles contain MCX
- Profiles contain Embedded Certificates

However, this does not affect the type's idempotence.

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

    sudo puppet resource propertylist /Library/Preferences/com.apple.loginwindow.plist

{% highlight Puppet %}
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
{% endhighlight %}

Example 2:

By default, plist content is managed as a whole. If you only want to manage one or two keys, change the `method` param to `insert`.

{% highlight Puppet %}
$content = { LoginwindowText => 'A message to you, Rudy.' }

propertylist { '/Library/Preferences/com.apple.loginwindow.plist':
  ensure  => present,
  method  => insert,
  content => $content,
}
{% endhighlight %}

Example 3:

Use the `defaults` provider to manage a plist like a preferences domain.

Avoid problems with `cfprefsd` and preference domain synchronization by
setting the provider parameter to :defaults.

{% highlight Puppet %}
$content = { LoginwindowText => 'A message to you, Rudy.' }

propertylist { '/Library/Preferences/com.apple.loginwindow.plist':
  ensure   => present,
  method   => insert,
  content  => $content,
  provider => defaults,
}
{% endhighlight %}

The defaults provider will not write directly to disk. Instead, it uses the /usr/bin/defaults utility to sync the data so that the changes are picked up by cfprefsd.

#### IMPORTANT:

When you use the `defaults` provider, the content property MUST be a Hash (Dictionary) because that is what OS X `defaults` demands. If you attempt to use another primitive, Puppet will raise an exception.

---
<a id="Remotemanagement"></a>
### Remotemanagement

This is a direct port of the remotemanagement type from [x_types](https://github.com/dayglojesus/x_types) with a few improvements.

It basically abstracts the OS X `kickstart` utility and manages user ACLs/permissions.

{% highlight Puppet %}
remotemanagement { 'apple_remote_desktop':
  ensure            => 'running',
  allow_all_users   => false,
  enable_menu_extra => false,
  users             => {'fry' => -1073741569, 'bender' => -2147483646, 'leela' => -1073741822 },
}
{% endhighlight %}

There is a good example of usage in manifests/remotemanagement.pp.
