require 'bundler/gem_tasks'
require 'rspec/core/rake_task'
require 'yard'

RSpec::Core::RakeTask.new('spec')

task default: :spec

require 'rake/extensiontask'
Rake::ExtensionTask.new 'netsoul_kerberos' do |ext|
  ext.lib_dir = 'lib'
end

desc 'Generate documentation'
YARD::Rake::YardocTask.new do |t|
  t.files = %w(lib/**/*.rb - LICENSE.txt)
  t.options = %w(--main README.md --no-private --protected)
end
