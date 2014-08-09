---
layout: default
title: creating-users
---

## Fun With Raw Constructors

---
### Creating Users

Creating user accounts is probably one of the most common tasks you'll need to perform.

Puppet is awesome at managing local user accounts. It makes it trivial to create local administrators and keep passwords rotated on a regular basis.

The easiest method for creating a user with Puppet, is to use the `puppet resource` utility, copy the output and transpose it into Hiera data.

##### Step One: Use Puppet to Create a User Account

Open Terminal, type in this command and enter your password when requested:


    sudo puppet resource user foo ensure=present uid=999

##### Step Two: Set a Password for "foo"

Run this command, give the user a password and confirm it.

    sudo passwd foo

##### Step Three: Dump the User

Enter this command:

    sudo puppet resource user foo

You should get some output:

{% highlight Puppet %}
user { 'foo':
  ensure     => 'present',
  comment    => 'foo',
  gid        => '20',
  home       => '/Users/foo',
  iterations => '29239',
  password   => 'dba31340c6885e92ca8ce643d05a9ea32f4035a3871e007fa74bee649576be284b535299694d14c8bcbb501fc19649d94bcad520f25adbebf9022daceeae22d5cf5ef9f6fe4b2d5e55bc9024a4d381787e8f7b32a1ec627f7b95a6975657f702473809905f6d992d68971ae788304f87ee4c0a85297e26ba625f52cf8656d625',
  salt       => 'e924361df3b9d9453cb138f0dbf22f8697eb82939d65e9629277cbf681d0c52a',
  shell      => '/bin/bash',
  uid        => '999',
}
{% endhighlight %}

##### Step Four: Transpose the Puppet Resource

All that's left to do is transpose the output and create a Raw Constructor, but what you have to realize, is that we can name the user account whatever we want. We can also change any of the other attributes to meet our final requirements.

The real reason for jumping through hoops 1-3 was to get the Password data, which is complicated to construct manually. OS X Passwords are actually composed of 3 different attributes: `salt`, `iterations`, `password`. You need ALL of them to successfully set a user password.

{% highlight YAML %}
---
# Let's give this user admin access
# Note: we can omit the ensure => present because that's Puppet's default
# when declaring a resource.
managedmac::users::accounts:
  myadmin:
    uid: 999
    gid: 80
    home: '/Users/myadmin'
    comment: 'My Local Administrator Account'
    shell: '/bin/zsh'
    salt: 'e924361df3b9d9453cb138f0dbf22f8697eb82939d65e9629277cbf681d0c52a'
    iterations: 29239
    password: 'dba31340c6885e92ca8ce643d05a9ea32f4035a3871e007fa74bee649576be284b535299694d14c8bcbb501fc19649d94bcad520f25adbebf9022daceeae22d5cf5ef9f6fe4b2d5e55bc9024a4d381787e8f7b32a1ec627f7b95a6975657f702473809905f6d992d68971ae788304f87ee4c0a85297e26ba625f52cf8656d625'
{% endhighlight %}

What if you want to add more than one user? Simple: add another user to the `managedmac::users::accounts` Hash...

{% highlight YAML %}
---
managedmac::users::accounts:
  user_a:
    uid: 1001
  user_b:
    uid: 1002
  user_c:
    uid: 1003
{% endhighlight %}

NOTE: If you want to delete the user 'foo' when you are done, do so with the following command:

    sudo puppet resource user foo ensure=absent

##### Step Five: Password Rotation

Let's say you need to change the password for `myadmin`. Extrapolate...

    sudo passwd someaccount
    sudo puppet resource user someaccount

Now, just copy and paste the values for `salt`, `iterations`, `password` into your Hiera configuration and you are done.

You can actually do this with any account on the system, even your own if you don't mind changing it back afterward.
