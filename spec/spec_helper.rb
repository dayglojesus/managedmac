require 'rubygems'
require 'bundler/setup'
require 'rspec-puppet'
require 'puppetlabs_spec_helper/rake_tasks'
require_relative './helpers'

fixture_path = File.expand_path(File.join(__FILE__, '..', 'fixtures'))
fixture_modules   = "#{fixture_path}/modules"
fixture_manifests = "#{fixture_path}/manifests"

Dir.glob("#{fixture_path}/modules/*").collect do |path|
  $LOAD_PATH << "#{path}/lib"
end

RSpec.configure do |c|
  c.include Helpers
  c.module_path = File.join(fixture_path, 'modules')
  c.manifest_dir = File.join(fixture_path, 'manifests')
end
