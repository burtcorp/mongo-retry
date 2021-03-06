# encoding: utf-8

$: << File.expand_path('../lib', __FILE__)

Gem::Specification.new do |s|
  s.name          = 'mongo-retry'
  s.version       = '0.3.0'
  s.authors       = ['Erik Fonselius', 'Sofia Larsson', 'Gustav Munkby']
  s.email         = ['fonsan@burtcorp.com', 'karinsofiapaulina@gmail.com', 'gustav.munkby@burtcorp.com']
  s.homepage      = 'http://github.com/burtcorp/mongo-retry'
  s.summary       = %q{mongo-retry helper}
  s.description       = %q{mongo-retry helper}
  s.license       = 'MIT'

  s.files         = Dir['lib/**/*.rb', 'README.md']
  s.test_files    = Dir['spec/*.rb']
  s.require_paths = %w(lib)

  s.add_runtime_dependency 'mongo', '>= 2.2'

  s.platform = Gem::Platform::RUBY
  s.required_ruby_version = '>= 1.9.3'
end
