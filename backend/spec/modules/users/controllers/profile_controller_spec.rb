require 'rails_helper'

RSpec.describe "Profile", type: :request do
  describe "GET /api/profile/me" do
    context "when authenticated" do
      let(:user) { create(:user) }

      it "returns 200 and the current user's data" do
        get "/api/profile/me", headers: auth_headers(user)

        expect(response).to have_http_status(:ok)
        body = JSON.parse(response.body)
        expect(body["id"]).to eq(user.id)
        expect(body["email"]).to eq(user.email)
      end
    end

    context "when not authenticated" do
      it "returns 401" do
        get "/api/profile/me", headers: { "Accept" => "application/json" }

        expect(response).to have_http_status(:unauthorized)
      end
    end
  end
end