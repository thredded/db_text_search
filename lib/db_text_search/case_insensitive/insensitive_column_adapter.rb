# frozen_string_literal: true

require 'db_text_search/case_insensitive/abstract_adapter'
module DbTextSearch
  class CaseInsensitive
    # Provides case-insensitive string-in-set querying for case-insensitive columns.
    # @api private
    class InsensitiveColumnAdapter < AbstractAdapter
      # (see AbstractAdapter#find)
      def find(values)
        @scope.where(@column => values)
      end

      # (see AbstractAdapter#like)
      def like(query)
        @scope.where "#{quoted_scope_column} LIKE ?", query
      end

      # (see AbstractAdapter.add_index)
      def self.add_index(connection, table_name, column_name, options = {})
        connection.add_index table_name, column_name, options
      end
    end
  end
end
