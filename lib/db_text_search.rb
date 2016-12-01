# frozen_string_literal: true

require 'active_record'
require 'active_support/core_ext/hash/keys'

require 'db_text_search/version'
require 'db_text_search/case_insensitive'
require 'db_text_search/full_text'

# DbTextSearch provides a unified interface on top of ActiveRecord for SQLite, MySQL, and PostgreSQL to do:
# * Case-insensitive string-in-set querying, and CI index creation.
# * Basic full-text search for a list of terms, and FTS index creation.
# @see DbTextSearch::CaseInsensitive
# @see DbTextSearch::FullText
module DbTextSearch
  # Call the appropriate proc based on the adapter name.
  # @param connection [ActiveRecord::ConnectionAdapters::AbstractAdapter]
  # @param mysql [Proc]
  # @param postgres [Proc]
  # @param sqlite [Proc]
  # @return the called proc return value.
  # @api private
  def self.match_adapter(connection, mysql:, postgres:, sqlite:)
    case connection.adapter_name
      when /mysql/i
        mysql.call
      when /postg/i # match all postgres and postgis adapters
        postgres.call
      when /sqlite/i
        sqlite.call
      else
        unsupported_adapter! connection
    end
  end

  # Raises an ArgumentError with "Unsupported adapter #{connection.adapter_name}"
  # @param connection [ActiveRecord::ConnectionAdapters::AbstractAdapter]
  # @api private
  def self.unsupported_adapter!(connection)
    fail ArgumentError, "Unsupported adapter #{connection.adapter_name}"
  end
end
