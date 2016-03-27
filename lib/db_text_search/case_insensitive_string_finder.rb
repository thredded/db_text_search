require 'db_text_search/case_insensitive_string_finder/insensitive_by_default_adapter'
require 'db_text_search/case_insensitive_string_finder/lower_adapter'
require 'db_text_search/case_insensitive_string_finder/collate_nocase_adapter'

module DbTextSearch
  class CaseInsensitiveStringFinder
    # @param scope [ActiveRecord::Relation, Class<ActiveRecord::Base>]
    # @param column [Symbol] column name
    def initialize(scope, column)
      @adapter = self.class.adapter_class(scope.connection.adapter_name).new(scope, column)
      @scope   = scope
    end

    # @param value_or_values [String, Array<String>]
    # @return [ActiveRecord::Relation]
    def find(value_or_values)
      values = Array(value_or_values)
      return @scope.none if values.empty?
      @adapter.find(values)
    end

    # @param adapter_name [String]
    # @return [Class]
    def self.adapter_class(adapter_name)
      case adapter_name.downcase
        when /mysql/
          InsensitiveByDefaultAdapter
        when /postgresql/
          LowerAdapter
        when /sqlite/
          CollateNocaseAdapter
        else
          fail "Please define a CaseInsensitiveStringFinder adapter for #{adapter_name}"
      end
    end
  end
end
