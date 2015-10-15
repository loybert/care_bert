$LOAD_PATH.push File.expand_path('../lib', __FILE__)

# Maintain your gem's version:
require 'care_bert/version'

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = 'care_bert'
  s.version     = CareBert::VERSION
  s.authors     = ['Daniel Loy']
  s.email       = ['loybert@gmail.com']
  s.homepage    = 'https://github.com/loybert/care_bert'
  s.summary     = 'CareBert takes care of the validation state of your current database items'
  s.description = 'CareBert analyzes the current items of your database and performs differing validation and integrity tests. Currently it supports following checks: \n - Table Integrity => check each single model-instance of all available tables can be loaded \n - Model Validation => triggers the validation of each single model-instance (which results might have changed due code-modifications) \n - Missing Assocs => tries to load each instance of an assoc, if the foreign_key is set (having a present FK doesn\'t mean it really has the targeted model available)'
  s.license     = 'MIT'

  s.files = Dir['{app,config,db,lib}/**/*', 'MIT-LICENSE', 'Rakefile', 'README.md']
  s.require_paths = ['lib']
  s.test_files = Dir['test/**/*']

  s.add_dependency 'rails', '>= 3'
  s.add_dependency 'ruby-progressbar'

  s.add_development_dependency 'sqlite3'
  s.add_development_dependency 'rubocop'
end
