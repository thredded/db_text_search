# frozen_string_literal: true

require 'spec_helper'

module DbTextSearch
  RSpec.describe FullText do
    let!(:post_midsummer) { Post.create!(content: 'Love looks not with the eyes, but with the mind;') }
    let!(:post_richard) { Post.create!(content: 'An honest tale speeds best, being plainly told.') }
    let!(:post_well) { Post.create!(content: 'Love all, trust a few, do wrong to none.') }

    around { |ex| force_index { ex.call } }
    it '#find(terms) with index' do
      index_name = :index_posts_content_fts
      FullText.add_index(Post.connection, :posts, :content, name: index_name)
      finder = FullText.new(Post, :content)
      expect(finder.find('love').to_a).to eq [post_midsummer, post_well]
      expect(finder.find(%w(honest plainly)).to_a).to eq [post_richard]
      expect(finder.find(%w(trust)).to_a).to eq [post_well]
      expect(finder.find('Shakespeare').to_a).to be_empty
      unless Post.connection.adapter_name =~ /sqlite/i
        expect(finder.find('love')).to use_index(index_name)
      end
    end

    describe '.add_index' do
      it 'fails with ArgumentError on an unknown adapter' do
        mock_connection = Struct.new(:adapter_name).new('AnInvalidAdapter')
        expect {
          FullText.add_index mock_connection, :posts, :content
        }.to raise_error(ArgumentError, 'Unsupported adapter AnInvalidAdapter')
      end
    end

    class Post < ActiveRecord::Base
    end

    before :all do
      ActiveRecord::Schema.define do
        self.verbose = false
        create_table :posts do |t|
          t.text :content, null: false
        end
      end
      ActiveRecord::Base.connection.schema_cache.clear!
    end

    after :all do
      ActiveRecord::Migration.drop_table :posts
      ActiveRecord::Base.connection.schema_cache.clear!
    end
  end
end
