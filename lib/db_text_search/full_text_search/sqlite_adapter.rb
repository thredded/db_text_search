require 'db_text_search/full_text_search/abstract_adapter'
module DbTextSearch
  class FullTextSearch
    # Provides very basic FTS support for SQLite.
    #
    # Runs a `LIKE %term%` query for each term, joined with `AND`.
    # Cannot use an index.
    #
    # @note .add_index is a no-op.
    # @api private
    class SqliteAdapter < AbstractAdapter
      # (see AbstractAdapter#find)
      def find(terms, pg_ts_config:)
        quoted_col = quoted_scope_column
        terms.map(&:downcase).uniq.inject(@scope) do |scope, term|
          scope.where("#{quoted_col} COLLATE NOCASE LIKE ?", "%#{sanitize_sql_like term}%")
        end
      end

      # (see AbstractAdapter.add_index)
      def self.add_index(connection, table_name, column_name, name:, pg_ts_config:)
        # A no-op, as we just use LIKE for sqlite.
      end
    end
  end
end
