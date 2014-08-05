# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'crap_server/version'

Gem::Specification.new do |spec|
  spec.name          = 'crap_server'
  spec.version       = CrapServer::VERSION
  spec.authors       = ['Andres Jose Borek']
  spec.email         = ['andres.b.dev@gmail.com']
  spec.summary       = %q{Really thin a non intuitive ruby server.}
  spec.description   = %q{Really thin and non intuitive ruby server. Made to be fast and ready for really heavy servers (not only http server).}
  spec.homepage      = 'https://rubygems.org/gems/crap_server'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.required_ruby_version = '>= 1.9.2'
  spec.add_development_dependency 'bundler', '~> 1.6'
  spec.add_development_dependency 'rspec', '>= 3.0'
  # celluloid is for future use. Right now is not used
  # spec.add_dependency "celluloid", '~> 0.15.2'
end
