# frozen_string_literal: true

lib = File.expand_path('../lib'.freeze, __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'netsoul/version'

Gem::Specification.new do |spec|
  spec.name          = 'netsoul'.freeze
  spec.version       = Netsoul::VERSION
  spec.authors       = ['Christian Kakesa'.freeze]
  spec.email         = ['christian.kakesa@gmail.com'.freeze]

  spec.summary       = 'Netsoul client and library for ruby.'.freeze
  spec.description   = spec.summary
  spec.homepage      = 'https://github.com/fenicks/netsoul-ruby'.freeze
  spec.license       = 'MIT'.freeze

  # Prevent pushing this gem to RubyGems.org by setting 'allowed_push_host', or
  # delete this section to allow pushing this gem to any host.
  raise 'RubyGems 2.0 or newer is required to protect against public gem pushes.'.freeze unless spec.respond_to?(:metadata)
  spec.metadata['allowed_push_host'] = 'https://rubygems.org'.freeze

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = 'bin'.freeze
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.require_paths = %w(lib ext bin).map(&:freeze).freeze
  spec.extensions    = ['ext/netsoul_kerberos/extconf.rb'.freeze]

  spec.add_development_dependency 'bundler'.freeze, '~> 1.7'.freeze, '>= 1.7.0'.freeze
  spec.add_development_dependency 'rake'.freeze, '~> 0'.freeze
  spec.add_development_dependency 'rubocop'.freeze, '~> 0'.freeze
  spec.add_development_dependency 'rspec'.freeze, '~> 3.3'.freeze
  spec.add_development_dependency 'simplecov'.freeze, '~> 0'.freeze
  spec.add_development_dependency 'coveralls'.freeze, '~> 0'.freeze
  spec.add_development_dependency 'yard'.freeze, '~> 0'.freeze
  spec.add_development_dependency 'memory_profiler'.freeze, '~> 0'.freeze if RUBY_VERSION >= '2.1.0'
  spec.add_development_dependency 'rake-compiler'.freeze, '~> 0.9.5'.freeze
end
