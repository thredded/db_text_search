require 'spec_helper'

module DbTextSearch
  RSpec.describe CaseInsensitiveStringFinder do
    column_cases = [['case-insensitive', :ci_name], ['case-sensitive', :cs_name]]
    describe '#find(value)' do
      let!(:records) { %w(ABC abC abc).map { |name| Name.create!(ci_name: name, cs_name: name) } }
      column_cases.each do |(column_desc, column)|
        it "works with a #{column_desc} column" do
          finder = CaseInsensitiveStringFinder.new(Name, column)
          expect(finder.find('aBc').to_a).to eq records
        end
      end
    end

    describe '.add_index' do
      column_cases.each do |(column_desc, column)|
        it "adds an index is usable by #find on a #{column_desc} column" do
          if Name.connection.adapter_name =~ /mysql/i && column == :cs_name
            skip 'MySQL case-insensitive index creation for case-sensitive columns is not yet implemented'
          end
          index_name = :an_index
          force_index { expect(CaseInsensitiveStringFinder.new(Name, column).find('aBc')).to_not use_index(index_name) }
          begin
            CaseInsensitiveStringFinder.add_index Name.connection, :names, column, name: index_name
            force_index { expect(CaseInsensitiveStringFinder.new(Name, column).find('aBc')).to use_index(index_name) }
          ensure
            ActiveRecord::Migration.remove_index :names, name: index_name
          end
        end
      end
    end

    it '.column_case_sensitive?' do
      skip 'not implemented' if Name.connection.adapter_name =~ /sqlite/i
      expect(CaseInsensitiveStringFinder.column_case_sensitive?(Name.connection, :names, :cs_name)).to be_truthy
      expect(CaseInsensitiveStringFinder.column_case_sensitive?(Name.connection, :names, :ci_name)).to be_falsey
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
          case connection.adapter_name
            when /mysql/i
              t.string :ci_name
              t.column :cs_name, 'VARCHAR(191) COLLATE utf8_bin'
            when /postgres/i
              begin
                connection.enable_extension 'citext'
              rescue ActiveRecord::StatementInvalid
                fail "Please run the command below to enable the 'citext' Postgres extension:\n" <<
                         "#{psql_su_cmd} -d #{ActiveRecord::Base.connection_config[:database]} -c 'CREATE EXTENSION citext;'"
              end
              t.column :ci_name, 'CITEXT'
              t.string :cs_name
            when /sqlite/i
              t.column :ci_name, 'VARCHAR(191) COLLATE NOCASE'
              t.string :cs_name
            else
              fail "unknown adapter #{connection.adapter_name}"
          end
        end
      end
    end

    after :all do
      ActiveRecord::Migration.drop_table :names
    end
  end
end
