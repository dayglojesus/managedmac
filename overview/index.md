---
layout: default
title: How does it work?
---

## Overview
---

Managedmac is comprised of a series of parameterized Puppet classes and custom type/providers. Each class represents a specific group of OS X features or services, but these classes are DORMANT -- that is, they do not apply any changes to the target system until they are activated by:

1. Hiera Data bindings
2. Declaration with parameters

If you are not familiar with the Puppet DSL, no need to worry, this module does not require you to be intimately familiar with Puppet code.

<br>
### Design

Managedmac was designed to be a sort of OS X world-engine.

Once the components are installed, the only thing you need to begin terraforming is a configuration file.

You've already seen this in the [Quick Start!]({{ site.baseurl }}/#quickstart)

The file we created was a Hiera `defaults.yaml` file. In simple terms, Hiera is a Puppet component that allows you to pass data (params) to Puppet classes without using the DSL.

You _can_ use this module without Hiera. Each of the classes and custom types can be used individually, but you can get a lot of value from the module without writing a bunch of Puppet code.

There is a bit of behind-the-scenes magic involved in this. To understand it, you need to know a little bit about Hiera and how it functions to supply parameters to Puppet classes.

<br>
### Data Binding

According to the Puppet Labs site, [Hiera](http://docs.puppetlabs.com/hiera/1/index.html) "is a key/value lookup tool for configuration data". It functions as a database for Puppet from which it can source class parameters.

When you use Puppet v3, Hiera support is builtin -- there's not much you need to do to get it going. To use it effectively, you must understand the relationship between Puppet and Hiera and how it aligns configuration data with classes based on *namespace*.

Example:

Amongst the numerous classes in this module is one named...

    managedmac::ntp

This is its namespace. The class takes two parameters...

{% highlight Puppet %}
class managedmac::ntp (

  $enable  = undef,
  $servers = ['time.apple.com']

) {
  ...
}
{% endhighlight %}

As a result, a Hiera configuration for this class would look like this...

{% highlight YAML %}
---
managedmac::ntp::enable: true
managedmac::ntp::servers:
  - time.apple.com
  - time1.google.com
{% endhighlight %}

The alignment of namespaces between Puppet and Hiera is referred to as _data binding_.

This pattern holds for the remainder of classes in the module.

Example:

{% highlight YAML %}
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
{% endhighlight %}

So, without writing a line of Puppet code, we can actually make this data available to Puppet thanks to Hiera.

<br>
### Hiera Powered

If you are thinking to yourself, "This Hiera data looks a lot like the Puppet declaration syntax", you are right.

So, why would you use it? Here's a simplistic example...

Normally, when you wish to declare a Puppet class and pass it some parameters, you need to create a Puppet manifest, like this...

{% highlight Puppet %}
class { 'managedmac::screensharing':
  enable => true,
  users  => ['bender', 'fry']
}
{% endhighlight %}

Okay, that's easy enough and now you can apply that to all your machines.

But wait... What if there's a few machines you need to configure differently? You'd need to create a separate manifest for those machines.

Okay, still tenable? What if there were more differences? What if you needed to devise a strategy for creating different roles for different machines?

* desktop (staff)
* desktop (staff, finance)
* desktop (student, labs)
* laptop (student, library)
* laptop (staff)
* etc.

At what point does creating a new manifest or module for each role become unwieldy?

The real problem with this type of setup is that you TRAP configuration data in the code. So, rather than your Puppet code being simply transformative, it is also the source of configuration data. This can lead to all kinds of awkward code organization in the long run.

Hiera was conceived to address this. For one thing, Hiera can source multiple data stores to come up with an authoritative set of configuration options for any host or group of hosts. It also has the ability to fallback to using defaults in the absence of either of these.

Example:

Five files in the Hiera database, all contain the same variable...

##### /var/lib/hiera/myhost.foo.com.yaml
{% highlight YAML %}
---
managedmac::organization: 'My Organization - Local'
{% endhighlight %}

##### /var/lib/hiera/development.yaml
{% highlight YAML %}
---
managedmac::organization: 'My Organization - Development'
{% endhighlight %}
##### /var/lib/hiera/production.yaml
{% highlight YAML %}
---
managedmac::organization: 'My Organization - Production'
{% endhighlight %}

##### /var/lib/hiera/defaults.yaml
{% highlight YAML %}
---
managedmac::organization: 'My Organization - Defaults'
{% endhighlight %}

##### /var/lib/hiera/global.yaml
{% highlight YAML %}
---
managedmac::organization: 'My Organization - Global'
{% endhighlight %}

When you apply the Puppet configuration to _my_host.foo.com_, which value will it get?

Answer: _it all depends on how you have setup your hierarchy._

Hiera will assess the variables based on a strategy you define. The default configuration specifies:

{% highlight YAML %}
---
:hierarchy:
  - defaults
  - "%{clientcert}"
  - "%{environment}"
  - global
{% endhighlight %}

A complete overview of Hiera is beyond the scope of this document. If you want to learn more about how to use Hiera to add flexibility to your Puppet setup, [Puppet Labs has mounds of documentation that will get you started](http://docs.puppetlabs.com/hiera/1/).

NOTE: All the example data you've seen so far has been [YAML](http://www.yaml.org) encoded, but Hiera can handle other data formats as well.
