# frozen_string_literal: true

require 'db_text_search/full_text/abstract_adapter'
module DbTextSearch
  class FullText
    # Provides basic FTS support for PostgreSQL.
    #
    # Runs a `@@ plainto_tsquery` query against a `gist(to_tsvector(...))` index.
    #
    # @see DbTextSearch::FullText::DEFAULT_PG_TS_CONFIG
    # @api private
    class PostgresAdapter < AbstractAdapter
      # (see AbstractAdapter#search)
      def search(terms, pg_ts_config:)
        @scope.where("to_tsvector(#{pg_ts_config}, #{quoted_scope_column}) @@ plainto_tsquery(#{pg_ts_config}, ?)",
                     terms.uniq.join(' '))
      end

      # (see AbstractAdapter.add_index)
      def self.add_index(connection, table_name, column_name, name:, pg_ts_config:)
        expression = "USING gist(to_tsvector(#{pg_ts_config}, #{connection.quote_column_name column_name}))"
        connection.exec_query quoted_create_index(connection, table_name, name: name, expression: expression)
      end
    end
  end
end
