$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
ENV['RAILS_ENV'] = ENV['RACK_ENV'] = 'test'
if ENV['TRAVIS'] && !(defined?(RUBY_ENGINE) && RUBY_ENGINE == 'rbx')
  require 'codeclimate-test-reporter'
  CodeClimate::TestReporter.start
end
require 'db_text_search'
require 'fileutils'

FileUtils.mkpath 'log' unless File.directory? 'log'
ActiveRecord::Base.logger = Logger.new('log/test-queries.log')

ENV['DB'] ||= 'sqlite3'
case ENV['DB']
  when 'mysql2', 'postgresql'
    ActiveRecord::Base.establish_connection(
        database:     'db_text_search_gem_test',
        encoding:     'utf8',
        min_messages: 'WARNING',
        adapter:      ENV['DB'],
        username:     ENV['DB_USERNAME'] || 'db_text_search',
        password:     ENV['DB_PASSWORD'] || 'db_text_search')
  when 'sqlite3'
    ActiveRecord::Base.establish_connection(adapter: 'sqlite3', database: ':memory:')
  else
    fail "Unknown DB adapter #{ENV['DB']}"
end

system({'DB' => ENV['DB']}, 'script/create-db-users') unless ENV['TRAVIS']
ActiveRecord::Tasks::DatabaseTasks.create ActiveRecord::Base.connection_config.stringify_keys
