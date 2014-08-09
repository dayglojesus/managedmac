---
layout: default
title: creating-mobileconfigs
---

## Fun With Raw Constructors

---

### Creating Mobileconfigs

Managedmac allows you to set a lot of different policy, but there may be times when you may need to control something not defined in the module. Adding policy through the use of custom OS X profiles can be accomplished using the `managedmac::mobileconfigs` class.

You may have already seen one example of its usage in the [Quick Start!]({{ site.baseurl }}/#quickstart) where we used this class to manipulate the Dock, but many more things are possible.

Let's begin by looking at basic profile, take stock of what is relevant, and see what we can do...

##### Basic Profile for Managing Finder:

{% highlight XML %}
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>PayloadIdentifier</key>
	<string>my.org.finder.alacarte</string>
	<key>PayloadRemovalDisallowed</key>
	<true/>
	<key>PayloadScope</key>
	<string>System</string>
	<key>PayloadType</key>
	<string>Configuration</string>
	<key>PayloadUUID</key>
	<string>101e14ad-77e2-443e-98a8-eab4d4ceb096</string>
	<key>PayloadOrganization</key>
	<string>My Organization</string>
	<key>PayloadVersion</key>
	<integer>1</integer>
	<key>PayloadDisplayName</key>
	<string>My Organization: Finder Settings</string>
	<key>PayloadContent</key>
	<array>
		<dict>
			<key>PayloadType</key>
			<string>com.apple.finder</string>
			<key>PayloadVersion</key>
			<integer>1</integer>
			<key>PayloadIdentifier</key>
			<string>my.org.finder.alacarte.cf7904ed-4cfd-49fa-8469-17bdfd117e95</string>
			<key>PayloadEnabled</key>
			<true/>
			<key>PayloadUUID</key>
			<string>cf7904ed-4cfd-49fa-8469-17bdfd117e95</string>
			<key>PayloadDisplayName</key>
			<string>Finder</string>
			<key>InterfaceLevel</key>
			<string>Full</string>
			<key>ShowHardDrivesOnDesktop</key>
			<true/>
			<key>ShowExternalHardDrivesOnDesktop</key>
			<true/>
			<key>ShowRemovableMediaOnDesktop</key>
			<true/>
			<key>ShowMountedServersOnDesktop</key>
			<true/>
			<key>ProhibitConnectTo</key>
			<false/>
			<key>ProhibitEject</key>
			<false/>
			<key>ProhibitBurn</key>
			<false/>
			<key>ProhibitGoToFolder</key>
			<false/>
		</dict>
		<dict>
			<key>PayloadType</key>
			<string>com.apple.loginwindow</string>
			<key>PayloadVersion</key>
			<integer>1</integer>
			<key>PayloadIdentifier</key>
			<string>my.org.finder.alacarte.819211c9-65fd-4e58-aa98-69d2f021e752</string>
			<key>PayloadEnabled</key>
			<true/>
			<key>PayloadUUID</key>
			<string>819211c9-65fd-4e58-aa98-69d2f021e752</string>
			<key>PayloadDisplayName</key>
			<string>Finder</string>
			<key>RestartDisabledWhileLoggedIn</key>
			<false/>
			<key>ShutDownDisabledWhileLoggedIn</key>
			<false/>
		</dict>
	</array>
</dict>
</plist>
{% endhighlight %}

Okay, that's a lot of information, so let it soak in. If we were to ask ourself, "What is the essence of this profile?", we might break it down like this...

* we have two Payloads in the PayloadContent array
* each Payload is a dictionary
* one payload manages policy in the `com.apple.finder` preference domain
* the other manages policy in the `com.apple.loginwindow` domain
* the remaining information describes the profile

If that's all it is, then only a few parts of this document are relevant to accomplishing our goal. XML is verbose and many of the key/value pairs above are repeated with small variations, PayloadUUID, PayloadDescription, etc. The important bits are the keys/values that control the settings you want applied.

One of the cool things about the Mobileconfig type, is its ability to cut to the chase. It only asks you to specify what is absolutely required, the rest of the information OS X needs to create a valid profile is synthesized for you.

This means we can reduce the code required to manage these settings and dispense with the noise.

##### Transposed to Hiera:

{% highlight YAML %}
---
# Configure the Finder using an OS X profile
managedmac::mobileconfigs::payloads:
  'my.org.finder.alacarte':
    displayname: 'My Organization: Finder Settings'
    content:
      - PayloadType:                    'com.apple.finder'
        InterfaceLevel:                 'Full'
        ShowHardDrivesOnDesktop:         true
        ShowExternalHardDrivesOnDesktop: true
        ShowRemovableMediaOnDesktop:     true
        ShowMountedServersOnDesktop:     true
        ProhibitConnectTo:               false
        ProhibitEject:                   false
        ProhibitBurn:                    false
        ProhibitGoToFolder:              false
      - PayloadType:                    'com.apple.loginwindow'
        RestartDisabledWhileLoggedIn:   false
        ShutDownDisabledWhileLoggedIn:  false
{% endhighlight %}

And that's all... Not only have we reduced ~75 lines to ~20, we've increased readability and reduced the chance we'll make a mistake the next time we edit it. Not bad!

So, that takes care of the Finder. *What if we want to add some other policy?*

All we need to do is stack the `managedmac::mobileconfigs::payloads` Hash with more resources:

{% highlight YAML %}
---
# Configure:
# 1. Finder (my.org.finder.alacarte)
# 2. Dock (my.org.dock.alacarte)
# 3. iCloud Documents (.GlobalPreferences)
managedmac::mobileconfigs::payloads:
  'my.org.finder.alacarte':
    displayname: 'My Organization: Finder Settings'
    content:
      - PayloadType:                    'com.apple.finder'
        InterfaceLevel:                 'Full'
        ShowHardDrivesOnDesktop:         true
        ShowExternalHardDrivesOnDesktop: true
        ShowRemovableMediaOnDesktop:     true
        ShowMountedServersOnDesktop:     true
        ProhibitConnectTo:               false
        ProhibitEject:                   false
        ProhibitBurn:                    false
        ProhibitGoToFolder:              false
      - PayloadType:                    'com.apple.loginwindow'
        RestartDisabledWhileLoggedIn:   false
        ShutDownDisabledWhileLoggedIn:  false
  'my.org.dock.alacarte':
    displayname: 'My Organization: Dock Settings'
    content:
      PayloadType: 'com.apple.dock'
      largesize: 128
      orientation: left
      tilesize: 128
      autohide: true
  'my.org.mcx.alacarte':
    displayname: 'My Organization: Custom MCX'
    description: 'Turns off iCloud as the default save location'
    content:
      - PayloadType: 'com.apple.ManagedClient.preferences'
        PayloadContent:
            .GlobalPreferences:
              Set-Once:
              - mcx_data_timestamp: 2013-10-29 11:16:05.000000000 -07:00
                mcx_preference_settings:
                  NSDocumentSaveNewDocumentsToCloud: false
{% endhighlight %}

And we can also set some defaults for the profiles:

    ---
    # Set the PayloadOrganization key for listed profiles
    managedmac::mobileconfigs::defaults:
      organization: My Organization

##### Complex Hiera Structures

Like the XML we are abstracting, the YAML or JSON you create for Hiera can get fairly complicated. Constructing the various nested structures can be a bit tricky, especially those that contain embedded MCX like the `my.org.mcx.alacarte` payload above.

To make authoring content for this Raw Constructor class a bit easier, you can use the supplied script, `profile2hiera`.

    /etc/puppet/modules/managedmac/files/profile2hiera /path/to/a/profile.mobileconfig

The default output format is YAML, the same format used in this documentation, but it will also produce JSON:

    /etc/puppet/modules/managedmac/files/profile2hiera -f json /path/to/a/profile.mobileconfig

You can pass it as many profiles as wish, or even a glob:

    /etc/puppet/modules/managedmac/files/profile2hiera profile_a.mobileconfig profile_b.mobileconfig
    /etc/puppet/modules/managedmac/files/profile2hiera *.mobileconfig

