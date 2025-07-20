require 'rails_helper'

module Search
  RSpec.describe Search, type: :model do

    describe 'searching' do
      it 'should return all documents with this words' do
        Search.kaboom_files!
        search = Search.new

        search.index("hello world", 12)
        search.index("hello mate", 23)
        search.index("Cat is black", 34)
        search.index("Brown cat is black", 45)
        search.index("Hello brown cat", 56)
        search.index("Hell is where brownie blame category", 67)

        search.flush!

        # expect(search.search("hello")).to eq(["hello world", "hello mate", "Hello brown cat"])
        # expect(search.search("Cat")).to eq(["Cat is black", "Brown cat is black", "Hello brown cat"])
        expect(search.search("hello bro blame")).to eq(["hello world", "hello mate", "Hello brown cat", "Hell is where brownie blame category"])

      end
    end
  end

end