module DbTextSearch
  class FullTextSearch
    # A base class for FullTextSearch adapters.
    class AbstractAdapter
      include ::DbTextSearch::QueryBuilding
      DEFAULT_PG_TS_CONFIG = %q('english')

      # @param scope [ActiveRecord::Relation, Class<ActiveRecord::Base>]
      # @param column [Symbol] name
      def initialize(scope, column)
        @scope  = scope
        @column = column
      end

      # @param terms [Array<String>]
      # @return [ActiveRecord::Relation]
      def find(terms)
        @scope.where(*where_args(terms))
      end

      # @param terms [Array<String>]
      # @param options [Hash]
      # @option options pg_ts_config [String] a pg text search config. Default: 'english'
      # @return [query fragment, binds]
      # @abstract
      def where_args(terms, options = {})
        fail 'abstract'
      end

      # Add an index for full text search.
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

      protected

      def parse_search_options(options = {})
        options.assert_valid_keys(:pg_ts_config)
        options.reverse_merge(pg_ts_config: DEFAULT_PG_TS_CONFIG)
      end
    end
  end
end
