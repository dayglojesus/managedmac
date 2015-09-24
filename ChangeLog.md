# Change Log

## 0.7.3
- IMPORTANT: requires Puppet 3.8.3
- Plenty of bug fixes and make ready the El Capitan
- Refactoring and optimization of some Puppet functions
- Improves AppStore preference controls
- Update specs to run RSpec 3
- Thanks to helge000 for fixing issue #90
- closed: #82, #86, #90, #92, #93

## 0.7.2
- no changes; just need to bump the version so I can submit to the Forge

## 0.7.1
- properly scope the module to Puppet Version 3 only
- reference issues: #80, #81 and #84

## 0.7.0
- closed: #81, #79, #76, #75, #72, #69
- Dsconfigad is now the default provider for the `managedmac::activedirectory` class
- fixes a bug in Macgroup type that was purging members when `strict` was `false`
- updates docs and comments

## 0.6.0
- closed: #56, #63, #64, #66, #67, #68, #71, #73
- new type: Dsconfigad
- new feature: managedmac::activedirectory class has new provider option
- enhancement: manage mobileconfigs that contain embedded certs
- new feature: control the Desktop picture (clburlison)
- several bug fixes and improvements (much credit: clburlison) thanks!

## 0.5.9
- bug fixes for: #3, #54, #58, #59, 60
- fix #59 and #60 are important; you should update
- gem maintenance
- rake task overhauls
- fix failing spec

## 0.5.8
- quick bug fixes for #55 and #57
- fix filevault\_active fact
- fix init.pp

## 0.5.7
- add fact: macaddress_primary
- add raw constructor: cron
- make ntp class idemtpotent
- fix documentation
- bug fixes: #47, #48, #50, #51

## 0.5.6
- overhauled macauthdb provider; still needs a bit of work, but is operating as designed
- allow scoped PHD policy by expanding $enable param to accept version strings
- fix an edge case with ssh service management
- documentation fixes
- bug fixes for issues #37, #38, #41, and #42

## 0.5.5
- release 0.5.5

## 0.5.4
- bug fixes for issues #34, #33, #32, #8, #36

## 0.5.3
- release 0.5.3
- bug fixes for issues #25, #26, #27, #30
- added small utility to convert a profile into Hiera data

## 0.5.1
- release 0.5.1
- update metadata.json and build
- fix issue #24

## 0.5.0
- release 0.5.0
- update metadata.json and build

## 0.4.9
- fix issue #23
- implements com.apple.SoftwareUpdate control AllowPreReleaseInstallation

## 0.4.8
- fixes for issues #21, #19, and 18
- mainly adjusting for changes in Yosemite

## 0.4.7
- fixes issue #20
- Mobileconfig can now handle any kind of profile (in theory)
- mcx.pp now places custom MCX into a profile; no more local MCX
- fix some edges in the #destringify method

## 0.4.6
- bug fixes: #16 and #17

## 0.4.5
- release 0.4.5
- update metadata.json and build

## 0.4.4
- more authorization fixes and enhancements (see log)
- fix issue #11, Mobileconfig#content was failing to process an empty array
- fix issue #6, changed variable name

## 0.4.3
- fix issue #11: merge pull-request from @groob
- fix documentation and add tests
- lock down gem versions

## 0.4.2
- fix issues #10 and #13
- many changes to Mobileconfig, see log for details

## 0.4.1
- fix issues #4 and #5
- some clean-up

## 0.4.0
* initial release

## 0.3.3
* clean-up and organize some documentation in preparation for Github

## 0.3.2
* add documentation to init; make organization configurable
* correct macgroup resource creation and gid checking

## 0.3.1
* update the propertylist resources so that they use the new provider

## 0.3.0
* re-org propertylist type/provider to make room for new provider, :defaults
* :defaults handles preference synching in addition to plist management

## 0.2.9
* many many bug fixes and enhancements, see the log...
* fix issue with macgroup type/provider in which resources would be re-applied on each run if the :strict param was :false

