require 'rails_helper'

module Search
  RSpec.describe Search, type: :model do

    describe 'searching' do
      it 'should return all documents with this words' do
        search = Search.new

        search.index("hello world")
        search.index("hello mate")
        search.index("Cat is black")
        search.index("Brown cat is black")
        search.index("Hello brown cat")

        puts search.search("hell")

      end
    end
  end

end