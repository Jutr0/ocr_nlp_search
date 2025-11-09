require 'rails_helper'
require 'seeds/documents_seed'

RSpec.describe "Documents", type: :request do
  include_examples 'documents_seed'

  let(:headers) { { 'ACCEPT' => 'application/json' } }

  describe 'GET /documents' do
    include_examples 'an user-only endpoint', method: :get, path: '/documents'

    context "returns list of signed user's documents" do
      it 'user' do
        sign_in user
        get '/documents', headers: headers

        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        expect(json).to be_an(Array)
        ids = json.map { |d| d['id'] }
        expect(ids).to include(pending_document.id, approved_document.id)
        expect(ids).not_to include(another_user_document.id)
      end

      it 'another user' do
        sign_in another_user
        get '/documents', headers: headers

        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        ids = json.map { |d| d['id'] }
        expect(ids).to include(another_user_document.id)
        expect(ids).not_to include(pending_document.id, approved_document.id)
      end
    end

    it 'renders the expected fields for each document' do
      sign_in user
      get '/documents', headers: headers
      expect(response.body).to match_schema('user_documents')
    end
  end

  describe 'GET /documents/:id' do
    include_examples 'an user-only endpoint',
                     method: :get,
                     path_proc: -> { "/documents/#{pending_document.id}" }

    it 'returns document data when user signed in' do
      sign_in user
      get "/documents/#{pending_document.id}", headers: headers

      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)['id']).to eq(pending_document.id)
    end

    it "returns 401 Unauthorized when user is not document's owner" do
      sign_in user
      get "/documents/#{another_user_document.id}", headers: headers

      expect(response).to have_http_status(:unauthorized)
    end

    it 'renders the expected fields for document' do
      sign_in user
      get "/documents/#{pending_document.id}", headers: headers
      expect(response.body).to match_schema('user_pending_document')
    end
  end

  describe 'POST /documents' do
    include_examples 'an user-only endpoint',
                     method: :post,
                     path: '/documents',
                     params_proc: -> { { file: file } }

    it 'creates a document when user signed in' do
      sign_in user

      expect {
        post '/documents', params: { file: file }, headers: headers
      }.to change(Document, :count).by(1)

      expect(response).to have_http_status(:created)
      expect(JSON.parse(response.body)['status']).to eq('pending')
    end

    it 'publish document created event' do
      sign_in user
      post '/documents', params: { file: file }, headers: headers

      expect(@topic).to eq(:documents_stream)
      expect(@event).to eq('documents.created')
      expect(@data.to_json).to match_schema('document_created_event_payload')
    end

    it 'renders the expected fields for created document' do
      sign_in user
      post '/documents', params: { file: file }, headers: headers
      expect(response.body).to match_schema('user_created_document')
    end
  end

  describe 'DELETE /documents/:id' do
    include_examples 'an user-only endpoint',
                     method: :delete,
                     path_proc: -> { "/documents/#{pending_document.id}" }

    it 'destroys document when user signed in' do
      sign_in user

      expect {
        delete "/documents/#{pending_document.id}", headers: headers
      }.to change(Document, :count).by(-1)

      expect(response).to have_http_status(:ok)
    end

    it "returns 401 Unauthorized when user is not document's owner" do
      sign_in user
      delete "/documents/#{another_user_document.id}", headers: headers
      expect(response).to have_http_status(:unauthorized)
    end
  end

  describe 'GET /documents/:id/refresh_ocr' do
    include_examples 'an user-only endpoint',
                     method: :get,
                     path_proc: -> { "/documents/#{pending_document.id}/refresh_ocr" }

    it 'publish refresh ocr event when user signed in' do
      sign_in user
      get "/documents/#{pending_document.id}/refresh_ocr", headers: headers

      expect(response).to have_http_status(:ok)
      expect(@topic).to eq(:documents_stream)
      expect(@event).to eq('documents.ocr.refresh')
      expect(@data.to_json).to match_schema('refresh_ocr_payload')
    end

    it "returns 401 Unauthorized when user is not document's owner" do
      sign_in user
      get "/documents/#{another_user_document.id}/refresh_ocr", headers: headers
      expect(response).to have_http_status(:unauthorized)
    end
  end

  describe 'GET /documents/:id/refresh_nlp' do
    include_examples 'an user-only endpoint',
                     method: :get,
                     path_proc: -> { "/documents/#{approved_document.id}/refresh_nlp" }

    it 'publish refresh nlp event when user signed in' do
      sign_in user
      get "/documents/#{approved_document.id}/refresh_nlp", headers: headers

      expect(response).to have_http_status(:ok)
      expect(@topic).to eq(:documents_stream)
      expect(@event).to eq('documents.nlp.refresh')
      expect(@data.to_json).to match_schema('refresh_nlp_payload')
    end

    it "returns 401 Unauthorized when user is not document's owner" do
      sign_in user
      get "/documents/#{another_user_document.id}/refresh_nlp", headers: headers
      expect(response).to have_http_status(:unauthorized)
    end
  end

  describe 'GET /documents/to_review' do
    include_examples 'an user-only endpoint', method: :get, path: '/documents/to_review'

    context "returns list of signed user's documents" do
      it 'user' do
        sign_in user
        get '/documents/to_review', headers: headers

        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        ids = json.map { |d| d['id'] }
        expect(ids).to include(to_review_document.id)
        expect(ids).not_to include(
                             pending_document.id,
                             approved_document.id,
                             another_user_document.id,
                             another_user_to_review_document.id
                           )
      end

      it 'another user' do
        sign_in another_user
        get '/documents/to_review', headers: headers

        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        ids = json.map { |d| d['id'] }
        expect(ids).to include(another_user_to_review_document.id)
        expect(ids).not_to include(
                             pending_document.id,
                             approved_document.id,
                             another_user_document.id,
                             to_review_document.id
                           )
      end
    end

    it 'renders the expected fields for each document' do
      sign_in user
      get '/documents/to_review', headers: headers
      expect(response.body).to match_schema('user_to_review_documents')
    end
  end

  describe 'POST /documents/:id/approve' do
    include_examples 'an user-only endpoint',
                     method: :post,
                     path_proc: -> { "/documents/#{to_review_document.id}/approve" }

    it "changes document status to approved" do
      sign_in user
      post "/documents/#{to_review_document.id}/approve", headers: headers

      expect(response).to have_http_status(:ok)
      expect(to_review_document.reload).to be_approved
    end

    it 'returns 422 if document is not to_review' do
      sign_in user
      post "/documents/#{pending_document.id}/approve", headers: headers

      expect(response).to have_http_status(:unprocessable_entity)
      expect(JSON.parse(response.body)['message'])
        .to eq("Document must be in to_review state to be approved")
      expect(pending_document.reload).not_to be_approved
    end

    it "returns 401 Unauthorized when user is not document's owner" do
      sign_in user
      post "/documents/#{another_user_document.id}/approve", headers: headers
      expect(response).to have_http_status(:unauthorized)
    end
  end

  describe 'POST /documents/:id/reject' do
    include_examples 'an user-only endpoint',
                     method: :post,
                     path_proc: -> { "/documents/#{to_review_document.id}/reject" }

    it "changes document status to rejected" do
      sign_in user
      post "/documents/#{to_review_document.id}/reject", headers: headers

      expect(response).to have_http_status(:ok)
      expect(to_review_document.reload).to be_ocr_retrying
    end

    it 'returns 422 if document is not to_review' do
      sign_in user
      post "/documents/#{pending_document.id}/reject", headers: headers

      expect(response).to have_http_status(:unprocessable_entity)
      expect(JSON.parse(response.body)['message'])
        .to eq("Document must be in to_review state to be rejected")
      expect(pending_document.reload).not_to be_ocr_retrying
    end

    it "returns 401 Unauthorized when user is not document's owner" do
      sign_in user
      post "/documents/#{another_user_document.id}/reject", headers: headers
      expect(response).to have_http_status(:unauthorized)
    end
  end
end
