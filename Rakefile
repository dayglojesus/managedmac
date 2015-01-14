require 'rake'
require 'yaml'
require 'fileutils'
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
task :setup => [
  :install_hooks,
  :bundle_install,
  :install_modules,
  :prep_hiera,
  :spec_prep,
]

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

task :bundle_install do
  system "bundle", "install"
end

task :install_modules do
  this_module = File.dirname(File.expand_path(__FILE__))
  the_symlink = '/private/etc/puppet/modules/managedmac'
  system "puppet", "module", "install", "puppetlabs-stdlib"
  unless File.exists?(the_symlink) and File.symlink?(the_symlink)
    Dir.chdir File.dirname(the_symlink)
    FileUtils.ln_s this_module, File.basename(the_symlink)
    Dir.chdir this_module
  end
end

task :prep_hiera do
  # Hiera config
  hiera_config = {
    :backends   =>  ["yaml"],
    :logger     =>  "console",
    :hierarchy  =>  ["defaults"],
    :yaml       =>  { :datadir => "/var/lib/hiera" },
  }
  hiera_config_path = '/private/etc/hiera.yaml'
  puts "Installing #{hiera_config_path}..."
  unless File.exists? hiera_config_path
    File.write(hiera_config_path, hiera_config.to_yaml)
  end

  # Hiera YAML hierarchy
  hiera_lib_dir  = '/private/var/lib/hiera'
  hiera_defaults = '/private/var/lib/hiera/defaults.yaml'
  puts "Installing #{hiera_lib_dir}..."
  FileUtils.mkdir_p hiera_lib_dir unless File.exists? hiera_lib_dir
  FileUtils.touch hiera_defaults  unless File.exists? hiera_lib_dir
end

# Jim Weirich died today
task :thanks_Jim do
  puts "I <3 Rake. Thanks, Jim."
end