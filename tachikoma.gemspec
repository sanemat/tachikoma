# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'tachikoma/version'

Gem::Specification.new do |spec|
  spec.name          = 'tachikoma'
  spec.version       = Tachikoma::VERSION
  spec.authors       = ['sanemat']
  spec.email         = ['o.gata.ken@gmail.com']
  spec.description   = %q{Interval pull requester with bundle/carton update.}
  spec.summary       = %q{Update gem frequently gets less pain. Let's doing bundle update as a habit!}
  spec.homepage      = 'https://github.com/sanemat/tachikoma'
  spec.license       = 'MIT'

  spec.files         = `git ls-files`.split($INPUT_RECORD_SEPARATOR)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_dependency 'safe_yaml'
  spec.add_dependency 'rake'
  spec.add_dependency 'octokit', '>= 2', '< 3'
  spec.add_dependency 'json'
  spec.add_dependency 'thor'

  spec.add_development_dependency 'bundler', '~> 1.3'
  spec.add_development_dependency 'dotenv'
  spec.add_development_dependency 'rspec', '>= 3.0.0.beta'
end
