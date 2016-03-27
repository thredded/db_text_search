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
        @scope.where <<-SQL
          LOWER(#{conn.quote_table_name(@scope.table_name)}.#{conn.quote_column_name(@column)})
            IN (#{values.map { |v| "LOWER(#{conn.quote(v.to_s)})" }.join(', ')})
        SQL
      end
    end
  end
end
