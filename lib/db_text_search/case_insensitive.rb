# frozen_string_literal: true

require 'db_text_search/case_insensitive/insensitive_column_adapter'
require 'db_text_search/case_insensitive/lower_adapter'
require 'db_text_search/case_insensitive/collate_nocase_adapter'

module DbTextSearch
  # Provides case-insensitive string-in-set querying, LIKE querying, and CI index creation.
  class CaseInsensitive
    # @param scope [ActiveRecord::Relation, Class<ActiveRecord::Base>]
    # @param column [Symbol] name
    def initialize(scope, column)
      @adapter = self.class.adapter_class(scope.connection, scope.table_name, column).new(scope, column)
      @scope   = scope
    end

    # @param value_or_values [String, Array<String>]
    # @return [ActiveRecord::Relation]
    def in(value_or_values)
      values = Array(value_or_values)
      return @scope.none if values.empty?
      @adapter.in(values)
    end

    # @param query [String]
    # @return [ActiveRecord::Relation]
    def like(query)
      return @scope.none if query.empty?
      @adapter.like(query)
    end

    # @return [String] SQL-quoted string suitable for use in a LIKE statement, with % and _ escaped.
    def sanitize_sql_like(string, escape_character = '\\')
      @adapter.sanitize_sql_like(string, escape_character)
    end

    # Adds a case-insensitive column to the given table.
    # @param connection [ActiveRecord::ConnectionAdapters::AbstractAdapter]
    # @param table_name [String, Symbol]
    # @param column_name [String, Symbol]
    # @param options [Hash] passed to ActiveRecord::ConnectionAdapters::SchemaStatements#add_index
    def self.add_ci_text_column(connection, table_name, column_name, options = {})
      connection.add_column table_name, column_name, *DbTextSearch.match_adapter(
          connection,
          mysql:    -> { [:text, options] },
          postgres: -> {
            connection.enable_extension 'citext'
            [(ActiveRecord::VERSION::STRING >= '4.2.0' ? :citext : 'CITEXT'), options]
          },
          sqlite:   -> {
            if ActiveRecord::VERSION::MAJOR >= 5
              [:text, options.merge(collation: 'NOCASE')]
            else
              ['TEXT COLLATE NOCASE', options]
            end
          })
    end

    # Add an index for case-insensitive string search.
    #
    # @param connection [ActiveRecord::ConnectionAdapters::AbstractAdapter]
    # @param table_name [String, Symbol]
    # @param column_name [String, Symbol]
    # @param options [Hash]
    # @option options name [String] index name
    # @option options unique [Boolean] default: false
    def self.add_index(connection, table_name, column_name, options = {})
      adapter_class(connection, table_name, column_name).add_index(connection, table_name, column_name, options)
    end

    # @param connection [ActiveRecord::ConnectionAdapters::AbstractAdapter]
    # @param table_name [String, Symbol]
    # @param column_name [String, Symbol]
    # @return [Class<AbstractAdapter>]
    # @api private
    def self.adapter_class(connection, table_name, column_name)
      lower_or_insensitive = -> {
        column_case_sensitive?(connection, table_name, column_name) ? LowerAdapter : InsensitiveColumnAdapter
      }
      DbTextSearch.match_adapter(
          connection,
          mysql:    lower_or_insensitive,
          postgres: lower_or_insensitive,
          # Always use COLLATE NOCASE for SQLite, as we can't check if the column is case-sensitive.
          # It has no performance impact apart from slightly longer query strings for case-insensitive columns.
          sqlite:   -> { CollateNocaseAdapter })
    end

    # @param connection [ActiveRecord::ConnectionAdapters::AbstractAdapter]
    # @param table_name [String, Symbol]
    # @param column_name [String, Symbol]
    # @return [Boolean]
    # @note sqlite not supported.
    # @api private
    def self.column_case_sensitive?(connection, table_name, column_name)
      column = connection.schema_cache.columns(table_name).detect { |c| c.name == column_name.to_s }
      DbTextSearch.match_adapter(
          connection,
          mysql:    -> { column.case_sensitive? },
          postgres: -> { column.sql_type !~ /citext/i },
          sqlite:   -> { DbTextSearch.unsupported_adapter! connection })
    end
  end
end
