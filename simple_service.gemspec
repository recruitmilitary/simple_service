# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'simple_service/version'

Gem::Specification.new do |spec|
  spec.name          = "simple_service"
  spec.version       = SimpleService::VERSION

  spec.author        = "Steve Valaitis"
  spec.email         = "steve@digitalnothing.com"
  spec.summary       = %q{Provides a simple framework for lightweight service objects/actions}
  spec.homepage      = "https://github.com/dnd/simple_service"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "hashie"

  spec.add_development_dependency "bundler", "~> 1.6"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "pry"
end
