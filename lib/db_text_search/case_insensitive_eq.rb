require 'db_text_search/case_insensitive_eq/insensitive_column_adapter'
require 'db_text_search/case_insensitive_eq/lower_adapter'
require 'db_text_search/case_insensitive_eq/collate_nocase_adapter'

module DbTextSearch
  # Provides case-insensitive string-in-set querying, and CI index creation.
  class CaseInsensitiveEq
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

    # Adds a case-insensitive column to the given table.
    # @param connection [ActiveRecord::ConnectionAdapters::AbstractAdapter]
    # @param table_name [String, Symbol]
    # @param column_name [String, Symbol]
    # @param options [Hash]
    def self.add_ci_text_column(connection, table_name, column_name, options = {})
      case connection.adapter_name.downcase
        when /mysql/
          connection.add_column(table_name, column_name, :text, options)
        when /postgres/
          connection.enable_extension 'citext'
          if ActiveRecord::VERSION::MAJOR >= 4 && ActiveRecord::VERSION::MINOR >= 2
            connection.add_column(table_name, column_name, :citext, options)
          else
            connection.add_column(table_name, column_name, 'CITEXT', options)
          end
        when /sqlite/
          if ActiveRecord::VERSION::MAJOR >= 5
            connection.add_column(table_name, column_name, :text, options.merge(collation: 'NOCASE'))
          else
            connection.add_column(table_name, column_name, 'TEXT COLLATE NOCASE', options)
          end
        else
          fail "Unsupported adapter #{connection.adapter_name}"
      end
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
    # @api private
    def self.column_case_sensitive?(connection, table_name, column_name)
      column = connection.schema_cache.columns(table_name).detect { |c| c.name == column_name.to_s }
      case connection.adapter_name.downcase
        when /mysql/
          column.case_sensitive?
        when /postgres/
          column.sql_type !~ /citext/i
        else
          fail "Unsupported adapter #{connection.adapter_name}"
      end
    end
  end
end
