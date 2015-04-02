# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'decking/version'

Gem::Specification.new do |spec|
  spec.name          = "decking"
  spec.version       = Decking::VERSION
  spec.authors       = ["Randy D. Wallace Jr."]
  spec.email         = ["randy@randywallace.com"]
  spec.summary       = %q{Decking is a rewrite of the node tool also called decking which provides docker orchestration}
  spec.description   = %q{Decking is a rewrite of the node tool also called decking which provides docker orchestration}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "hashie"
  spec.add_dependency "ruby-progressbar"
  spec.add_dependency "docker-api", "~> 1.20.0"
  spec.add_dependency "log4r"
  spec.add_dependency "io-console"

  spec.add_development_dependency "bundler", "~> 1.7"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.1.0"
  spec.add_development_dependency "guard"
  spec.add_development_dependency "guard-rspec"
  spec.add_development_dependency "pry"
  spec.add_development_dependency "pry-remote"
  spec.add_development_dependency "pry-nav"
end

