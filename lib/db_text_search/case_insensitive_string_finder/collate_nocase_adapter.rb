require 'db_text_search/case_insensitive_string_finder/adapter'
module DbTextSearch
  class CaseInsensitiveStringFinder
    class CollateNocaseAdapter < Adapter
      # (see Adapter#initialize)
      def initialize(scope, column)
        @scope  = scope
        @column = column
      end

      # (see Adapter#find)
      def find(values)
        conn = @scope.connection
        @scope.where <<-SQL
          #{conn.quote_table_name(@scope.table_name)}.#{conn.quote_column_name(@column)} COLLATE NOCASE
          IN (#{values.map { |v| conn.quote(v.to_s) }.join(', ')})
        SQL
      end
    end
  end
end
