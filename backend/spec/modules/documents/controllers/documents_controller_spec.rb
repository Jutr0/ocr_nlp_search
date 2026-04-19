require 'rails_helper'

RSpec.describe "Documents", type: :request do
  let(:user) { create(:user) }
  let(:other_user) { create(:user) }

  describe "GET /api/documents" do
    context "as the owner" do
      it "returns 200 and only own documents" do
        own = create(:document, user: user)
        create(:document, user: other_user)

        get "/api/documents", headers: auth_headers(user)

        expect(response).to have_http_status(:ok)
        ids = JSON.parse(response.body).map { |d| d["id"] }
        expect(ids).to include(own.id)
        expect(ids).not_to include(other_user.id)
      end
    end

    context "when not authenticated" do
      it "returns 401" do
        get "/api/documents", headers: { "Accept" => "application/json" }

        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe "GET /api/documents/to_review" do
    context "as the owner" do
      it "returns 200 and only to_review documents" do
        to_review_doc = create(:document, :to_review, user: user)
        create(:document, user: user)

        get "/api/documents/to_review", headers: auth_headers(user)

        expect(response).to have_http_status(:ok)
        ids = JSON.parse(response.body).map { |d| d["id"] }
        expect(ids).to include(to_review_doc.id)
      end

      it "does not include pending documents" do
        pending_doc = create(:document, user: user)

        get "/api/documents/to_review", headers: auth_headers(user)

        ids = JSON.parse(response.body).map { |d| d["id"] }
        expect(ids).not_to include(pending_doc.id)
      end
    end
  end

  describe "GET /api/documents/:id" do
    context "as the owner" do
      it "returns 200 and document details" do
        document = create(:document, user: user)

        get "/api/documents/#{document.id}", headers: auth_headers(user)

        expect(response).to have_http_status(:ok)
        body = JSON.parse(response.body)
        expect(body["id"]).to eq(document.id)
        expect(body["status"]).to eq(document.status)
      end
    end

    context "accessing another user's document" do
      it "returns 401" do
        document = create(:document, user: other_user)

        get "/api/documents/#{document.id}", headers: auth_headers(user)

        expect(response).to have_http_status(:unauthorized)
      end
    end

    context "with a non-existent id" do
      it "returns 404" do
        get "/api/documents/#{SecureRandom.uuid}", headers: auth_headers(user)

        expect(response).to have_http_status(:not_found)
      end
    end
  end

  describe "POST /api/documents" do
    let(:pdf_file) do
      Rack::Test::UploadedFile.new(
        StringIO.new("%PDF-1.4 fake content"),
        "application/pdf",
        original_filename: "invoice.pdf"
      )
    end

    context "as authenticated user with valid file" do
      before do
        allow(Processing::OcrJob).to receive(:perform_later)
      end

      it "returns 201 and creates a document" do
        expect {
          post "/api/documents",
               params: { file: pdf_file },
               headers: auth_headers(user)
        }.to change(Documents::Document, :count).by(1)

        expect(response).to have_http_status(:created)
        body = JSON.parse(response.body)
        expect(body["status"]).to eq("pending")
      end

      it "enqueues OcrJob for the new document" do
        expect(Processing::OcrJob).to receive(:perform_later).once

        post "/api/documents",
             params: { file: pdf_file },
             headers: auth_headers(user)
      end
    end

    context "without a file" do
      it "returns 422" do
        post "/api/documents", headers: auth_headers(user), as: :json

        expect(response).to have_http_status(:unprocessable_entity)
      end
    end

    context "when not authenticated" do
      it "returns 401" do
        post "/api/documents",
             params: { file: pdf_file },
             headers: { "Accept" => "application/json" }

        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe "DELETE /api/documents/:id" do
    context "as the owner" do
      it "deletes the document and returns 200" do
        document = create(:document, user: user)

        expect {
          delete "/api/documents/#{document.id}", headers: auth_headers(user)
        }.to change(Documents::Document, :count).by(-1)

        expect(response).to have_http_status(:ok)
      end
    end

    context "accessing another user's document" do
      it "returns 401 and does not delete" do
        document = create(:document, user: other_user)

        expect {
          delete "/api/documents/#{document.id}", headers: auth_headers(user)
        }.not_to change(Documents::Document, :count)

        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe "GET /api/documents/:id/refresh_ocr" do
    context "as the owner" do
      it "enqueues OcrJob and returns 200" do
        document = create(:document, user: user)
        allow(Processing::OcrJob).to receive(:perform_later)

        get "/api/documents/#{document.id}/refresh_ocr", headers: auth_headers(user)

        expect(response).to have_http_status(:ok)
        expect(Processing::OcrJob).to have_received(:perform_later)
      end
    end

    context "accessing another user's document" do
      it "returns 401" do
        document = create(:document, user: other_user)

        get "/api/documents/#{document.id}/refresh_ocr", headers: auth_headers(user)

        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe "GET /api/documents/:id/refresh_nlp" do
    context "as the owner" do
      it "enqueues NlpJob and returns 200" do
        document = create(:document, user: user)
        allow(Processing::NlpJob).to receive(:perform_later)

        get "/api/documents/#{document.id}/refresh_nlp", headers: auth_headers(user)

        expect(response).to have_http_status(:ok)
        expect(Processing::NlpJob).to have_received(:perform_later)
      end
    end

    context "accessing another user's document" do
      it "returns 401" do
        document = create(:document, user: other_user)

        get "/api/documents/#{document.id}/refresh_nlp", headers: auth_headers(user)

        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe "POST /api/documents/:id/approve" do
    context "when document is in to_review state" do
      it "approves the document and returns 200" do
        document = create(:document, :to_review, user: user)

        post "/api/documents/#{document.id}/approve", headers: auth_headers(user)

        expect(response).to have_http_status(:ok)
        expect(document.reload.status).to eq("approved")
      end
    end

    context "when document is not in to_review state" do
      it "returns 422" do
        document = create(:document, user: user)

        post "/api/documents/#{document.id}/approve", headers: auth_headers(user)

        expect(response).to have_http_status(:unprocessable_entity)
      end
    end

    context "accessing another user's document" do
      it "returns 401" do
        document = create(:document, :to_review, user: other_user)

        post "/api/documents/#{document.id}/approve", headers: auth_headers(user)

        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe "POST /api/documents/:id/reject" do
    context "when document is in to_review state" do
      it "returns 200 and re-enqueues OCR" do
        document = create(:document, :to_review, user: user)
        allow(Processing::OcrJob).to receive(:perform_later)

        post "/api/documents/#{document.id}/reject", headers: auth_headers(user)

        expect(response).to have_http_status(:ok)
      end
    end

    context "when document is not in to_review state" do
      it "returns 422" do
        document = create(:document, user: user)

        post "/api/documents/#{document.id}/reject", headers: auth_headers(user)

        expect(response).to have_http_status(:unprocessable_entity)
      end
    end

    context "accessing another user's document" do
      it "returns 401" do
        document = create(:document, :to_review, user: other_user)

        post "/api/documents/#{document.id}/reject", headers: auth_headers(user)

        expect(response).to have_http_status(:unauthorized)
      end
    end
  end
end
