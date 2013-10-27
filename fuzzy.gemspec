# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'fuzzy/version'

Gem::Specification.new do |spec|
  spec.name          = "fuzzy"
  spec.version       = Fuzzy::VERSION
  spec.authors       = ["Sudhir Jonathan"]
  spec.email         = ["sudhir.j@gmail.com"]
  spec.description   = %q{Tokenizes, fuzzes and scores strings - good for autocomplete}
  spec.summary       = %q{Fuzzy tokenizer and ranker}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "i18n"
  spec.add_dependency "active_support"
  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "minitest"
end
