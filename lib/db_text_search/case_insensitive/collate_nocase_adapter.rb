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

      # (see AbstractAdapter#like)
      def like(query)
        escape = '\\'
        # assuming case_sensitive_like mode to be disabled, like it is by default.
        # this is to avoid adding COLLATE NOCASE here, which prevents index use in SQLite LIKE.
        @scope.where "#{quoted_scope_column} LIKE ?#{" ESCAPE '#{escape}'" if query.include?(escape)}", query
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
