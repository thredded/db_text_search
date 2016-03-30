require 'db_text_search/case_insensitive_eq/abstract_adapter'
module DbTextSearch
  class CaseInsensitiveEq
    # Provides case-insensitive string-in-set querying by applying the database LOWER function.
    # @api private
    class LowerAdapter < AbstractAdapter
      # (see AbstractAdapter#find)
      def find(values)
        conn = @scope.connection
        @scope.where "LOWER(#{quoted_scope_column}) IN (#{values.map { |v| "LOWER(#{conn.quote(v.to_s)})" }.join(', ')})"
      end

      # (see AbstractAdapter.add_index)
      def self.add_index(connection, table_name, column_name, options = {})
        if connection.adapter_name =~ /postgres/i
          # TODO: Switch to native Rails support once it lands.
          # https://github.com/rails/rails/pull/18499
          options              = options.dup
          options[:name]       ||= "#{table_name}_#{column_name}_lower"
          options[:expression] = "(LOWER(#{connection.quote_column_name(column_name)}))"
          if defined?(::SchemaPlus)
            connection.add_index(table_name, column_name, options)
          else
            connection.exec_query quoted_create_index(connection, table_name, **options)
          end
        elsif connection.adapter_name =~ /mysql/i
          fail ArgumentError.new('MySQL case-insensitive index creation for case-sensitive columns is not supported.')
        else
          fail ArgumentError.new(
              "Cannot create a case-insensitive index for case-sensitive column on #{connection.adapter_name}.")
        end
      end
    end
  end
end
