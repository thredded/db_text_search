module DbTextSearch
  module QueryBuilding
    protected

    def quoted_scope_table
      @scope.connection.quote_table_name(@scope.table_name)
    end

    def quoted_column
      @scope.connection.quote_column_name(@column)
    end

    def quoted_scope_column
      "#{quoted_scope_table}.#{quoted_column}"
    end

    def sanitize_sql_like(string, escape_character = "\\")
      pattern = Regexp.union(escape_character, '%', '_')
      string.gsub(pattern) { |x| [escape_character, x].join }
    end
  end
end
