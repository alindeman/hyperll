require "bundler/gem_tasks"
require "rake/extensiontask"

spec = Gem::Specification.load "hyperll.gemspec"
Rake::ExtensionTask.new("hyperll", spec) do |ext|
  ext.lib_dir = 'lib/hyperll'
end

require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new(:spec)
task :spec => :compile
task :default => :spec
