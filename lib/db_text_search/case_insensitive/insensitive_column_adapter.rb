# frozen_string_literal: true

require 'db_text_search/case_insensitive/abstract_adapter'
module DbTextSearch
  class CaseInsensitive
    # Provides case-insensitive string-in-set querying for case-insensitive columns.
    # @api private
    class InsensitiveColumnAdapter < AbstractAdapter
      # (see AbstractAdapter#in)
      def in(values)
        @scope.where(@column => values)
      end

      # (see AbstractAdapter#prefix)
      def prefix(query)
        @scope.where "#{quoted_scope_column} LIKE ?", "#{sanitize_sql_like(query)}%"
      end

      # (see AbstractAdapter#column_for_order)
      def column_for_order(asc_or_desc)
        Arel.sql("#{quoted_scope_column} #{asc_or_desc}")
      end

      # (see AbstractAdapter.add_index)
      def self.add_index(connection, table_name, column_name, options = {})
        connection.add_index table_name, column_name, options
      end
    end
  end
end
