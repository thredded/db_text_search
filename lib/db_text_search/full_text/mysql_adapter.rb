# frozen_string_literal: true

require 'db_text_search/full_text/abstract_adapter'
module DbTextSearch
  class FullText
    # Provides basic FTS support for MySQL.
    #
    # Runs a `MATCH AGAINST` query against a `FULLTEXT` index.
    #
    # @note MySQL v5.6.4+ is required.
    # @api private
    class MysqlAdapter < AbstractAdapter
      # (see AbstractAdapter#search)
      def search(terms, pg_ts_config:)
        @scope.where("MATCH (#{quoted_scope_column}) AGAINST (?)", terms.uniq.join(' '))
      end

      # (see AbstractAdapter.add_index)
      def self.add_index(connection, table_name, column_name, name:, pg_ts_config:)
        connection.add_index table_name, column_name, name: name, type: :fulltext
      end
    end
  end
end
