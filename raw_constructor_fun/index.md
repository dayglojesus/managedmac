---
layout: default
title: fun-with-raw-constructors
---

## Fun With Raw Constructors

---

### Overview

Raw Constructors allow you to compose Puppet resources using Hiera data.

There's nothing spectacular about this -- many administrators use this simple technique. It relies on the builtin Puppet function `create_resources`. If you haven't looked the documentation for [create_resources](http://docs.puppetlabs.com/references/latest/function.html#createresources), it's a quick read and it will allow you to better understand how Raw Constructors work.

It also helps to have a good understanding of the various [Puppet Types](http://docs.puppetlabs.com/references/latest/type.html) available and how they operate.

There aren't Raw Constructors for every Puppet type, just enough to cover the basics. Still, they're fairly convenient and allow you to add resources to the Puppet catalog without resorting to creating extra manifests.

---

### How-tos

#### [The Basics]({{ site.baseurl }}/raw_constructor_fun/basics.html)
#### [Creating Users]({{ site.baseurl }}/raw_constructor_fun/creating_users.html)
#### [Creating Mobileconfigs]({{ site.baseurl }}/raw_constructor_fun/creating_mobileconfigs.html)
#### [Creating Propertylists]({{ site.baseurl }}/raw_constructor_fun/creating_propertylists.html)






