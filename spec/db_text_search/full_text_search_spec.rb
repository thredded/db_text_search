require 'spec_helper'

module DbTextSearch
  RSpec.describe FullTextSearch do
    let!(:post_midsummer) { Post.create!(
        content: 'Love looks not with the eyes, but with the mind; and therefore is winged Cupid painted blind.') }
    let!(:post_richard) { Post.create!(content: 'An honest tale speeds best, being plainly told.') }
    let!(:post_well) { Post.create!(content: 'Love all, trust a few, do wrong to none.') }

    around { |ex| force_index { ex.call } }
    it '#find(terms) with index' do
      index_name = :index_posts_content_fts
      FullTextSearch.add_index(Post.connection, :posts, :content, name: index_name)
      finder = FullTextSearch.new(Post, :content)
      expect(finder.find('love').to_a).to eq [post_midsummer, post_well]
      expect(finder.find(%w(honest plainly)).to_a).to eq [post_richard]
      expect(finder.find(%w(trust)).to_a).to eq [post_well]
      expect(finder.find('Shakespeare').to_a).to be_empty
      unless Post.connection.adapter_name =~ /sqlite/i
        expect(finder.find('love')).to use_index(index_name)
      end
    end

    #describe '.add_index' do
    #end

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
