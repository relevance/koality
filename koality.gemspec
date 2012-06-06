# -*- encoding: utf-8 -*-
require File.expand_path('../lib/koality/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Jared Pace"]
  gem.email         = ["jared@thinkrelevance.com"]
  gem.description   = %q{Runs opinionated code quality tools as part of you test stuite}
  gem.summary       = %q{Runs opinionated code quality tools as part of you test stuite}
  gem.homepage      = "https://github.com/relevance/koality"

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "koality"
  gem.require_paths = ["lib"]
  gem.version       = Koality::VERSION

  # Runtime Dependencies
  gem.add_runtime_dependency 'rails_best_practices', ['~> 1.9']
  gem.add_runtime_dependency 'simplecov', ['~> 0.6']
  gem.add_runtime_dependency 'cane', ['~> 1.3']
  gem.add_runtime_dependency 'terminal-table', ['~> 1.4']
  gem.add_runtime_dependency 'term-ansicolor', ['~> 1.0']

  # Developmnet Dependencies
  gem.add_development_dependency 'rspec', ['~> 2.10']
  gem.add_development_dependency 'mocha', ['~> 0.11']
end
