# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "vuelandia/version"

Gem::Specification.new do |spec|
  spec.name          = "vuelandia"
  spec.version       = Vuelandia::VERSION
  spec.authors       = ["Mario Muniz"]
  spec.email         = ["mario462@gmail.com"]
  spec.summary       = %q{Interfaces with the Vuelandia API to book hotel rooms}
  spec.summary       = %q{Interfaces with the Vuelandia API to book hotel rooms using Nokogiri to build and parse XML and Net::HTTP to make a POST to the website}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "nokogiri", '~> 1.6'
end
