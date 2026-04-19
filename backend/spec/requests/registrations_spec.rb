require "rails_helper"

RSpec.describe "Registrations", type: :request do
  describe "POST /api/users/sign_up" do
    context "with valid params" do
      let(:attrs) do
        { email: "new@example.com", password: "password123", password_confirmation: "password123" }
      end

      it "creates a new user and returns 201" do
        expect {
          post "/api/users", params: { user: attrs }, as: :json
        }.to change(Users::User, :count).by(1)

        expect(response).to have_http_status(:created)
      end

      it "returns the created user data" do
        post "/api/users", params: { user: attrs }, as: :json

        body = JSON.parse(response.body)
        expect(body.dig("user", "email")).to eq("new@example.com")
      end

      it "returns an Authorization header with a JWT token" do
        post "/api/users", params: { user: attrs }, as: :json

        expect(response.headers["Authorization"]).to match(/^Bearer /)
      end
    end

    context "with mismatched password confirmation" do
      it "returns 422 and error messages" do
        post "/api/users",
             params: { user: { email: "new@example.com", password: "password123", password_confirmation: "other" } },
             as: :json

        expect(response).to have_http_status(:unprocessable_entity)
        expect(JSON.parse(response.body)["errors"]).to be_present
      end
    end

    context "with a duplicate email" do
      it "returns 422 and error messages" do
        create(:user, email: "taken@example.com")

        post "/api/users",
             params: { user: { email: "taken@example.com", password: "password123", password_confirmation: "password123" } },
             as: :json

        expect(response).to have_http_status(:unprocessable_entity)
        expect(JSON.parse(response.body)["errors"]).to be_present
      end
    end
  end
end
