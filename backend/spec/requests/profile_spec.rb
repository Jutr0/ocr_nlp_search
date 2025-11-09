require 'rails_helper'

RSpec.describe "Profile", type: :request do
  let(:headers) { { 'ACCEPT' => 'application/json' } }

  include_examples 'basic_seed'

  describe 'GET api/profile/me' do
    include_examples 'a signed-only endpoint', method: :get, path: '/api/profile/me'

    context 'when signed in as user' do
      before do
        sign_in user
        get '/api/profile/me', headers: headers
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
