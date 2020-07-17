# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'monza/version'

Gem::Specification.new do |spec|
  spec.name          = "monza"
  spec.version       = Monza::VERSION
  spec.authors       = ["Gabriel Garza"]
  spec.email         = ["garzagabriel@gmail.com"]

  spec.summary       = %q{Validate iTunes In-App purchase receipts, including auto-renewable subscriptions, with the App Store.}
  spec.description   = %q{Validate iTunes In-App purchase receipts, including auto-renewable subscriptions, with the App Store.}
  spec.homepage      = "https://github.com/gabrielgarza/monza"
  spec.license       = "MIT"

  # Prevent pushing this gem to RubyGems.org by setting 'allowed_push_host', or
  # delete this section to allow pushing this gem to any host.
  # if spec.respond_to?(:metadata)
  #   spec.metadata['allowed_push_host'] = "TODO: Set to 'http://mygemserver.com'"
  # else
  #   raise "RubyGems 2.0 or newer is required to protect against public gem pushes."
  # end

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "json"
  spec.add_dependency "activesupport"

  spec.add_development_dependency "bundler", "~> 2.1"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec"
end
