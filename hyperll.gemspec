# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'hyperll/version'

Gem::Specification.new do |spec|
  spec.name          = "hyperll"
  spec.version       = Hyperll::VERSION
  spec.authors       = ["Andy Lindeman"]
  spec.email         = ["andy@andylindeman.com"]
  spec.description   = %q{HyperLogLog implementation in pure Ruby}
  spec.summary       = %q{HyperLogLog implementation in pure Ruby}
  spec.homepage      = "https://github.com/alindeman/hyperll"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.extensions    = ['ext/hyperll/extconf.rb']
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec", "~> 2.14"
  spec.add_development_dependency "rake-compiler", "~>0.9.1"
end
