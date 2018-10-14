# frozen_string_literal: true

require 'db_text_search/query_building'
module DbTextSearch
  class CaseInsensitive
    # A base class for CaseInsensitiveStringFinder adapters.
    # @abstract
    # @api private
    class AbstractAdapter
      include ::DbTextSearch::QueryBuilding

      # @param scope [ActiveRecord::Relation, Class<ActiveRecord::Base>]
      # @param column [Symbol] name
      def initialize(scope, column)
        @scope  = scope
        @column = column
      end

      # @param values [Array<String>]
      # @return [ActiveRecord::Relation]
      # @abstract
      def in(values)
        fail 'abstract'
      end

      # @param query [String]
      # @return [ActiveRecord::Relation]
      # @abstract
      def prefix(query)
        fail 'abstract'
      end

      # @param asc_or_desc [Symbol]
      # @return [Arel::Collectors::SQLString]
      # @abstract
      def column_for_order(asc_or_desc)
        fail 'abstract'
      end

      # Add an index for case-insensitive string search.
      #
      # @param connection [ActiveRecord::ConnectionAdapters::AbstractAdapter]
      # @param table_name [String, Symbol]
      # @param column_name [String, Symbol]
      # @param options [Hash] passed down to ActiveRecord::ConnectionAdapters::SchemaStatements#add_index.
      # @option options name [String] index name
      # @option options unique [Boolean] default: false
      # @abstract
      def self.add_index(connection, table_name, column_name, options = {})
        fail 'abstract'
      end
    end
  end
end
