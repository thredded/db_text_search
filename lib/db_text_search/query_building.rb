# frozen_string_literal: true

module DbTextSearch
  # Common methods for building SQL that use @scope and @column instance variables.
  # @api private
  module QueryBuilding
    def self.included(base) # :nodoc:
      base.extend ClassMethods
    end

    # @return [String] SQL-quoted string suitable for use in a LIKE statement, with % and _ escaped.
    def sanitize_sql_like(string, escape_character = '\\')
      pattern = Regexp.union(escape_character, '%', '_')
      string.gsub(pattern) { |x| [escape_character, x].join }
    end

    protected

    # @return [String] SQL-quoted scope table name.
    def quoted_scope_table
      @scope.connection.quote_table_name(@scope.table_name)
    end

    # @return [String] SQL-quoted column (without the table name).
    def quoted_column
      @scope.connection.quote_column_name(@column)
    end

    # @return [String] SQL-quoted column fully-qualified with the scope table name.
    def quoted_scope_column
      "#{quoted_scope_table}.#{quoted_column}"
    end

    # Common methods for building SQL
    # @api private
    module ClassMethods
      protected

      # @return [String] a CREATE INDEX statement
      def quoted_create_index(connection, table_name, name:, expression:, unique: false)
        "CREATE #{'UNIQUE ' if unique}INDEX #{name} ON #{connection.quote_table_name(table_name)} #{expression}"
      end
    end
  end
end
