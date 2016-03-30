# frozen_string_literal: true

require 'db_text_search/case_insensitive_eq/abstract_adapter'
module DbTextSearch
  class CaseInsensitiveEq
    # Provides case-insensitive string-in-set querying by applying the database LOWER function.
    # @api private
    class LowerAdapter < AbstractAdapter
      # (see AbstractAdapter#find)
      def find(values)
        conn = @scope.connection
        @scope.where "LOWER(#{quoted_scope_column}) IN (#{values.map { |v| "LOWER(#{conn.quote(v)})" }.join(', ')})"
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
              options[:expression] = "(LOWER(#{connection.quote_column_name(column_name)}))"
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
