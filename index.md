---
layout: default
title: managedmac
---

## What is it?

Managedmac is a module designed to make using Puppet to configure OS X simple.

You don't need to understand Puppet to use it (though it helps).

Once you've installed the components, all you need to do is create a configuration file and run Puppet.

It's that simple.

---
<a id="quickstart"></a>
## Quick Start

### 1. Install Packages

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

### 2. Create a Configuration

Open your favorite text editor, copy in the YAML below and save it as (requires root):

##### /var/lib/hiera/defaults.yaml

    ---
    # Configure the Dock using an OS X profile
    managedmac::mobileconfigs::payloads:
      'managedmac.dock.alacarte':
        content:
          largesize: 128
          orientation: left
          tilesize: 128
          autohide: true
          PayloadType: 'com.apple.dock'
        displayname: 'Managed Mac: Dock Settings'

### 3. Apply a Puppet manifest

Here's a simple Puppet manifest piped into `puppet apply`

    echo "include managedmac" | sudo puppet apply

In addition to changes in the Dock's appearance you should see a new profile named Managed Mac: Dock Settings' appear in System Preferences.

If you delete this profile and run Puppet again, it will re-appear. Try it.

Now, try running this and inspecting the output...

    sudo puppet resource mobileconfig managedmac.dock.alacarte

---
## More Documentation

The demonstration above provides just one quick example of what can be accomplished. There are hundreds of configurations that can be made.

To learn more about this module and how it works, read the [Overview](/overview) and see the documentation on [Custom Types](/types) and [Classes](/classes).

