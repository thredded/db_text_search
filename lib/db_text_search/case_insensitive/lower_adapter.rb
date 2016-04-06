# frozen_string_literal: true

require 'db_text_search/case_insensitive/abstract_adapter'
module DbTextSearch
  class CaseInsensitive
    # Provides case-insensitive string-in-set querying by applying the database LOWER function.
    # @api private
    class LowerAdapter < AbstractAdapter
      # (see AbstractAdapter#in)
      def in(values)
        conn = @scope.connection
        @scope.where "LOWER(#{quoted_scope_column}) IN (#{values.map { |v| "LOWER(#{conn.quote(v)})" }.join(', ')})"
      end

      # (see AbstractAdapter#like)
      def like(query)
        @scope.where "LOWER(#{quoted_scope_column}) LIKE LOWER(?)", query
      end

      # (see AbstractAdapter.add_index)
      def self.add_index(connection, table_name, column_name, options = {})
        unsupported = -> { DbTextSearch.unsupported_adapter! connection }
        DbTextSearch.match_adapter(
            connection,
            # TODO: Switch to native Rails support once it lands.
            # https://github.com/rails/rails/pull/18499
            postgres: -> {
              options              = options.dup
              options[:name]       ||= "#{table_name}_#{column_name}_lower"
              options[:expression] = "(LOWER(#{connection.quote_column_name(column_name)}) text_pattern_ops)"
              if defined?(::SchemaPlus)
                connection.add_index(table_name, column_name, options)
              else
                connection.exec_query quoted_create_index(connection, table_name, **options)
              end
            },
            mysql:    unsupported,
            sqlite:   unsupported)
      end
    end
  end
end
