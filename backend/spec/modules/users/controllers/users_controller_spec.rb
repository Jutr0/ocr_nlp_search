require 'rails_helper'

RSpec.describe "Users", type: :request do
  let(:superadmin) { create(:user, :superadmin) }
  let(:regular_user) { create(:user) }

  before { superadmin; regular_user }

  describe "GET /api/users" do
    context "as superadmin" do
      it "returns 200 and lists all users" do
        create_list(:user, 2)

        get "/api/users", headers: auth_headers(superadmin)

        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body).length).to be >= 3
      end
    end

    context "as regular user" do
      it "returns 401" do
        get "/api/users", headers: auth_headers(regular_user)

        expect(response).to have_http_status(:unauthorized)
      end
    end

    context "when not authenticated" do
      it "returns 401" do
        get "/api/users", headers: { "Accept" => "application/json" }

        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe "GET /api/users/:id" do
    context "as superadmin" do
      it "returns 200 and the user data" do
        get "/api/users/#{regular_user.id}", headers: auth_headers(superadmin)

        expect(response).to have_http_status(:ok)
        body = JSON.parse(response.body)
        expect(body["id"]).to eq(regular_user.id)
        expect(body["email"]).to eq(regular_user.email)
        expect(body["role"]).to eq(regular_user.role)
      end
    end

    context "as regular user" do
      it "returns 401" do
        get "/api/users/#{regular_user.id}", headers: auth_headers(regular_user)

        expect(response).to have_http_status(:unauthorized)
      end
    end

    context "with a non-existent id" do
      it "returns 404" do
        get "/api/users/#{SecureRandom.uuid}", headers: auth_headers(superadmin)

        expect(response).to have_http_status(:not_found)
      end
    end
  end

  describe "PATCH /api/users/:id" do
    context "as superadmin" do
      it "updates the user and returns 200" do
        patch "/api/users/#{regular_user.id}",
              params: { user: { role: "superadmin" } },
              headers: auth_headers(superadmin),
              as: :json

        expect(response).to have_http_status(:ok)
        expect(regular_user.reload.role).to eq("superadmin")
      end
    end

    context "as regular user" do
      it "returns 401" do
        patch "/api/users/#{regular_user.id}",
              params: { user: { role: "superadmin" } },
              headers: auth_headers(regular_user),
              as: :json

        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe "DELETE /api/users/:id" do
    context "as superadmin" do
      it "deletes the user and returns 200" do
        target = create(:user)

        expect {
          delete "/api/users/#{target.id}", headers: auth_headers(superadmin)
        }.to change(Users::User, :count).by(-1)

        expect(response).to have_http_status(:no_content)
      end
    end

    context "as regular user" do
      it "returns 401" do
        delete "/api/users/#{regular_user.id}", headers: auth_headers(regular_user)

        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe "POST /api/users/create" do
    context "as superadmin" do
      it "creates a user and returns 201" do
        expect {
          post "/api/users/create",
               params: { user: { email: "admin_new@example.com", password: "password123", password_confirmation: "password123", role: "superadmin" } },
               headers: auth_headers(superadmin),
               as: :json
        }.to change(Users::User, :count).by(1)

        expect(response).to have_http_status(:created)
      end
    end

    context "as regular user" do
      it "returns 401" do
        post "/api/users/create",
             params: { user: { email: "admin_new@example.com", password: "password123", password_confirmation: "password123" } },
             headers: auth_headers(regular_user),
             as: :json

        expect(response).to have_http_status(:unauthorized)
      end
    end
  end
end
