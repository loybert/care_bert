$:.push File.expand_path('../lib', __FILE__)

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
  s.description = 'CareBert analyzes the current items of your database and performs differing validation and integrity tests.'
  s.license     = 'MIT'

  s.files = Dir["{app,config,db,lib}/**/*", 'MIT-LICENSE', 'Rakefile', 'README.md']
  s.require_paths = ["lib"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency 'rails', '~> 3'

  s.add_development_dependency 'sqlite3'
  s.add_development_dependency 'rubocop'
end
