# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'active_merchant_recurring/version'

Gem::Specification.new do |spec|
  spec.name          = "active_merchant_recurring"
  spec.version       = ActiveMerchantRecurring::VERSION
  spec.authors       = ["Remus Rusanu"]
  spec.email         = ["contact@rusanu.com"]
  spec.description   = %q{ActiveMerchant recurring payments with PayPal Express Chekout}
  spec.summary       = %q{ActiveMerchant recurring payments with PayPal Express Chekout}
  spec.homepage      = "https://github.com/rusanu/active_merchant_recurring"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "activemerchant", "~> 1.45"
  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
end
