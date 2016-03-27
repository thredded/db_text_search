module DbTextSearch
  class CaseInsensitiveStringFinder
    class InsensitiveByDefaultAdapter
      # @param [ActiveRecord::Relation, Class<ActiveRecord::Base>] scope
      # @param [Symbol] column name
      def initialize(scope, column)
        @scope  = scope
        @column = column
      end

      # @param [Array<String>] values
      # @return [ActiveRecord::Relation]
      def find(values)
        @scope.where(@column => values)
      end
    end
  end
end
