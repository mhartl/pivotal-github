# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'pivotal-github/version'

Gem::Specification.new do |gem|
  gem.name          = "pivotal-github"
  gem.version       = Pivotal::Github::VERSION
  gem.authors       = ["Michael Hartl"]
  gem.email         = ["michael@michaelhartl.com"]
  gem.description   = %q{Add commands for Pivotal Tracker-GitHub integration}
  gem.summary       = %q{See the README for full documentation}
  gem.homepage      = "https://github.com/mhartl/pivotal-github"

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]
end
