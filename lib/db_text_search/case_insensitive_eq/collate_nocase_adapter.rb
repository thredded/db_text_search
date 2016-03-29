require 'db_text_search/case_insensitive_eq/abstract_adapter'
module DbTextSearch
  class CaseInsensitiveEq
    class CollateNocaseAdapter < AbstractAdapter
      # (see AbstractAdapter#find)
      def find(values)
        conn = @scope.connection
        @scope.where <<-SQL.strip
          #{quoted_scope_column} COLLATE NOCASE IN (#{values.map { |v| conn.quote(v.to_s) }.join(', ')})
        SQL
      end

      # (see AbstractAdapter.add_index)
      def self.add_index(connection, table_name, column_name, options = {})
        # TODO: Switch to the native Rails solution once it's landed, as the current one requires SQL dump format.
        # https://github.com/rails/rails/pull/18499
        options.assert_valid_keys(:name, :unique)
        index_name = options[:name] || options[:name] || "#{column_name}_nocase"
        connection.exec_query <<-SQL.strip
          CREATE #{'UNIQUE ' if options[:unique]}INDEX #{index_name} ON #{connection.quote_table_name(table_name)}
            (#{connection.quote_column_name(column_name)} COLLATE NOCASE);
        SQL
      end
    end
  end
end
