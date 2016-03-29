require 'db_text_search/case_insensitive_string_finder/insensitive_column_adapter'
require 'db_text_search/case_insensitive_string_finder/lower_adapter'
require 'db_text_search/case_insensitive_string_finder/collate_nocase_adapter'

module DbTextSearch
  class CaseInsensitiveStringFinder
    # (see Adapter)
    def initialize(scope, column)
      @adapter = self.class.adapter_class(scope.connection, scope.table_name, column).new(scope, column)
      @scope   = scope
    end

    # @param value_or_values [String, Array<String>]
    # @return (see Adapter#find)
    def find(value_or_values)
      values = Array(value_or_values)
      return @scope.none if values.empty?
      @adapter.find(values)
    end

    # (see Adapter.add_index)
    def self.add_index(connection, table_name, column_name, options = {})
      adapter_class(connection, table_name, column_name).add_index(connection, table_name, column_name, options)
    end

    # @param connection [ActiveRecord::ConnectionAdapters::AbstractAdapter]
    # @param table_name [String, Symbol]
    # @param column_name [String, Symbol]
    # @return [Class<Adapter>]
    def self.adapter_class(connection, table_name, column_name)
      if connection.adapter_name.downcase =~ /sqlite/
        # Always use COLLATE NOCASE for SQLite, as we can't check if the column is case-sensitive.
        # It has no performance impact apart from slightly longer query strings for case-insensitive columns.
        CollateNocaseAdapter
      elsif column_case_sensitive?(connection, table_name, column_name)
        LowerAdapter
      else
        InsensitiveColumnAdapter
      end
    end

    # @param connection [ActiveRecord::ConnectionAdapters::AbstractAdapter]
    # @param table_name [String, Symbol]
    # @param column_name [String, Symbol]
    # @return [Boolean]
    # @note sqlite not supported.
    def self.column_case_sensitive?(connection, table_name, column_name)
      column = connection.columns(table_name).detect { |c| c.name == column_name.to_s }
      case connection.adapter_name.downcase
        when /mysql/
          column.case_sensitive?
        when /postgresql/
          column.sql_type !~ /citext/i
        else
          fail "Unsupported adapter #{connection.adapter_name}"
      end
    end
  end
end
