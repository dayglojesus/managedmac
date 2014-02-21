# Development Guidelines

## Requirements

- OS X Mavericks
- Xcode Commandline Tools
- [puppet >= 3.4.0](http://downloads.puppetlabs.com/mac/puppet-3.4.0.dmg)
- [facter >= 1.74](http://downloads.puppetlabs.com/mac/facter-1.7.4.dmg)
- [hiera >= 1.3.1](http://downloads.puppetlabs.com/mac/hiera-1.3.1.dmg)

This module also requires several gems as well as some Puppet Modules from the forge to do what it does -- they are all listed below. If you follow the instructions in _Getting Setup_, you don't need to worry about these...

If you want to know what they are, see the Appendix.

## Getting Setup...

#### 1. TextMate

The use of TextMate is reccommended.

- [install the latest TextMate](http://macromates.com/download)
- install the following code bundles:
	- YAML
	- Puppet
	- RSpec

#### 2. Install Bundler

    sudo gem install bundler

#### 3. Setup

- Open Terminal
- `cd` into the repo
- run:
	- `sudo bundle install`
	- `rake setup`

## Guidelines

### Git

#### Versioning

We are using Semantic Versioning in this module. Please ensure you conform to this basic outline.

#### Branching

Git branching guidelines are loose, but you should know the difference between a _Feature_ branch and a _Release_ branch.

Employ these as required and do not abuse them. Here is a quick read on the subject...

[A successful Git branching model](http://nvie.com/posts/a-successful-git-branching-model/)

One more thing... _NEVER under any circumstances should you be editing in the master branch_.

#### Merging

Before you merge a _Release_ branch, make sure it is properly tagged.

When merging always use: 

    git merge --no-ff

#### Pushing

When you are pushing _Release_ branches, always make sure you push your tags with `--tags`.

#### Commiting and Puppet Style

When you are editing, follow the adage of: "Commit Early, commit often."

Smaller more frequent commits are more useful and easier to rollback.

Likewise, please avoid generating commits that span multiple files unless they are absolutley required.

Just use common sense and good habits.

#### Puppet Style

Your intended commits will be scrutinized using puppet-lint before you commit by way of a Git pre-commit hook. If puppet-lint finds a style error in your manifests, the commit will be aborted and an alert produced.

### Integration Testing with RSpec

When you are developing code for this module, you should be writing integration tests in RSpec. The entire toolchain for doing this is at your disposal.

Breaking it down, at a bare minumum you should be writing a spec for every class you produce and following the RED-GREEN-REFACTOR pattern during development. Every class spec should include:

- a compilation test
- parameter assignment tests
- edge case testing

There is no definitive method for performing all of these, but there will be plenty of examples of how to get most of it. Testing Puppet with RSpec integration tests is not exhaustive, but we should be aiming for a mimimum of 25% coverage.

### No Data in Modules

Our goal is to achieve 100% NO DATA in this module. This means there will be no default values hard coded into the module. If you find yourself needing to add data, stop and consult with the other developers.

We should be able to achieve this. Moreover, by using Hiera data fixtures in your specs, you will be able to mock out what data should be passed into the Puppet code, and come up with some reliable tests to ensure its appropriate.

#### stdlib validate_*

When adding parameters to Puppet classes, be sure that you use the puppetlabs/stdlib's validate_* functions.

### Puppet Style

You should endeavour to follow the Puppet Style guidelines. This style will be enforced by the pre-commit hook. If you want to check your manifests for mistakes you can run `puppet-lint` against your .pp file, you run the rake task:

    cd sfu-managedmac
	rake lint

### Editing with TextMate

TextMate has support for running RSpec tests, code completion, and syntax highlighting when you install the RSpec bundle.

It can also handle the majority of basic Git operations you'll require while editing. After you get used to using Git in TM, you will be able to work quite quickly.


### Changelog

Please ensure you update the changelog when you merge Feature branches into a Release.

## Appendix

#### Required Gems
- rake (10.1.1)
- diff-lcs (1.2.5)
- hiera-puppet-helper (2.0.1) from git://github.com/mmz-srf/hiera-puppet-helper.git (at master)
- metaclass (0.0.2)
- mocha (1.0.0)
- puppet-lint (0.3.2)
- rspec-core (2.14.7)
- rspec-expectations (2.14.5)
- rspec-mocks (2.14.5)
- rspec (2.14.1)
- rspec-puppet (1.0.1)
- puppetlabs\_spec\_helper (0.4.1)
- bundler (1.5.3)

#### Required Puppet Modules
- puppetlabs-stdlib
