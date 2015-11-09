# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'fallout/version'

Gem::Specification.new do |spec|
  spec.name          = "fallout"
  spec.version       = Fallout::VERSION
  spec.authors       = ["Valentin Vasilyev"]
  spec.email         = ["valentin.vasilyev@outlook.com"]
  spec.summary       = %q{A simple ruby script that can backup and restore Amazon EC2 instances}
  spec.homepage      = "https://github.com/Valve/fallout"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "aws-sdk", "< 3"
  spec.add_dependency "trollop"

  spec.add_development_dependency "bundler"
  spec.add_development_dependency "rake"
end
