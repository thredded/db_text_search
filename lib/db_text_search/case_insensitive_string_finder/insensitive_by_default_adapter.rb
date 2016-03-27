require 'db_text_search/case_insensitive_string_finder/adapter'
module DbTextSearch
  class CaseInsensitiveStringFinder
    class InsensitiveByDefaultAdapter < Adapter
      # (see Adapter#initialize)
      def initialize(scope, column)
        @scope  = scope
        @column = column
      end

      # (see Adapter#find)
      def find(values)
        @scope.where(@column => values)
      end
    end
  end
end
