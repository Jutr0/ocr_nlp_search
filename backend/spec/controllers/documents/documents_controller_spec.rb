require 'rails_helper'
require 'ostruct'
require 'seeds/documents_seed'

RSpec.describe DocumentsController, type: :controller do
  include Devise::Test::ControllerHelpers
  include_examples 'documents_seed'

  describe 'GET #index' do
    include_examples 'an user-only endpoint', method: :get, action: :index

    context "returns list of signed user's documents" do
      it 'user' do
        sign_in user
        get :index, format: :json

        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        expect(json).to be_an(Array)
        ids = json.map { |d| d['id'] }
        expect(ids).to include(pending_document.id, approved_document.id)
        expect(ids).not_to include(another_user_document.id)
      end

      it 'another user' do
        sign_in another_user
        get :index, format: :json

        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        expect(json).to be_an(Array)
        ids = json.map { |d| d['id'] }
        expect(ids).to include(another_user_document.id)
        expect(ids).not_to include(pending_document.id)
        expect(ids).not_to include(approved_document.id)
      end
    end

    it 'renders the expected fields for each document' do
      sign_in user
      get :index, format: :json
      expect(response.body).to match_schema('user_documents')
    end
  end

  describe 'GET #show' do
    include_examples 'an user-only endpoint',
                     method: :get,
                     action: :show,
                     params_proc: -> { { id: pending_document.id } }

    it 'returns document data when user signed in' do
      sign_in user
      get :show, params: { id: pending_document.id }, format: :json

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['id']).to eq(pending_document.id)
    end

    it "returns 401 Unauthorized when user is not document's owner" do
      sign_in user
      get :show, params: { id: another_user_document.id }, format: :json
      expect(response).to have_http_status(:unauthorized)
    end

    it 'renders the expected fields for document' do
      sign_in user
      get :show, params: { id: pending_document.id }, format: :json
      expect(response.body).to match_schema('user_pending_document')
    end
  end

  describe 'POST #create' do
    include_examples 'an user-only endpoint',
                     method: :post,
                     action: :create,
                     params_proc: -> { { file: file } }

    it 'creates a document when user signed in' do
      sign_in user

      expect {
        post :create, params: { file: file }, format: :json
      }.to change(Document, :count).by(1)

      expect(response).to have_http_status(:created)
      json = JSON.parse(response.body)
      expect(json['status']).to eq('pending')
    end

    it 'publish document created event' do
      sign_in user

      post :create, params: { file: file }, format: :json

      expect(@topic).to eq(:documents_stream)
      expect(@event).to eq('documents.created')
      expect(@data.to_json).to match_schema('document_created_event_payload')
    end

    it 'renders the expected fields for created document' do
      sign_in user
      post :create, params: { file: file }, format: :json

      expect(response.body).to match_schema('user_created_document')
    end
  end

  describe 'DELETE #destroy' do
    include_examples 'an user-only endpoint',
                     method: :delete,
                     action: :destroy,
                     params_proc: -> { { id: pending_document.id } }

    it 'destroys document when user signed in' do
      sign_in user
      expect {
        delete :destroy, params: { id: pending_document.id }, format: :json
      }.to change(Document, :count).by(-1)
      expect(response).to have_http_status(:ok)
    end

    it "returns 401 Unauthorized when user is not document's owner" do
      sign_in user
      delete :destroy, params: { id: another_user_document.id }, format: :json
      expect(response).to have_http_status(:unauthorized)
    end
  end

  describe 'GET #refresh_ocr' do
    include_examples 'an user-only endpoint',
                     method: :get,
                     action: :refresh_ocr,
                     params_proc: -> { { id: pending_document.id } }

    it 'publish refresh ocr event when user signed in' do
      sign_in user
      get :refresh_ocr, params: { id: pending_document.id }, format: :json
      expect(response).to have_http_status(:ok)

      expect(@topic).to eq(:documents_stream)
      expect(@event).to eq('documents.ocr.refresh')
      expect(@data.to_json).to match_schema('refresh_ocr_payload')
    end

    it "returns 401 Unauthorized when user is not document's owner" do
      sign_in user
      get :refresh_ocr, params: { id: another_user_document.id }, format: :json

      expect(response).to have_http_status(:unauthorized)
    end
  end

  describe 'GET #refresh_nlp' do
    include_examples 'an user-only endpoint',
                     method: :get,
                     action: :refresh_nlp,
                     params_proc: -> { { id: approved_document.id } }

    it 'publish refresh nlp event when user signed in' do
      sign_in user
      get :refresh_nlp, params: { id: approved_document.id }, format: :json
      expect(response).to have_http_status(:ok)

      expect(@topic).to eq(:documents_stream)
      expect(@event).to eq('documents.nlp.refresh')
      expect(@data.to_json).to match_schema('refresh_nlp_payload')
    end

    it "returns 401 Unauthorized when user is not document's owner" do
      sign_in user
      get :refresh_nlp, params: { id: another_user_document.id }, format: :json

      expect(response).to have_http_status(:unauthorized)
    end
  end

  describe 'GET #to_review' do
    include_examples 'an user-only endpoint', method: :get, action: :to_review

    context "returns list of signed user's documents" do
      it 'user' do
        sign_in user
        get :to_review, format: :json

        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        expect(json).to be_an(Array)
        ids = json.map { |d| d['id'] }
        expect(ids).to include(to_review_document.id)

        [
          pending_document,
          approved_document,
          another_user_document,
          another_user_to_review_document
        ].each do |doc|
          expect(ids).not_to include(doc.id)
        end
      end

      it 'another user' do
        sign_in another_user
        get :to_review, format: :json

        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        expect(json).to be_an(Array)
        ids = json.map { |d| d['id'] }
        expect(ids).to include(another_user_to_review_document.id)

        [
          pending_document,
          approved_document,
          another_user_document,
          to_review_document
        ].each do |doc|
          expect(ids).not_to include(doc.id)
        end
      end
    end

    it 'renders the expected fields for each document' do
      sign_in user
      get :to_review, format: :json
      expect(response.body).to match_schema('user_to_review_documents')
    end
  end

  describe 'POST #approve' do
    include_examples 'an user-only endpoint',
                     method: :post,
                     action: :approve,
                     params_proc: -> { { id: to_review_document.id } }

    it "change document status to approved" do
      sign_in user
      post :approve, params: { id: to_review_document.id }, format: :json

      expect(response).to have_http_status(:ok)
      expect(to_review_document.reload).to be_approved
    end

    it 'returns 422 Unprocessable Entity if document is not to_review' do
      sign_in user
      post :approve, params: { id: pending_document.id }, format: :json

      expect(response).to have_http_status(:unprocessable_entity)
      expect(JSON.parse(response.body)["message"]).to eq("Document must be in to_review state to be approved")
      expect(pending_document.reload).not_to be_approved
    end

    it "returns 401 Unauthorized when user is not document's owner" do
      sign_in user
      post :approve, params: { id: another_user_document.id }, format: :json

      expect(response).to have_http_status(:unauthorized)
    end
  end

  describe 'POST #reject' do
    include_examples 'an user-only endpoint',
                     method: :post,
                     action: :reject,
                     params_proc: -> { { id: to_review_document.id } }

    it "change document status to reject" do
      sign_in user
      post :reject, params: { id: to_review_document.id }, format: :json

      expect(response).to have_http_status(:ok)
      expect(to_review_document.reload).to be_ocr_retrying
    end

    it 'returns 422 Unprocessable Entity if document is not to_review' do
      sign_in user
      post :reject, params: { id: pending_document.id }, format: :json

      expect(response).to have_http_status(:unprocessable_entity)
      expect(JSON.parse(response.body)["message"]).to eq("Document must be in to_review state to be rejected")
      expect(pending_document.reload).not_to be_ocr_retrying
    end

    it "returns 401 Unauthorized when user is not document's owner" do
      sign_in user
      post :reject, params: { id: another_user_document.id }, format: :json

      expect(response).to have_http_status(:unauthorized)
    end
  end
end
