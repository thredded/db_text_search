require 'db_text_search/full_text_search/postgres_adapter'
require 'db_text_search/full_text_search/mysql_adapter'
require 'db_text_search/full_text_search/sqlite_adapter'

module DbTextSearch
  # Provides case-insensitive string-in-set querying, and CI index creation.
  class FullTextSearch
    # (see AbstractAdapter)
    def initialize(scope, column)
      @adapter = self.class.adapter_class(scope.connection, scope.table_name, column).new(scope, column)
      @scope   = scope
    end

    # @param term_or_terms [String, Array<String>]
    # @return (see AbstractAdapter#find)
    def find(term_or_terms)
      values = Array(term_or_terms)
      return @scope.none if values.empty?
      @adapter.find(values)
    end

    # (see AbstractAdapter.add_index)
    def self.add_index(connection, table_name, column_name, options = {})
      adapter_class(connection, table_name, column_name).add_index(connection, table_name, column_name, options)
    end

    # @param connection [ActiveRecord::ConnectionAdapters::AbstractAdapter]
    # @param _table_name [String, Symbol]
    # @param _column_name [String, Symbol]
    # @return [Class<AbstractAdapter>]
    def self.adapter_class(connection, _table_name, _column_name)
      case connection.adapter_name
        when /mysql/i
          MysqlAdapter
        when /postgres/i
          PostgresAdapter
        when /sqlite/i
          SqliteAdapter
        else
          fail "unknown adapter #{connection.adapter_name}"
      end
    end
  end
end
