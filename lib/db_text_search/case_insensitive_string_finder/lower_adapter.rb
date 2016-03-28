require 'db_text_search/case_insensitive_string_finder/adapter'
module DbTextSearch
  class CaseInsensitiveStringFinder
    class LowerAdapter < Adapter
      # (see Adapter#initialize)
      def initialize(scope, column)
        @scope  = scope
        @column = column
      end

      # (see Adapter#find)
      def find(values)
        conn = @scope.connection
        @scope.where <<-SQL.strip
          LOWER(#{conn.quote_table_name(@scope.table_name)}.#{conn.quote_column_name(@column)})
            IN (#{values.map { |v| "LOWER(#{conn.quote(v.to_s)})" }.join(', ')})
        SQL
      end

      # (see Adapter.add_index)
      def self.add_index(connection, table_name, column_name, options = {})
        if connection.adapter_name =~ /postgres/i
          # TODO: Currently using schema_plus_pg_indexes. Switch to native Rails support once it lands.
          connection.add_index(
              table_name, column_name,
              {name: "#{column_name}_lower"}.merge(options)
                  .merge(expression: "LOWER(#{connection.quote_column_name(column_name)})"))
        elsif connection.adapter_name =~ /mysql/i
          fail 'MySQL case-insensitive index creation for case-sensitive columns is not yet implemented.'
        else
          fail "Cannot create a case-insensitive index for case-sensitive column on #{connection.adapter_name}."
        end
      end
    end
  end
end
