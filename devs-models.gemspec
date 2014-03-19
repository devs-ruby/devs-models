# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'devs/models'

Gem::Specification.new do |spec|
  spec.name          = "devs-models"
  spec.version       = DEVS::Models::VERSION.dup
  spec.authors       = ["Romain Franceschini"]
  spec.email         = ["franceschini.romain@gmail.com"]
  spec.description   = %q{DEVS Models}
  spec.summary       = %q{A library of common models to go with Ruby DEVS implementation}
  spec.homepage      = "https://github.com/romain1189/devs-models"
  spec.license       = 'MIT'

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec)/})
  spec.require_paths = ['lib']

  spec.add_development_dependency('bundler', '~> 1.3')
  spec.add_development_dependency('yard', '~> 0.8')
  spec.add_development_dependency('rake')
  spec.add_development_dependency('minitest')
  spec.add_development_dependency('pry', '~> 0.9')

  spec.add_dependency('devs', '~> 1.0')
end
