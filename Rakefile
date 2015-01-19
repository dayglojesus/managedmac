require 'rake'
require 'yaml'
require 'fileutils'

# These tasks are purely for development
# We load these tasks conditionally. Pre-reqs need to be isntalled first.
begin
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
rescue LoadError
  puts "\n" + "=" * 70
  puts "| WARNING: not loading some tasks because of missing dependencies."
  puts "|  * Run `sudo rake setup` to build the demo environment."
  puts "|  * For development, run: `sudo rake setup[development]`"
  puts (("=" * 70) + "\n\n")
end

desc "Install managedmac and dependencies (requires root): demo or development"
task :setup, :env do |t, args|
  # Check UID (must be root)
  unless Process.euid == 0
    raise "You must be root to execute this script."
  end
  env = args[:env] || 'demo'
  fail "Unknown environment: #{env}" unless env =~ /\A(demo|development)\z/
  Rake::Task[:bundle_install].invoke(env)
  Rake::Task[:install_modules].invoke
  Rake::Task[:prep_hiera].invoke
  Rake::Task[:install_hooks].invoke if env.eql? 'development'
  Rake::Task[:finish].invoke
end

# Install Bundler and run it
task :bundle_install, :env do |t, args|
  env = args[:env] || 'demo'
  unless system("which bundle > /dev/null 2>&1")
    puts "Installing bundler..."
    puts %x{gem install bundler -N}
  end
  env =
  bundler_cmd = %w{bundle install}
  bundler_cmd += %w{--without development test} if args[:env].eql?('demo')
  puts "Running bundler..."
  puts %x{#{bundler_cmd.join(' ')}}
end

# Install the required Puppet modules and link the managedmac module into
# /etc/puppet/modules
task :install_modules do
  this_module = File.dirname(File.expand_path(__FILE__))
  the_symlink = '/private/etc/puppet/modules/managedmac'
  puts "Installing puppetlabs-stdlib ..."
  puts %x{puppet module install puppetlabs-stdlib}
  puts "Linking managedmac into /etc/puppet/modules ..."
  unless File.exists?(the_symlink) and File.symlink?(the_symlink)
    Dir.chdir File.dirname(the_symlink)
    FileUtils.ln_s this_module, File.basename(the_symlink)
    Dir.chdir this_module
  end
end

# Setup Hiera -- why doesn't the gem do this?
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

  # Link Hiera config into Puppet
  this_module = File.dirname(File.expand_path(__FILE__))
  the_symlink = '/private/etc/puppet/hiera.yaml'
  puts "Linking #{the_symlink} into /etc/puppet..."
  unless File.symlink?(the_symlink)
    Dir.chdir File.dirname(the_symlink)
    FileUtils.ln_s hiera_config_path, File.basename(the_symlink)
    Dir.chdir this_module
  end

  # Hiera YAML hierarchy
  hiera_lib_dir  = '/private/var/lib/hiera'
  hiera_defaults = '/private/var/lib/hiera/defaults.yaml'
  puts "Installing #{hiera_lib_dir}..."
  FileUtils.mkdir_p hiera_lib_dir unless File.exists? hiera_lib_dir
  FileUtils.touch hiera_defaults  unless File.exists? hiera_defaults
end

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

task :finish do
  puts "Setup Complete"
end

desc "Package managedmac module for PuppetForge"
task :forge do
  if Rake::Task[:spec_clean].invoke
    puts %x{puppet module build}
    puts %x{open https://forge.puppetlabs.com/login}
  end
end

# Jim Weirich died today
task :thanks_Jim do
  puts "I \u{1F496}  Rake. Thanks, Jim."
end
