require "rails_helper"

RSpec.describe "Dashboard", type: :request do
  describe "GET /api/dashboard" do
    context "when unauthenticated" do
      it "rejects the request" do
        get "/api/dashboard", as: :json
        expect(response).to have_http_status(:unauthorized)
      end
    end

    context "when authenticated" do
      let(:user) { create(:user) }

      before do
        create(:document, user: user, status: :to_review, category: "it_services",
               gross_amount: 100.0, invoice_number: "INV-001", ocr_confidence: 95, nlp_confidence: 90)
        create(:document, user: user, status: :pending, category: "office_supplies",
               gross_amount: 50.0, invoice_number: "INV-002", ocr_confidence: 70, nlp_confidence: 60)
        create(:document, user: user, status: :approved, category: "it_services",
               gross_amount: 200.0, invoice_number: "INV-003", ocr_confidence: 95, nlp_confidence: 85)
      end

      it "returns 200 with correct shape" do
        get "/api/dashboard", headers: auth_headers(user)

        expect(response).to have_http_status(:ok)
        body = JSON.parse(response.body)

        expect(body).to include("summary", "documents_per_category", "processing_documents",
                                "expenses_by_category", "recent_documents", "flagged_anomalies")

        summary = body["summary"]
        expect(summary["all_documents"]).to eq(3)
        expect(summary["documents_to_review"]).to eq(1)
        expect(summary["documents_this_month"]).to be_a(Integer)
      end

      it "returns correct aggregation data" do
        get "/api/dashboard", headers: auth_headers(user)
        body = JSON.parse(response.body)

        categories = body["documents_per_category"].map { |c| c["category"] }
        expect(categories).to include("it_services", "office_supplies")

        processing = body["processing_documents"]
        statuses = processing.map { |p| p["status"] }
        expect(statuses).to include("to_review", "pending")
        expect(statuses).not_to include("approved")

        expenses = body["expenses_by_category"]
        it_expense = expenses.find { |e| e["category"] == "it_services" }
        expect(it_expense["total"]).to eq(300.0)

        recent = body["recent_documents"]
        expect(recent.length).to be <= 5
        expect(recent.first).to include("id", "doc_number", "upload_date", "category", "status", "amount")

        flagged = body["flagged_anomalies"]
        expect(flagged.length).to eq(1)
        expect(flagged.first["ocr_confidence"]).to eq(70)
      end
    end

    context "data isolation" do
      let(:user_a) { create(:user) }
      let(:user_b) { create(:user) }

      before do
        create_list(:document, 3, user: user_a, status: :pending, category: "it_services", gross_amount: 100.0)
        create_list(:document, 5, user: user_b, status: :to_review, category: "office_supplies", gross_amount: 200.0)
      end

      it "user A only sees their own documents" do
        get "/api/dashboard", headers: auth_headers(user_a)
        body = JSON.parse(response.body)

        expect(body["summary"]["all_documents"]).to eq(3)
        expect(body["summary"]["documents_to_review"]).to eq(0)

        categories = body["documents_per_category"].map { |c| c["category"] }
        expect(categories).to eq(["it_services"])
      end

      it "user B only sees their own documents" do
        get "/api/dashboard", headers: auth_headers(user_b)
        body = JSON.parse(response.body)

        expect(body["summary"]["all_documents"]).to eq(5)
        expect(body["summary"]["documents_to_review"]).to eq(5)

        categories = body["documents_per_category"].map { |c| c["category"] }
        expect(categories).to eq(["office_supplies"])
      end
    end
  end
end
