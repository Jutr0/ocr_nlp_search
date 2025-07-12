require 'rails_helper'
module Users
  RSpec.describe Users::ProfileController, type: :controller do
    include Devise::Test::ControllerHelpers
    include_examples 'basic_seed'

    describe 'GET #me' do
      include_examples 'an signed-only endpoint', :get, :me

      it 'return currently signed user data' do
        sign_in user
        get :me, format: :json

        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        expect(json['id']).to eq(user.id)
        expect(json['email']).to eq(user.email)
        expect(json['role']).to eq(user.role)
      end

      it 'renders the expected fields for profile' do
        sign_in user
        get :me, format: :json
        expect(response.body).to match_schema('user_profile')
      end

    end
  end
end