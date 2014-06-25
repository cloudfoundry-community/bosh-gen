# -*- encoding: utf-8 -*-
require File.expand_path('../lib/bosh/gen/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Dr Nic Williams"]
  gem.email         = ["drnicwilliams@gmail.com"]
  gem.description   = %q{Generators for creating BOSH releases}
  gem.summary       = gem.summary
  gem.homepage      = "https://github.com/drnic/bosh-gen"

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "bosh-gen"
  gem.require_paths = ["lib"]
  gem.version       = Bosh::Gen::VERSION

  gem.add_dependency "thor"
  gem.add_dependency "bosh_cli"
  gem.add_dependency "bosh_common"

  gem.add_dependency "cyoi", "~> 0.10.0"
  gem.add_dependency "fog", "~> 1.11"
  gem.add_dependency "readwritesettings", "~> 3.0"

  gem.add_development_dependency "rake"
  gem.add_development_dependency "minitest", "~> 2.12"
  gem.add_development_dependency "minitest-colorize"
  gem.add_development_dependency "guard-minitest"
end
