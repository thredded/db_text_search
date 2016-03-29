require 'db_text_search/case_insensitive_eq/abstract_adapter'
module DbTextSearch
  class CaseInsensitiveEq
    class InsensitiveColumnAdapter < AbstractAdapter
      # (see AbstractAdapter#find)
      def find(values)
        @scope.where(@column => values)
      end

      # (see AbstractAdapter.add_index)
      def self.add_index(connection, table_name, column_name, options = {})
        connection.add_index table_name, column_name, options
      end
    end
  end
end
