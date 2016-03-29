require 'db_text_search/full_text_search/abstract_adapter'
module DbTextSearch
  class FullTextSearch
    class SqliteAdapter < AbstractAdapter
      # (see AbstractAdapter.where_args)
      def where_args(terms, options = {})
        parse_search_options(options)
        quoted_col = quoted_scope_column
        term_args = terms.map(&:downcase).uniq.map do |term|
          ["#{quoted_col} COLLATE NOCASE LIKE ?", "%#{sanitize_sql_like term}%"]
        end
        [term_args.map(&:first).join(' AND '), *term_args.map(&:second)]
      end

      # (see AbstractAdapter.add_index)
      def self.add_index(connection, table_name, column_name, options = {})
        # A no-op, as we just use LIKE for sqlite.
      end
    end
  end
end
