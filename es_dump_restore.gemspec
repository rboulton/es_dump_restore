# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'es_dump_restore/version'

Gem::Specification.new do |gem|
  gem.name          = "es_dump_restore"
  gem.version       = EsDumpRestore::VERSION
  gem.authors       = ["Nat Budin"]
  gem.email         = ["nbudin@patientslikeme.com"]
  gem.description   = %q{A utility for dumping the contents of an ElasticSearch index to a compressed file and restoring the dumpfile back to an ElasticSearch server}
  gem.summary       = %q{Dump ElasticSearch indexes to files and restore them back}
  gem.homepage      = "https://github.com/patientslikeme/es_dump_restore"

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  gem.add_dependency 'multi_json'
  gem.add_dependency 'httpclient'
  gem.add_dependency 'thor'
  gem.add_dependency 'rubyzip', ">= 1.0.0"
  gem.add_dependency 'progress_bar'
  gem.add_dependency 'rake'
end
