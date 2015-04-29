# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'clockwork/admin/version'

Gem::Specification.new do |spec|
  spec.name          = "clockwork-admin"
  spec.version       = Clockwork::Admin::VERSION
  spec.authors       = ["Stephen Veiss"]
  spec.email         = ["stephen@brokenbottle.net"]

  spec.summary       = %q{UI for clustered Clockwork}
  spec.description   = "A basic admin UI for ZooKeeper-backed Clockwork."
  spec.homepage      = "https://github.com/GoCarrot/clockwork-admin"
  spec.license       = "Apache-2.0"

  spec.files         = Dir['README.md', 'LICENSE', 'lib/**/*', 'examples/*']
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.extra_rdoc_files = ["README.md"]

  spec.add_development_dependency "bundler", "~> 1.9"
  spec.add_development_dependency "rake", "~> 10.0"

  spec.add_dependency "sinatra", '~> 1.4'
  spec.add_dependency "sinatra-contrib", '~> 1.4'
  spec.add_dependency "zk", '~> 1.9'
  spec.add_dependency "multi_json", '~> 1.8'
end
