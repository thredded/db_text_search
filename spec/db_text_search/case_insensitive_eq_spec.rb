require 'spec_helper'

module DbTextSearch
  RSpec.describe CaseInsensitiveEq do
    column_cases = [['case-insensitive', :ci_name], ['case-sensitive', :cs_name]]
    describe '#find(value)' do
      let!(:records) { %w(ABC abC abc).map { |name| Name.create!(ci_name: name, cs_name: name) } }
      column_cases.each do |(column_desc, column)|
        it "works with a #{column_desc} column" do
          finder = CaseInsensitiveEq.new(Name, column)
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
          force_index { expect(CaseInsensitiveEq.new(Name, column).find('aBc')).to_not use_index(index_name) }
          begin
            CaseInsensitiveEq.add_index Name.connection, :names, column, name: index_name
            force_index { expect(CaseInsensitiveEq.new(Name, column).find('aBc')).to use_index(index_name) }
          ensure
            if Name.connection.adapter_name =~ /postgres/i
              # Work around https://github.com/rails/rails/issues/24359
              Name.connection.exec_query %Q(DROP INDEX #{index_name})
            else
              ActiveRecord::Migration.remove_index :names, name: index_name
            end
          end
        end
      end

      describe CaseInsensitiveEq::LowerAdapter do
        it 'throws an error for MySQL case-insensitive index for case-sensitive column' do
          mock_connection = Struct.new(:adapter_name).new('MySQL')
          expect {
            CaseInsensitiveEq::LowerAdapter.add_index(mock_connection, :names, :name)
          }.to raise_error(ArgumentError,
                           'MySQL case-insensitive index creation for case-sensitive columns is not supported.')
        end

        it 'throws an error for an invalid adapter' do
          mock_connection = Struct.new(:adapter_name).new('AnInvalidAdapter')
          expect {
            CaseInsensitiveEq::LowerAdapter.add_index(mock_connection, :names, :name)
          }.to raise_error(ArgumentError,
                           'Cannot create a case-insensitive index for case-sensitive column on AnInvalidAdapter.')
        end
      end
    end

    describe '.add_ci_text_column' do
      column = :ci_text
      before :all do
        CaseInsensitiveEq.add_ci_text_column Name.connection, :names, column
        Name.reset_column_information
        ActiveRecord::Base.connection.schema_cache.clear!
      end
      after :all do
        ActiveRecord::Migration.remove_column :names, column
        Name.reset_column_information
        ActiveRecord::Base.connection.schema_cache.clear!
      end
      it 'adds a case-insensitive column' do
        if Name.connection.adapter_name =~ /sqlite/i
          # check not implemented, so just check that a search uses index
          ActiveRecord::Migration.add_index :names, column, name: :"#{column}_index"
          finder = CaseInsensitiveEq.new(Name, column)
          record = Name.create!(ci_name: 'Abc', cs_name: 'Abc', column => 'Abc')
          expect(finder.find('aBc')).to use_index(:"#{column}_index")
          expect(finder.find('aBc').first).to eq record
        else
          expect(CaseInsensitiveEq.column_case_sensitive?(Name.connection, :names, column)).to be_falsey
        end
      end
      it 'fails with ArgumentError on an unknown adapter' do
        mock_connection = Struct.new(:adapter_name).new('AnInvalidAdapter')
        expect {
          CaseInsensitiveEq.add_ci_text_column mock_connection, :names, column
        }.to raise_error(ArgumentError, 'Unsupported adapter AnInvalidAdapter')
      end
    end

    describe '.column_case_sensitive?' do
      it 'is truthy for a case-sensitive column' do
        skip 'not implemented for SQLite' if Name.connection.adapter_name =~ /sqlite/i
        expect(CaseInsensitiveEq.column_case_sensitive?(Name.connection, :names, :cs_name)).to be_truthy
      end

      it 'is falsey for a case-insensitive column' do
        skip 'not implemented for SQLite' if Name.connection.adapter_name =~ /sqlite/i
        expect(CaseInsensitiveEq.column_case_sensitive?(Name.connection, :names, :ci_name)).to be_falsey
      end

      it 'fails with ArgumentError on an unknown adapter' do
        mock_connection = double('Connection', adapter_name: 'AnInvalidAdapter', schema_cache: double(columns: []))
        expect {
          CaseInsensitiveEq.column_case_sensitive? mock_connection, :names, :a_column
        }.to raise_error(ArgumentError, 'Unsupported adapter AnInvalidAdapter')
      end
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
      ActiveRecord::Base.connection.schema_cache.clear!
    end

    after :all do
      ActiveRecord::Migration.drop_table :names
      ActiveRecord::Base.connection.schema_cache.clear!
    end
  end
end
