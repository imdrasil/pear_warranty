# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'pear_warranty/version'

Gem::Specification.new do |spec|
  spec.name          = "pear_warranty"
  spec.version       = PearWarranty::VERSION
  spec.authors       = ["Roman Kalnytsky"]
  spec.email         = ["moranibaca@gmail.com"]
  spec.summary       = %q{Get IPhone warranty information}
  spec.description   = %q{Get IPhone warranty information form  https://selfsolve.apple.com by device imei}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", '~> 1.3'
  spec.add_development_dependency "rake"
  spec.add_development_dependency 'rspec'
  spec.add_development_dependency 'webmock', '>= 1.21.0'

  spec.add_dependency 'http-cookie', '>= 1.0.2'
  spec.add_dependency 'mechanize', '>= 2.6.0'
end
