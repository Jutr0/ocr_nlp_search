require 'rails_helper'

RSpec.describe "Profile", type: :request do
  let(:headers) { { 'ACCEPT' => 'application/json' } }

  include_examples 'basic_seed'

  describe 'GET /profile/me' do
    include_examples 'an signed-only endpoint', method: :get, path: '/profile/me'
    context 'when user is signed in' do
      before do
        sign_in user
        get '/profile/me', headers: headers
      end

      it 'returns a 200 status' do
        expect(response).to have_http_status(:ok)
      end

      it 'returns his data' do
        json = JSON.parse(response.body)
        expect(json).to match('id' => user.id,
                              'email' => user.email,
                              'role' => user.role)
      end

      it 'renders the expected fields for profile' do
        expect(response.body).to match_schema('user_profile')
      end
    end
  end
end
