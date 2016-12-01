# frozen_string_literal: true
SimpleCov.start do
  add_filter '/spec/'
  add_filter '/lib/db_text_search/case_insensitive/abstract_adapter.rb'
  add_filter '/lib/db_text_search/full_text/abstract_adapter.rb'
  add_group 'Lib', 'lib/'
  formatter SimpleCov::Formatter::HTMLFormatter unless ENV['TRAVIS']
end
