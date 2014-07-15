require 'rake'
require 'rspec/core/rake_task'
require 'puppetlabs_spec_helper/rake_tasks'

desc "Run all RSpec code examples"
RSpec::Core::RakeTask.new(:rspec) do |t|
  t.rspec_opts = File.read("spec/spec.opts").chomp || ""
end

SPEC_SUITES = (Dir.entries('spec') - ['.', '..','fixtures']).select {|e| File.directory? "spec/#{e}" }
namespace :rspec do
  SPEC_SUITES.each do |suite|
    desc "Run #{suite} RSpec code examples"
    RSpec::Core::RakeTask.new(suite) do |t|
      t.pattern = "spec/#{suite}/**/*_spec.rb"
      t.rspec_opts = File.read("spec/spec.opts").chomp || ""
    end
  end
end
task :default => :rspec

begin
  if Gem::Specification::find_by_name('puppet-lint')
    require 'puppet-lint/tasks/puppet-lint'
    PuppetLint.configuration.ignore_paths = ["spec/**/*.pp", "vendor/**/*.pp"]
    task :default => [:rspec, :lint]
  end
rescue Gem::LoadError
end

desc "Setup the repo's development and testing environment"
task :setup => [:install_hooks, :spec_prep, :bundle_install_again]

# Installs the git-hooks for this repo
task :install_hooks do
  puts "Installing git-hooks..."
  hooks_destination = File.expand_path(File.join(__FILE__, '..', '.git', 'hooks'))
  hooks_source      = File.expand_path(File.join(__FILE__, '..', '.git-hooks'))
  raise "Source directory not found, #{hooks_source}" unless Dir.exists? hooks_source
  unless File.symlink? hooks_destination
    FileUtils.mv hooks_destination, hooks_destination + ".orignal"
    FileUtils.ln_s hooks_source, hooks_destination
  end
  puts "Done."
end

# We need to run `bundle install` twice:
# The first time, we do it manually and we get all the gems from RubyGems.
# The second time, we need do it to get bundler to install the one gem we 
# need from GitHub. It's a long stupid story...
# https://github.com/bundler/bundler/issues/2492
task :bundle_install_again do
  system "bundle", "install"
end

# Jim Weirich died today
task :thanks_Jim do
  puts "I <3 Rake. Thanks, Jim."
end