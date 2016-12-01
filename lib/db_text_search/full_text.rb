# frozen_string_literal: true

require 'db_text_search/full_text/postgres_adapter'
require 'db_text_search/full_text/mysql_adapter'
require 'db_text_search/full_text/sqlite_adapter'

module DbTextSearch
  # Provides basic full-text search for a list of terms, and FTS index creation.
  class FullText
    # The default Postgres text search config.
    DEFAULT_PG_TS_CONFIG = %q('english')

    # @param scope [ActiveRecord::Relation, Class<ActiveRecord::Base>]
    # @param column [Symbol] name
    def initialize(scope, column)
      @adapter = self.class.adapter_class(scope.connection, scope.table_name, column).new(scope, column)
      @scope   = scope
    end

    # @param term_or_terms [String, Array<String>]
    # @param pg_ts_config [String] for Postgres, the TS config to use; ignored for non-postgres.
    # @return [ActiveRecord::Relation]
    def search(term_or_terms, pg_ts_config: DEFAULT_PG_TS_CONFIG)
      values = Array(term_or_terms)
      return @scope.none if values.empty?
      @adapter.search(values, pg_ts_config: pg_ts_config)
    end

    # Add an index for full text search.
    #
    # @param connection [ActiveRecord::ConnectionAdapters::AbstractAdapter]
    # @param table_name [String, Symbol]
    # @param column_name [String, Symbol]
    # @param name [String, Symbol] index name
    # @param pg_ts_config [String] for Postgres, the TS config to use; ignored for non-postgres.
    def self.add_index(connection, table_name, column_name, name: "#{table_name}_#{column_name}_fts",
        pg_ts_config: DEFAULT_PG_TS_CONFIG)
      adapter_class(connection, table_name, column_name)
          .add_index(connection, table_name, column_name, name: name, pg_ts_config: pg_ts_config)
    end

    # @param connection [ActiveRecord::ConnectionAdapters::AbstractAdapter]
    # @param _table_name [String, Symbol]
    # @param _column_name [String, Symbol]
    # @return [Class<AbstractAdapter>]
    # @api private
    def self.adapter_class(connection, _table_name, _column_name)
      DbTextSearch.match_adapter(
          connection,
          mysql:    -> { MysqlAdapter },
          postgres: -> { PostgresAdapter },
          sqlite:   -> { SqliteAdapter }
      )
    end
  end
end
