require 'db_text_search/case_insensitive_eq/abstract_adapter'
module DbTextSearch
  class CaseInsensitiveEq
    class LowerAdapter < AbstractAdapter
      # (see AbstractAdapter#find)
      def find(values)
        conn = @scope.connection
        @scope.where <<-SQL.strip
          LOWER(#{quoted_scope_column}) IN (#{values.map { |v| "LOWER(#{conn.quote(v.to_s)})" }.join(', ')})
        SQL
      end

      # (see AbstractAdapter.add_index)
      def self.add_index(connection, table_name, column_name, options = {})
        if connection.adapter_name =~ /postgres/i
          # TODO: Switch to native Rails support once it lands.
          # https://github.com/rails/rails/pull/18499
          index_name = options[:name] || "#{table_name}_#{column_name}_lower"
          if defined?(SchemaPlus)
            connection.add_index(table_name, column_name, options.merge(
                name: index_name, expression: "LOWER(#{connection.quote_column_name(column_name)})"))
          else
            options.assert_valid_keys(:name, :unique)
            connection.exec_query <<-SQL.strip
              CREATE #{'UNIQUE ' if options[:unique]}INDEX #{index_name} ON #{connection.quote_table_name(table_name)}
                (LOWER(#{connection.quote_column_name(column_name)}));
            SQL
          end
        elsif connection.adapter_name =~ /mysql/i
          fail 'MySQL case-insensitive index creation for case-sensitive columns is not supported.'
        else
          fail "Cannot create a case-insensitive index for case-sensitive column on #{connection.adapter_name}."
        end
      end
    end
  end
end
