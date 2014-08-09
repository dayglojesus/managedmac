<!-- ---
layout: default
title: creating-propertylists
---
 -->
## Fun With Raw Constructors

---

### Creating Propertylists

Why create Propertylists? If you are reading this, you are probably interested in controlling OS X Preferences in a global or a user domain.

You are entering a world of pain. Sorry.

With the advent of [`cfprefsd`](https://developer.apple.com/library/mac/documentation/Darwin/Reference/Manpages/man8/cfprefsd.8.html), there are serious challenges to managing OS X preferences. Where once managing preferences was as simple as changing a  file-on-disk, we are now relegated to forcibly restarting cfprefsd in order to sync defaults.

Indeed, apart from this technique being overkill, it also not entirely reliable. Sometimes, sending a HUP to `cfprefsd` is simply not enough.

For example, if you attempt to modify preferences for a running application, you may simply find yourself spinning your wheels. Sure, you can write the preferences -- the file will gladly accept your changes -- but when the app quits, the modifications you make may simply be overwritten or destroyed.

So, why create Propertylists?

Sometimes, that's all you have. In such cases, you can use the [managedmac::propertylists]({{ site.baseurl }}/classes/#managedmac::propertylists) raw constructor. Your success will vary according to *how and when* you attempt to use it.

#### Important Details

Before you get started, there are few key things to know:

1. *Global domains typically respond better than User domains*

    Controlling user preferences is straightforward if the user is not logged in. However, if the user is active, you may not get the results you expect. Like the example provided in the preamble, if the preferences are loaded by their associated applications, they will likely overwrite any changes you've made when they are terminated. Conversely, preferences in the global domain seem to accept modifications more readily, though there are no guarantees.

2. *You need to use the `defaults` provider*

    By default, the [Propertylist]({{ site.baseurl }}/types/#Propertylist) type simply writes your specified changes to disk, treating the target as an ordinary file. If you are attempting to manage a preference domain, you need to supply a special parameter to tell the type to use `/usr/bin/defaults` to save the configuration.

    There will be ample demonstrations of this in the examples that follow.

3. *If you don't want to mange the entire domain, use `insert` mode*

    There are two *modes* in the [Propertylist]({{ site.baseurl }}/types/#Propertylist) type: `replace` and `insert`.

    The default mode is `replace`. However, if you do not wish to manage the entire set of preferences for a given domain, you need to set the mode explicitly to `insert`.

    You will see this parameter supplied in the examples below.

#### A Simple Example


















