require 'rails_helper'

module Search
  RSpec.describe Search, type: :model do

    describe 'searching' do
      it 'should return all documents with this words' do
        search = Search.new
        search.flush!

        search.index("hello world")
        search.index("hello mate")
        search.index("Cat is black")
        search.index("Brown cat is black")
        search.index("Hello brown cat")

        expect(search.search("hello")).to be_empty

        search.flush!

        expect(search.search("hello")).to eq(["hello world", "hello mate", "Hello brown cat"])
        expect(search.search("Cat")).to eq(["Cat is black", "Brown cat is black", "Hello brown cat"])

      end
    end
  end

end