---
layout: default
title: managedmac
---
## What is it?
---
Managedmac is a Puppet module designed to make OS X configuration simple.

You don't need to understand Puppet to use it (though it helps).

Once you've installed the components, all you need to do is create a configuration file and run Puppet.

It's that simple.

<a id="quickstart"></a>
## Quick Start
---
### 1. Install Packages

This setup is suitable for testing and development, not _masterless_ Puppet installations.

<button type="button" class="btn btn-info btn-custom" data-toggle="collapse" data-target="#super-quick">
  Automated Install
</button>
<div id="super-quick" class="collapse">
  <div class="alert  alert-danger" role="alert">
    <span class="glyphicon glyphicon-exclamation-sign" aria-hidden="true"></span>
    This methodology uses bundler and RubyGems to install and configure the system.<br>
    If you have _Puppet_, _Facter_ and _Hiera_ already installed, you may get conflicts using this method.
  </div>

  1. Clone the repo

        git clone https://github.com/dayglojesus/managedmac.git && cd manaagedmac

  2. Run Setup

        sudo rake setup
OR

        sudo rake setup[development]

</div>

A good demonstration of what a _masterless_ Puppet setup might look like.

<button type="button" class="btn btn-success btn-custom" data-toggle="collapse" data-target="#manual-install">
  Manual Install
</button>
<div id="manual-install" class="collapse">

  You need to install the following packages:

  * [Facter](https://downloads.puppetlabs.com/mac/)
  * [Hiera](https://downloads.puppetlabs.com/mac/)
  * [Puppet](https://downloads.puppetlabs.com/mac/)

Install these gems:

      sudo gem install CFPropertyList sqlite3
      sudo puppet module install sfu-managedmac

And create this symlink:

      cd /etc/puppet
      sudo ln -s /etc/hiera.yaml hiera.yaml

</div>


### 2. Create a Configuration

Open your favorite text editor, copy in the YAML below and save it as (requires root):

##### /var/lib/hiera/defaults.yaml

{% highlight YAML %}
---
# Configure the Dock using an OS X profile
managedmac::mobileconfigs::payloads:
  'managedmac.dock.alacarte':
    content:
      largesize: 128
      orientation: 'left'
      tilesize: 128
      autohide: true
      PayloadType: 'com.apple.dock'
    displayname: 'Managed Mac: Dock Settings'
{% endhighlight %}

### 3. Apply a Puppet manifest

Here's a simple Puppet manifest piped into `puppet apply`

    echo "include managedmac" | sudo puppet apply

In addition to changes in the Dock's appearance you should see a new profile named Managed Mac: Dock Settings' appear in System Preferences.

If you delete this profile and run Puppet again, it will re-appear. Try it.

Now, try running this and inspecting the output...

    sudo puppet resource mobileconfig managedmac.dock.alacarte

<br>

## More Documentation
---
The demonstration above provides just one quick example of what can be accomplished. There are hundreds of configurations that can be made.

To learn more about this module and how it works, read the [Overview]({{ site.baseurl }}/overview) and see the documentation on [Custom Types]({{ site.baseurl }}/types) and [Classes]({{ site.baseurl }}/classes).

