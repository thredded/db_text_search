require 'spec_helper'

module DbTextSearch
  RSpec.describe CaseInsensitiveStringFinder do
    it '#find(value)' do
      names  = %w(ABC abC abc).map { |name| Name.create!(name: name) }
      finder = CaseInsensitiveStringFinder.new(Name, :name)
      expect(finder.find('aBc').to_a).to eq names
    end


    class Name < ActiveRecord::Base
    end

    before do
      Name.delete_all
    end

    before :all do
      ActiveRecord::Schema.define do
        self.verbose = false
        create_table :names do |t|
          t.string :name
        end
      end
    end

    after :all do
      ActiveRecord::Migration.drop_table :names
    end
  end
end
