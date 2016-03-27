module DbTextSearch
  class CaseInsensitiveStringFinder
    # A base class for CaseInsensitiveStringFinder adapters, for documentation purposes.
    class Adapter
      # @param scope [ActiveRecord::Relation, Class<ActiveRecord::Base>]
      # @param column [Symbol] name
      def initialize(scope, column)
        fail 'abstract'
      end

      # @param values [Array<String>]
      # @return [ActiveRecord::Relation]
      def find(values)
        fail 'abstract'
      end
    end
  end
end