## 0.2.8
* add a sample hiera config detailing the many params for each class
* spec gem requirements and add sqlite3 gem resource

## 0.2.7
* macgroup provider bug fix

## 0.2.6
* refactor classes and re-spec to make them compatible with our plan to contain all classes
* refactor hooks to make them init.pp compatible
* re-spec init.pp with class containment tests
* make energysaver compatible with our plan to contain ALL classes in init.pp

## 0.2.5
* add and refactor some of the raw constructor classes

## 0.2.4
* refactor many classes to use a generic function; rename some others

## 0.2.3
* refactor security class with genericized function for processing params

## 0.2.2
* lots of refactoring to existing classes, bug fixes and additional features

## 0.2.1
* simply rename the class to better identify it's purpose

## 0.2.0
* significant enhancments to the softwareupdate class

## 0.1.9
* complete overhaul of the loginwindow class with added features, including an ACL

## 0.1.8
* refactored the active directory class making all class params explcit

## 0.1.7
* remove the ntp_offset fact and adjust the ntp class accordingly

## 0.1.6
* add service management for sshd and screensharing

## 0.1.5
* implements a new param for the mcx class that will suppress the iCloud setup dialogue for new users

## 0.1.4
* add class mounts and mcx
* mounts handles the mapping of drives at login
* mcx class handles bluetooth, wifi, and miscellaneuous loginitems

## 0.1.3
* adds propertylist type/provider and a raw constructor class for these types of files

## 0.1.2
* add remotemanagement type/provider for Apple Remote Desktop

## 0.1.1
* add class for managing basic security options

## 0.1.0
* adds filevault configurability; needs more testing

## 0.0.9
* add new class for managing portable home directory configurations

## 0.0.8
* add class fro managing sys pref panes

## 0.0.8
* new custom type and provider for managignn the OS X authorization db
* the Puppet builtin type macauthorization is broken in Mavericks

## 0.0.7
* added defined type: hook
* implemented classes loginhook and logouthook

## 0.0.6
* add the first ACL com.apple.access_loginwindow
* more to follow, but time to forge ahead as these are easy to add
* fix ntp_spec; class worked but the spec was brokenp
* not sure how they got out of whack
* bug fixes for macgroup and related method in common.rb
* add a new defined type for working with OS X groups ACLs
* abstracts Macgroup
* add a raw constructor class that builds Macgroup resources from data bindings
* work was begun on a previous brnach but using the built-in Puppet type
* add new custom type/provider for working with OS X Group resources: Macgroup
* Macgroup is a replacement for the built-in Puppet Group type but can handle nestedgroups

## 0.0.5
* Adds support for dynamically creating Mobileconfig resources using params

## 0.0.5
* Add users class that llows user reources to be created from param data

## 0.0.4
* refactor the softwareupdate class to accept a new parameter as per loginwindow
* Add loginwindow class fro controlling com.apple.loginwindow prefs domain
* includes multi-params for overriding $options; we'll be refactoring other classes to use this approach
* Add a primitive class for managing Energy Saver settings via mobileconfig resource
* add class for managing softwareupdate CatalogURL
* Like the activedirectory class, make the ntp class handle an ensure option and act accordingly.
* Also contains a commit that makes the ntp class a conditional requirement for the activedirectory class

## 0.0.3
* Many changes, all in an effort to normalize content and sanitize equality testing on the content parameter. The issues look like they are resolved, but there may be edge cases.
* We now scrub the content array in the Type so that it is normalized when we get around to comparing it with existing values. Likewise, existing values are also scrubbed before the resource is constructed.
* There are also a few bug fixes and additional changes to the activedirectory provider that should simplify content construction and resource management.
* make the content parameter more extensible
* ensure resource checking can accomodate unmanaged keys
* overhaul mobileconfig type and supply two providers: default and activedirectory
* refactor some other things

## 0.0.2
* refactor, comment, clean-up and rename the mobileconfig type/provider
* subclass mobileconfig

## 0.0.1
* initial commit
