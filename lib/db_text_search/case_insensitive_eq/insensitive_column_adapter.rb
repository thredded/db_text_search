require 'db_text_search/case_insensitive_eq/adapter'
module DbTextSearch
  class CaseInsensitiveEq
    class InsensitiveColumnAdapter < Adapter
      # (see Adapter#initialize)
      def initialize(scope, column)
        @scope  = scope
        @column = column
      end

      # (see Adapter#find)
      def find(values)
        @scope.where(@column => values)
      end

      # (see Adapter.add_index)
      def self.add_index(connection, table_name, column_name, options = {})
        connection.add_index table_name, column_name, options
      end
    end
  end
end
