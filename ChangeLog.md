# Change Log

## 0.4.1
- fix issues #4 and #5
- some clean-up

## 0.4.0
* inital release

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
