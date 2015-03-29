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
### 1. Choose Your Setup
<br>
<div>
  <table>
    <tr>
      <td>
        <button type="button" class="btn btn-success btn-custom" data-toggle="collapse" data-target="#super-quick">
          Automated Setup
        </button>
      </td>
      <td>
        <div class="setup-btn-info">
          Suitable for testing and development, not <em>masterless</em> Puppet installations.
        </div>
      </td>
    </tr>
  </table>
</div>

<br>
<div id="super-quick" class="collapse setup-detail">
  <div class="alert  alert-danger" role="alert">
    <span class="glyphicon glyphicon-exclamation-sign" aria-hidden="true"></span>
  This methodology uses bundler and RubyGems to install and configure the system.

  * If Puppet, Facter or Hiera were installed using OS X packages, you may get conflicts using this method.
  * Using RVM? I am about as sure what will happen as you are. :wink:
</div>

#####Clone the repo

If you don't have git, then you'll need to install the Xcode commandline tools: `sudo xcode-select --install`

    git clone https://github.com/dayglojesus/managedmac.git && cd managedmac

#####Run Setup

There are two setups: one for demonstration, one for development.

    sudo rake setup

Running the development setup installs the gems required for running tests, etc.

    sudo rake setup[development]

</div>

<table>
  <tr>
    <td>
      <button type="button" class="btn btn-info btn-custom" data-toggle="collapse" data-target="#manual-install">
        Manual
      </button>
    </td>
    <td>
      <div class="setup-btn-info">
        Demonstration of what a <em>masterless</em> Puppet setup might look like.
      </div>
    </td>
  </tr>
</table>

<br>
<div id="manual-install" class="collapse setup-detail">
#####You need to install the following packages:

  * [Facter](https://downloads.puppetlabs.com/mac/)
  * [Hiera](https://downloads.puppetlabs.com/mac/)
  * [Puppet](https://downloads.puppetlabs.com/mac/)

#####Install these gems:

      sudo gem install CFPropertyList sqlite3
      sudo puppet module install sfu-managedmac

#####And create this symlink:

      cd /etc/puppet
      sudo ln -s /etc/hiera.yaml hiera.yaml
</div>
<br>

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
<br>

### 3. Apply a Puppet manifest

Here's a simple Puppet manifest expressed in `puppet apply`

    sudo puppet apply -t -e 'include managedmac'

In addition to changes in the Dock's appearance you should see a new profile named Managed Mac: Dock Settings' appear in System Preferences.

If you delete this profile and run Puppet again, it will re-appear. Try it.

Now, try running this and inspecting the output...

    sudo puppet resource mobileconfig managedmac.dock.alacarte

<br>

## More Documentation
---
The demonstration above provides just one quick example of what can be accomplished. There are hundreds of configurations that can be made.

To learn more about this module and how it works, read the [Overview]({{ site.baseurl }}/overview) and see the documentation on [Custom Types]({{ site.baseurl }}/types) and [Classes]({{ site.baseurl }}/classes).

