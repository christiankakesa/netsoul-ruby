# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'netsoul/version'

Gem::Specification.new do |spec|
  spec.name          = 'netsoul'
  spec.version       = Netsoul::VERSION
  spec.authors       = ['Christian Kakesa']
  spec.email         = ['christian.kakesa@gmail.com']

  spec.summary       = 'Netsoul client and library for ruby.'
  spec.description   = spec.summary
  spec.homepage      = 'https://github.com/fenicks/netsoul-ruby'
  spec.license       = 'MIT'

  # Prevent pushing this gem to RubyGems.org by setting 'allowed_push_host', or
  # delete this section to allow pushing this gem to any host.
  raise 'RubyGems 2.0 or newer is required to protect against public gem pushes.' unless spec.respond_to?(:metadata)
  spec.metadata['allowed_push_host'] = 'https://rubygems.org'

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = 'bin'
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.require_paths = %w(lib ext bin)
  spec.extensions    = ['ext/netsoul_kerberos/extconf.rb']

  spec.add_development_dependency 'bundler', '~> 1.7', '>= 1.7.0'
  spec.add_development_dependency 'rake', '~> 0'
  spec.add_development_dependency 'rubocop', '~> 0'
  spec.add_development_dependency 'rspec', '~> 3.3'
  spec.add_development_dependency 'simplecov', '~> 0'
  spec.add_development_dependency 'coveralls', '~> 0'
  spec.add_development_dependency 'yard', '~> 0'
  spec.add_development_dependency 'rake-compiler', '~> 0.9.5'
end
