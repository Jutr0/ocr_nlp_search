require 'rails_helper'
module Users
  RSpec.describe UsersController, type: :controller do
    include Devise::Test::ControllerHelpers
    include_examples 'basic_seed'

    describe 'GET #index' do
      include_examples 'an superadmin-only endpoint', method: :get, action: :index

      it 'returns list of users when superadmin signed in' do
        sign_in superadmin
        get :index, format: :json

        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        expect(json).to be_an(Array)
        emails = json.map { |u| u['email'] }
        expect(emails).to include(superadmin.email, user.email)
      end

      it 'renders the expected fields for each user' do
        sign_in superadmin
        get :index, format: :json
        expect(response.body).to match_schema('users')
      end
    end

    describe 'GET #show' do
      include_examples 'an superadmin-only endpoint', method: :get, action: :show, params_proc: -> { { id: user.id } }

      it 'returns user data when superadmin signed in' do
        sign_in superadmin
        get :show, params: { id: user.id }, format: :json

        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        expect(json['id']).to eq(user.id)
        expect(json['email']).to eq(user.email)
      end

      it 'renders the expected fields for user' do
        sign_in superadmin
        get :show, params: { id: user.id }, format: :json
        expect(response.body).to match_schema('user')
      end
    end

    describe 'POST #create' do
      let(:user_params) do
        {
          email: 'new@example.com',
          password: 'password123',
          password_confirmation: 'password123',
          role: 'user'
        }
      end

      include_examples 'an superadmin-only endpoint', method: :post, action: :create, params_proc: -> { { user: user_params } }

      it 'creates a new user when superadmin signed in' do
        sign_in superadmin
        expect {
          post :create, params: { user: user_params }, format: :json
        }.to change(Users::User, :count).by(1)

        expect(response).to have_http_status(:created)
        json = JSON.parse(response.body)
        expect(json['email']).to eq('new@example.com')
        expect(json['role']).to eq('user')
      end

      it 'renders the expected fields for created user' do
        sign_in superadmin
        post :create, params: { user: user_params }, format: :json
        expect(response.body).to match_schema('created_user')
      end
    end

    describe 'PATCH #update' do
      let(:update_params) { { email: 'updated@example.com' } }

      include_examples 'an superadmin-only endpoint',
                       method: :patch,
                       action: :update,
                       params_proc: -> { { id: user.id, user: update_params } }

      it 'updates user when superadmin signed in' do
        sign_in superadmin
        patch :update, params: { id: user.id, user: update_params }, format: :json

        expect(response).to have_http_status(:ok)
        expect(user.reload.email).to eq('updated@example.com')
        json = JSON.parse(response.body)
        expect(json['email']).to eq('updated@example.com')
      end

      it 'renders the expected fields for updated user' do
        sign_in superadmin
        patch :update, params: { id: user.id, user: update_params }, format: :json
        expect(response.body).to match_schema('updated_user')
      end
    end

    describe 'DELETE #destroy' do
      include_examples 'an superadmin-only endpoint', method: :delete, action: :destroy, params_proc: -> { { id: user.id } }

      it 'destroys user when superadmin signed in' do
        sign_in superadmin
        expect {
          delete :destroy, params: { id: user.id }, format: :json
        }.to change(Users::User, :count).by(-1)

        expect(response).to have_http_status(:no_content)
      end
    end
  end
end
