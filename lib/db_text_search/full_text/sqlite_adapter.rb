# frozen_string_literal: true

require 'db_text_search/full_text/abstract_adapter'
module DbTextSearch
  class FullText
    # Provides very basic FTS support for SQLite.
    #
    # Runs a `LIKE %term%` query for each term, joined with `AND`.
    # Cannot use an index.
    #
    # @note .add_index is a no-op.
    # @api private
    class SqliteAdapter < AbstractAdapter
      # (see AbstractAdapter#search)
      def search(terms, pg_ts_config:)
        quoted_col = quoted_scope_column
        terms.map(&:downcase).uniq.inject(@scope) do |scope, term|
          scope.where("#{quoted_col} COLLATE NOCASE LIKE ?", "%#{sanitize_sql_like term}%")
        end
      end

      # A no-op, as we just use LIKE for sqlite.
      def self.add_index(_connection, _table_name, _column_name, name:, pg_ts_config:); end
    end
  end
end
