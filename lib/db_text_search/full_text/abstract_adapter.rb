# frozen_string_literal: true

module DbTextSearch
  class FullText
    # A base class for FullText adapters.
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

      # @param terms [Array<String>]
      # @param pg_ts_config [String] a pg text search config
      # @return [ActiveRecord::Relation]
      # @abstract
      def search(terms, pg_ts_config:)
        fail 'abstract'
      end

      # Add an index for full text search.
      #
      # @param connection [ActiveRecord::ConnectionAdapters::AbstractAdapter]
      # @param table_name [String, Symbol]
      # @param column_name [String, Symbol]
      # @param name [String, Symbol] index name
      # @param pg_ts_config [String] for Postgres, the TS config to use; ignored for non-postgres.
      # @abstract
      def self.add_index(connection, table_name, column_name, name:, pg_ts_config:)
        fail 'abstract'
      end
    end
  end
end
