# frozen_string_literal: true

require 'db_text_search/case_insensitive/abstract_adapter'
module DbTextSearch
  class CaseInsensitive
    # Provides case-insensitive string-in-set querying via COLLATE NOCASE.
    # @api private
    class CollateNocaseAdapter < AbstractAdapter
      # (see AbstractAdapter#in)
      def in(values)
        conn = @scope.connection
        @scope.where "#{quoted_scope_column} COLLATE NOCASE IN (#{values.map { |v| conn.quote(v.to_s) }.join(', ')})"
      end

      # (see AbstractAdapter#prefix)
      def prefix(query)
        escape        = '\\'
        escaped_query = "#{sanitize_sql_like(query, escape)}%"
        # assuming case_sensitive_prefix mode to be disabled, prefix it is by default.
        # this is to avoid adding COLLATE NOCASE here, which prevents index use in SQLite LIKE.
        @scope.where "#{quoted_scope_column} LIKE ?#{" ESCAPE '#{escape}'" if escaped_query.include?(escape)}",
                     escaped_query
      end

      # (see AbstractAdapter#column_for_order)
      def column_for_order(asc_or_desc)
        Arel.sql("#{quoted_scope_column} COLLATE NOCASE #{asc_or_desc}")
      end

      # (see AbstractAdapter.add_index)
      def self.add_index(connection, table_name, column_name, options = {})
        # TODO: Switch to the native Rails solution once it's landed, as the current one requires SQL dump format.
        # https://github.com/rails/rails/pull/18499
        options              = options.dup
        options[:name]       ||= "#{column_name}_nocase"
        options[:expression] = "(#{connection.quote_column_name(column_name)} COLLATE NOCASE)"
        connection.exec_query quoted_create_index(connection, table_name, **options)
      end
    end
  end
end
