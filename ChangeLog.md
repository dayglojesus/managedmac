# ChangeLog: managedmac

---

_Use cmd+ctl+opt+P to activate the Markdown Viewer in TextMate._<br>
_Use ^H to display Markdown Cheat Sheet._

---

## Version Branch: 0.0.1
- started creating specs and getting the fundamentals in order
- adjusted gem requirements
- added rake setup
- added support for using hiera fixtures
- added a development guideline

## Initial Setup:

- install TextMate
  * install the command line
  * install puppet bundle
  * install rspec bundle
  * install yaml bundle
  * configure preferences to taste
- sudo gem install bundle
- puppet module generate sfu-managedmac
- cd sfu-managedmac/
- bundle init
- mate .
  * edit Gemfile to include our dependencies
  * replace the “# gem ‘rails’” line with:
  
    <pre>
      <code>
          group :development do
            gem “rake”
            gem "rspec-puppet”
            gem “puppet-lint”
            gem “puppetlabs_spec_helper"
          end
      </code>
    </pre>
- rm spec/spec_helper.rb 
- rspec-puppet-init
- git init
- touch .gitkeep in all empty directories
        `find spec -empty -type d -exec touch {}/.gitkeep \;`
- edit Rakefile and add...

        `require 'puppetlabs_spec_helper/rake_tasks'`
- edit spec/spec_helper.rb and add...

        `require ‘puppetlabs_spec_helper/module_spec_helper’`
- add new file “.fixtures.yaml”
  * as per http://puppetlabs.com/blog/the-next-generation-of-puppet-module-testing
  
  <pre>
    <code>
        fixtures:
          repositories:
            stdlib: git://github.com/puppetlabs/puppetlabs-stdlib.git
          symlinks:
          managedmac: "#{source_dir}"
    </code>
  </pre>
- add new file “spec/spec.opts” with contents

        `--color --format d`
- git add .
- git ci -m “Initial Commit”
- create the bare repo on radmind.sfu.ca
  * ssh git@radmind
  * cd /repo
  * mkdir sfu-managedmac.git
  * cd sfu-managedmac.git && git init —bare
- git remote add origin ssh://git@radmind.sfu.ca/repo/sfu-managedmac.git
- git push -f origin master

## Resources

- http://puppetlabs.com/blog/the-next-generation-of-puppet-module-testing
- http://rspec-puppet.com/matchers/
