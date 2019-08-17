lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'db_text_search/version'

Gem::Specification.new do |s|
  s.name    = 'db_text_search'
  s.version = DbTextSearch::VERSION
  s.authors = ['Gleb Mazovetskiy']
  s.email   = ['glex.spb@gmail.com']

  s.summary     = 'A unified interface on top of ActiveRecord for SQLite, MySQL, and PostgreSQL'\
                  'for case-insensitive string search and basic full-text search.'
  s.description = 'Different relational databases treat text search very differently. DbTextSearch provides '\
                  'a unified interface on top of ActiveRecord for SQLite, MySQL, and PostgreSQL to do '\
                  'case-insensitive string-in-set querying and CI index creation, and '\
                  'basic full-text search for a list of terms, and FTS index creation.'
  s.homepage    = 'https://github.com/thredded/db_text_search'
  s.license     = 'MIT'

  s.files = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(spec|bin|script)/|^\.|Rakefile|Gemfile}) }

  s.require_paths         = ['lib']
  s.required_ruby_version = '~> 2.1'

  s.add_dependency 'activerecord', '>= 4.1.15', '< 7.0'

  s.add_development_dependency 'mysql2', '>= 0.3.20'
  s.add_development_dependency 'pg', '>= 0.18.4'
  s.add_development_dependency 'sqlite3', '>= 1.3.11'

  s.add_development_dependency 'rake', '~> 11.0'
  s.add_development_dependency 'rspec', '~> 3.4'
  s.add_development_dependency 'simplecov'
end
