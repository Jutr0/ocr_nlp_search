require 'rails_helper'

RSpec.describe "Users", type: :request do
  include_examples 'basic_seed'

  let(:headers) { { 'ACCEPT' => 'application/json' } }

  describe 'GET /users' do
    include_examples 'a superadmin-only endpoint', method: :get, path: '/users'

    it 'returns list of users when superadmin signed in' do
      sign_in superadmin
      get '/users', headers: headers

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json).to be_an(Array)

      emails = json.map { |u| u['email'] }
      expect(emails).to include(superadmin.email, user.email)
    end

    it 'matches the expected fields for each user' do
      sign_in superadmin
      get '/users', headers: headers
      expect(response.body).to match_schema('users')
    end
  end

  describe 'GET /users/:id' do
    include_examples 'a superadmin-only endpoint',
                     method: :get,
                     path_proc: -> { "/users/#{user.id}" }

    it 'returns user data when superadmin signed in' do
      sign_in superadmin
      get "/users/#{user.id}", headers: headers

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['id']).to eq(user.id)
      expect(json['email']).to eq(user.email)
    end

    it 'matches the expected fields for user' do
      sign_in superadmin
      get "/users/#{user.id}", headers: headers
      expect(response.body).to match_schema('user')
    end
  end

  describe 'POST /users' do
    let(:user_params) do
      {
        email: 'new@example.com',
        password: 'password123',
        password_confirmation: 'password123',
        role: 'user'
      }
    end

    include_examples 'a superadmin-only endpoint',
                     method: :post,
                     path: '/users',
                     params_proc: -> { { user: user_params } }

    it 'creates a new user when superadmin signed in' do
      sign_in superadmin

      expect {
        post '/users', params: { user: user_params }, headers: headers
      }.to change(User, :count).by(1)

      expect(response).to have_http_status(:created)
      json = JSON.parse(response.body)
      expect(json['email']).to eq('new@example.com')
      expect(json['role']).to eq('user')
    end

    it 'matches the expected fields for created user' do
      sign_in superadmin
      post '/users', params: { user: user_params }, headers: headers
      expect(response.body).to match_schema('created_user')
    end
  end

  describe 'PATCH /users/:id' do
    let(:update_params) { { email: 'updated@example.com' } }

    include_examples 'a superadmin-only endpoint',
                     method: :patch,
                     path_proc: -> { "/users/#{user.id}" },
                     params_proc: -> { { user: update_params } }

    it 'updates user when superadmin signed in' do
      sign_in superadmin
      patch "/users/#{user.id}", params: { user: update_params }, headers: headers

      expect(response).to have_http_status(:ok)
      expect(user.reload.email).to eq('updated@example.com')

      json = JSON.parse(response.body)
      expect(json['email']).to eq('updated@example.com')
    end

    it 'matches the expected fields for updated user' do
      sign_in superadmin
      patch "/users/#{user.id}", params: { user: update_params }, headers: headers
      expect(response.body).to match_schema('updated_user')
    end
  end

  describe 'DELETE /users/:id' do
    include_examples 'a superadmin-only endpoint',
                     method: :delete,
                     path_proc: -> { "/users/#{user.id}" }

    it 'destroys user when superadmin signed in' do
      sign_in superadmin

      expect {
        delete "/users/#{user.id}", headers: headers
      }.to change(User, :count).by(-1)

      expect(response).to have_http_status(:no_content)
    end
  end
end
