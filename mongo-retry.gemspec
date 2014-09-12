# encoding: utf-8

$: << File.expand_path('../lib', __FILE__)

require 'mongo/retry'

Gem::Specification.new do |s|
  s.name          = 'mongo-retry'
  s.version       = '0.1.2'
  s.authors       = ['Erik Fonselius', 'Sofia Larsson']
  s.email         = ['fonsan@burtcorp.com', 'karinsofiapaulina@gmail.com']
  s.homepage      = 'http://github.com/burtcorp/mongo-retry'
  s.summary       = %q{mongo-retry helper}
  s.description       = %q{mongo-retry helper}
  s.license       = 'MIT'

  s.files         = Dir['lib/**/*.rb', 'README.md']
  s.test_files    = Dir['spec/*.rb']
  s.require_paths = %w(lib)

  s.add_runtime_dependency 'mongo', '~> 1.1'

  s.platform = Gem::Platform::RUBY
  s.required_ruby_version = '>= 1.9.3'
end
