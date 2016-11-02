# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'devs/models/version'

Gem::Specification.new do |spec|
  spec.name          = "devs-models"
  spec.version       = DEVS::Models::VERSION.dup
  spec.authors       = ["Romain Franceschini"]
  spec.email         = ["franceschini.romain@gmail.com"]
  spec.description   = %q{DEVS Models}
  spec.summary       = %q{A library of common models to go with Ruby DEVS implementation}
  spec.homepage      = "https://github.com/devs-ruby/devs-models"
  spec.license       = 'MIT'

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec)/})
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 1.13'
  spec.add_development_dependency 'rake', '~> 11.3'

  spec.add_dependency('gnuplot', '~> 2.6')
  spec.add_dependency('devs', '~> 0.6')

  spec.required_ruby_version = '>= 2.1.0'
end
