---
layout: default
title: basics
---

## Fun With Raw Constructors

---
### The Basics

Each Raw Constructor class follows a similar pattern and *accepts a pair of Hashes as parameters*.

* The first Hash is for specifying the _list_ of resources you want to create.
* The second Hash provides a series of default values to each resource in the first Hash.

Read that again. The first Hash is a list; the second augments the list.

The Hashes can be composed in any order. Here we specify the `defaults` hash first...

Example:

{% highlight YAML %}
---
# The defaults Hash
managedmac::execs::defaults:
  path: /bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin
# The resource list Hash
managedmac::execs::commands:
  file_a:
    command: 'touch /tmp/file_a'
  file_b:
    command: 'touch /tmp/file_b'
  file_c:
    command: 'touch /tmp/file_c'
{% endhighlight %}

The YAML above defines 3 unique Puppet Exec resources, composed of two Hashes:

* managedmac::execs::defaults
* managedmac::execs::commands

The first Hash has one key, `path`, whose value is a String.

The second Hash has *three keys*, each in the form of:

{% highlight YAML %}
resource_name:
  command: 'some_command'
{% endhighlight %}

The thing to understand here is that each of the Hashes in the `managedmac::execs::commands` *inherit* the `path` key from the `managedmac::execs::defaults` Hash.

So, in the end, the `defaults` Hash is simply a way of refactoring. Consider this equivalent example:

{% highlight YAML %}
---
# The resource list Hash
managedmac::execs::commands:
  file_a:
    path: /bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin
    command: 'touch /tmp/file_a'
  file_b:
    path: /bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin
    command: 'touch /tmp/file_b'
  file_c:
    path: /bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin
    command: 'touch /tmp/file_c'
{% endhighlight %}

This is a contrived example, but any parameters you can pass to a [Puppet Exec resource](http://docs.puppetlabs.com/references/latest/type.html#exec-attributes), can be specified in the Hiera data. Here is a more detailed example:

{% highlight YAML %}
---
# Dump the process table to a file
managedmac::execs::commands:
  dump_proc_table:
    path: /bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin
    creates: '/tmp/proc_table.txt'
    command: 'ps aux > /tmp/proc_table.txt'
    returns: 0
    logoutput: on_failure
{% endhighlight %}