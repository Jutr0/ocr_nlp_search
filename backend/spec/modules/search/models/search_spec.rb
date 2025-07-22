require 'rails_helper'

module Search
  RSpec.describe Search, type: :model do

    describe 'searching' do
      it 'should return all documents with this words' do
        Search.kaboom_files!
        search = Search.new

        search.index("hello world Hello", 12)
        search.index("hello mate", 23)
        search.index("Cat is black", 34)
        search.index("Brown cat is black", 45)
        search.index("Hello brown cat", 56)
        search.index("Hell is where brownie blame category", 67)

        search.flush!

        search.index("Hello brown cat", 562)
        search.index("Hell is where a brownie blame category", 672)

        search.flush!

        # For 'OR' search with multiple words
        expect(search.search("hello    a no here")).to eq(["12", "23", "56", "562"])
        expect(search.search("Cat")).to eq(["34", "45", "56", "562"])
        expect(search.search("MATE where")).to eq(["23", "67", "672"])

      end
    end
  end

end