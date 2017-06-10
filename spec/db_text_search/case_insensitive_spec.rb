# frozen_string_literal: true

require 'spec_helper'

module DbTextSearch
  RSpec.describe CaseInsensitive do
    column_cases = [['case-insensitive', :ci_name], ['case-sensitive', :cs_name]]
    describe '#find(value)' do
      let!(:records) { %w[ABC abC abc].map { |name| Name.create!(ci_name: name, cs_name: name) } }
      column_cases.each do |(column_desc, column)|
        it "works with a #{column_desc} column" do
          finder = CaseInsensitive.new(Name, column)
          expect(finder.in('aBc').to_a).to eq records
        end
      end
    end

    describe '#prefix(query)' do
      let!(:records) { %w[Joe john jack jill x%zz].map { |name| Name.create!(ci_name: name, cs_name: name) } }
      column_cases.each do |(column_desc, column)|
        it "works with a #{column_desc} column" do
          finder = CaseInsensitive.new(Name, column)
          expect(finder.prefix('Jo').to_a).to eq records.first(2)
          expect(finder.prefix('x%Z').to_a).to eq [records.last]
        end
      end
    end

    describe '.add_index' do
      column_cases.each do |(column_desc, column)|
        index_name = :an_index

        it 'does not use an index when there is none (sanity check)' do
          force_index { expect(CaseInsensitive.new(Name, column).in('aBc')).to_not use_index(index_name) }
        end

        describe "adds a usable index on a #{column_desc} column" do
          before :all do
            if Name.connection.adapter_name =~ /mysql/i && column == :cs_name
              skip 'MySQL case-insensitive index creation for case-sensitive columns is not yet implemented'
            end
            CaseInsensitive.add_index Name.connection, :names, column, name: index_name
          end

          after :all do
            if Name.connection.adapter_name =~ /mysql/i && column == :cs_name
              next
            end
            if Name.connection.adapter_name =~ /postg/i
              # Work around https://github.com/rails/rails/issues/24359
              Name.connection.exec_query "DROP INDEX #{index_name}"
            else
              ActiveRecord::Migration.remove_index :names, name: index_name
            end
          end

          it 'uses an index for #find' do
            force_index { expect(CaseInsensitive.new(Name, column).in('aBc')).to use_index(index_name) }
          end
          it 'uses an index for #prefix' do
            if Name.connection.adapter_name =~ /postg/i && column == :ci_name
              skip 'PostgreSQL does not use a LIKE index on citext columns'
            end
            force_index { expect(CaseInsensitive.new(Name, column).prefix('A')).to use_index(index_name) }
          end
        end
      end

      describe CaseInsensitive::LowerAdapter do
        it 'throws an error for MySQL case-insensitive index for case-sensitive column' do
          mock_connection = Struct.new(:adapter_name).new('MySQL')
          expect {
            CaseInsensitive::LowerAdapter.add_index(mock_connection, :names, :name)
          }.to raise_error(ArgumentError, 'Unsupported adapter MySQL')
        end

        it 'throws an error for an invalid adapter' do
          mock_connection = Struct.new(:adapter_name).new('AnInvalidAdapter')
          expect {
            CaseInsensitive::LowerAdapter.add_index(mock_connection, :names, :name)
          }.to raise_error(ArgumentError, 'Unsupported adapter AnInvalidAdapter')
        end
      end
    end

    describe '.add_ci_text_column' do
      column = :ci_text
      before :all do
        CaseInsensitive.add_ci_text_column Name.connection, :names, column
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
          finder = CaseInsensitive.new(Name, column)
          record = Name.create!(ci_name: 'Abc', cs_name: 'Abc', column => 'Abc')
          expect(finder.in('aBc')).to use_index(:"#{column}_index")
          expect(finder.in('aBc').first).to eq record
        else
          expect(CaseInsensitive.column_case_sensitive?(Name.connection, :names, column)).to be_falsey
        end
      end
      it 'fails with ArgumentError on an unknown adapter' do
        mock_connection = Struct.new(:adapter_name).new('AnInvalidAdapter')
        expect {
          CaseInsensitive.add_ci_text_column mock_connection, :names, column
        }.to raise_error(ArgumentError, 'Unsupported adapter AnInvalidAdapter')
      end
    end

    describe '.column_case_sensitive?' do
      it 'is truthy for a case-sensitive column' do
        skip 'not implemented for SQLite' if Name.connection.adapter_name =~ /sqlite/i
        expect(CaseInsensitive.column_case_sensitive?(Name.connection, :names, :cs_name)).to be_truthy
      end

      it 'is falsey for a case-insensitive column' do
        skip 'not implemented for SQLite' if Name.connection.adapter_name =~ /sqlite/i
        expect(CaseInsensitive.column_case_sensitive?(Name.connection, :names, :ci_name)).to be_falsey
      end

      it 'fails with ArgumentError on an unknown adapter and sqlite' do
        %w[SQLite UnknownAdapter].each do |adapter_name|
          mock_connection = double('Connection', adapter_name: adapter_name, schema_cache: double(columns: []))
          expect {
            CaseInsensitive.column_case_sensitive? mock_connection, :names, :a_column
          }.to raise_error(ArgumentError, "Unsupported adapter #{adapter_name}")
        end
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
          DbTextSearch.match_adapter(
              connection,
              mysql:    -> {
                t.string :ci_name
                t.column :cs_name, 'VARCHAR(191) COLLATE utf8_bin'
              },
              postgres: -> {
                begin
                  connection.enable_extension 'citext'
                rescue ActiveRecord::StatementInvalid
                  raise "Please run the command below to enable the 'citext' Postgres extension:\n" \
                         "#{psql_su_cmd} -d #{ActiveRecord::Base.connection_config[:database]} " \
                         "-c 'CREATE EXTENSION citext;'"
                end
                t.column :ci_name, 'CITEXT'
                t.string :cs_name
              },
              sqlite:   -> {
                t.column :ci_name, 'VARCHAR(191) COLLATE NOCASE'
                t.string :cs_name
              }
          )
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
