$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
ENV['RAILS_ENV'] = ENV['RACK_ENV'] = 'test'
if ENV['TRAVIS'] && !(defined?(RUBY_ENGINE) && RUBY_ENGINE == 'rbx')
  require 'codeclimate_batch'
  CodeclimateBatch.start do
    add_filter '/lib/db_text_search/case_insensitive_string_finder/adapter.rb'
  end
end
require 'db_text_search'
require 'fileutils'

FileUtils.mkpath 'log' unless File.directory? 'log'
ActiveRecord::Base.logger = Logger.new('log/test-queries.log')

ENV['DB'] ||= 'sqlite3'
case ENV['DB']
  when 'mysql2', 'postgresql'
    system({'DB' => ENV['DB']}, 'script/create-db-users') unless ENV['TRAVIS']
    config = {
        # Host 127.0.0.1 required for default postgres installation on Ubuntu.
        host:         '127.0.0.1',
        database:     'db_text_search_gem_test',
        encoding:     'utf8',
        min_messages: 'WARNING',
        adapter:      ENV['DB'],
        username:     ENV['DB_USERNAME'] || 'db_text_search',
        password:     ENV['DB_PASSWORD'] || 'db_text_search'
    }
    if ENV['DB'] == 'postgresql'
      begin
        # Must be required before establish_connection.
        require 'schema_plus_pg_indexes'
      rescue LoadError
        # Nothing to do here, optional dependency
      end
    end
    ActiveRecord::Tasks::DatabaseTasks.create(config.stringify_keys)
    ActiveRecord::Base.establish_connection(config)
  when 'sqlite3'
    ActiveRecord::Base.establish_connection(adapter: 'sqlite3', database: ':memory:')
  else
    fail "Unknown DB adapter #{ENV['DB']}"
end

def force_index
  enable_force_index, disable_force_index =
      case ActiveRecord::Base.connection.adapter_name
        when /postgresql/i
          ['SET enable_seqscan=off', 'SET enable_seqscan=on']
        else
          nil
      end
  begin
    ActiveRecord::Base.connection.execute enable_force_index if enable_force_index
    yield
  ensure
    ActiveRecord::Base.connection.execute disable_force_index if disable_force_index
  end
end

def explain_index_expr(index_name)
  case ActiveRecord::Base.connection.adapter_name
    when /mysql/i
      /\b#{Regexp.escape index_name}\b.*Using index/
    when /sqlite/i
      "USING COVERING INDEX #{index_name}"
    when /postgres/i
      "Index Scan using #{index_name}"
    else
      fail "unknown adapter #{ActiveRecord::Base.connection.adapter_name}"
  end
end


RSpec::Matchers.define :use_index do |index_name|
  match do |scope|
    expect(scope.explain).to match(explain_index_expr(index_name))
  end

  failure_message do |scope|
    "expected EXPLAIN result to include #{explain_index_expr(index_name).inspect}:\n#{scope.explain}"
  end
end
