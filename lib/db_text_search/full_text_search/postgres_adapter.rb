require 'db_text_search/full_text_search/abstract_adapter'
module DbTextSearch
  class FullTextSearch
    class PostgresAdapter < AbstractAdapter
      # (see AbstractAdapter#where_args)
      def where_args(terms, options = {})
        options      = parse_search_options(options)
        pg_ts_config = options[:pg_ts_config]
        ["to_tsvector(#{pg_ts_config}, #{quoted_scope_column}::text) @@ plainto_tsquery(#{pg_ts_config}, ?)",
         terms.uniq.join(' ')]
      end

      # (see AbstractAdapter.add_index)
      def self.add_index(connection, table_name, column_name, options = {})
        options.assert_valid_keys(:name, :pg_ts_config)
        pg_ts_config    = options[:pg_ts_config] || DEFAULT_PG_TS_CONFIG
        index_name      = options[:name] || "#{table_name}_#{column_name}_fts"
        connection.exec_query <<-SQL.strip
          CREATE INDEX #{index_name} ON #{connection.quote_table_name(table_name)}
            USING gist(to_tsvector(#{pg_ts_config}, #{connection.quote_column_name column_name}))
        SQL
      end
    end
  end
end
