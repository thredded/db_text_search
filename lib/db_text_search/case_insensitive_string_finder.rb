module DbTextSearch
  module CaseInsensitiveStringFinder
    # @param [ActiveRecord::Relation, Class<ActiveRecord::Base>] scope
    # @param [Symbol] column
    def initialize(scope, column)
      @adapter = nil
    end

    # @return [ActiveRecord::Relation]
    def find(string)
      @adapter.find(string)
    end
  end
end
