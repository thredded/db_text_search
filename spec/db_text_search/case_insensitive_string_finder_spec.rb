require 'spec_helper'

module DbTextSearch
  RSpec.describe CaseInsensitiveStringFinder do
    it '#find(value)' do
      names  = %w(ABC abC abc).map { |name| Name.create!(name: name) }
      finder = CaseInsensitiveStringFinder.new(Name, :name)
      expect(finder.find('aBc').to_a).to eq names
    end

    describe '.add_index' do
      index_name = :index_name_ci
      context 'called' do
        before(:all) { CaseInsensitiveStringFinder.add_index Name.connection, :names, :name, name: index_name }
        after(:all) { ActiveRecord::Migration.remove_index :names, name: index_name }

        it 'the index is usable by #find' do
          finder = CaseInsensitiveStringFinder.new(Name, :name)
          force_index { expect(finder.find('aBc')).to use_index(index_name) }
        end
      end
      context 'not called' do
        it 'no index usable by #find' do
          finder = CaseInsensitiveStringFinder.new(Name, :name)
          force_index { expect(finder.find('aBc')).to_not use_index(index_name) }
        end
      end
    end

    # TODO tests
    if ENV['DB'] =~ /postgresql/i
      xcontext 'citext column'
    elsif ENV['DB'] =~ /mysql/i
      xcontext 'case-sensitive collation column'
    elsif ENV['DB'] =~ /sqlite/i
      xcontext 'COLLATE NOCASE column'
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
