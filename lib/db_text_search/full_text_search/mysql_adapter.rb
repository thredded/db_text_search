require 'db_text_search/full_text_search/abstract_adapter'
module DbTextSearch
  class FullTextSearch
    class MysqlAdapter < AbstractAdapter
      # (see AbstractAdapter#where_args)
      def where_args(terms, options = {})
        parse_search_options(options)
        conn = @scope.connection
        ["MATCH (#{conn.quote_table_name(@scope.table_name)}.#{conn.quote_column_name(@column)}) AGAINST (?)",
         terms.uniq.join(' ')]
      end

      # (see AbstractAdapter.add_index)
      def self.add_index(connection, table_name, column_name, options = {})
        connection.add_index table_name, column_name, options.merge(type: :fulltext)
      end
    end
  end
end
