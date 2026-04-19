require "rails_helper"

RSpec.describe "Sessions", type: :request do
  describe "POST /api/users/sign_in" do
    let(:user) { create(:user) }

    context "with valid credentials" do
      it "returns 200 and user data" do
        post "/api/users/sign_in",
             params: { user: { email: user.email, password: "password123" } },
             as: :json

        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body).dig("user", "email")).to eq(user.email)
      end

      it "returns an Authorization header with a JWT token" do
        post "/api/users/sign_in",
             params: { user: { email: user.email, password: "password123" } },
             as: :json

        expect(response.headers["Authorization"]).to match(/^Bearer /)
      end
    end

    context "with invalid credentials" do
      it "returns 401" do
        post "/api/users/sign_in",
             params: { user: { email: user.email, password: "wrong" } },
             as: :json

        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe "DELETE /api/users/sign_out" do
    let(:user) { create(:user) }

    it "returns 204 no content" do
      delete "/api/users/sign_out", headers: auth_headers(user)

      expect(response).to have_http_status(:no_content)
    end
  end
end
