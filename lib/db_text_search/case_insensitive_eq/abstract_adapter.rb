require 'db_text_search/query_building'
module DbTextSearch
  class CaseInsensitiveEq
    # A base class for CaseInsensitiveStringFinder adapters.
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
      def find(values)
        fail 'abstract'
      end

      # Add an index for case-insensitive string search.
      #
      # @param connection [ActiveRecord::ConnectionAdapters::AbstractAdapter]
      # @param table_name [String, Symbol]
      # @param column_name [String, Symbol]
      # @param options [Hash] passed down to ActiveRecord::ConnectionAdapters::SchemaStatements#add_index.
      # @return (see ActiveRecord::ConnectionAdapters::SchemaStatements#add_index)
      # @abstract
      def self.add_index(connection, table_name, column_name, options = {})
        fail 'abstract'
      end
    end
  end
end
