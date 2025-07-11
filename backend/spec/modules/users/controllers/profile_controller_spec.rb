require 'rails_helper'

RSpec.describe Users::ProfileController, type: :controller do
  include Devise::Test::ControllerHelpers
  include_examples 'basic_seed'

  describe 'GET #me' do

    it 'should return user data' do
      sign_in user
      get :me, format: :json

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['id']).to eq(user.id)
      expect(json['email']).to eq(user.email)
      expect(json['role']).to eq(user.role)
    end

    it 'should fail if user is not signed' do
      get :me, format: :json
      expect(response).to have_http_status(:unauthorized)
    end
  end
end