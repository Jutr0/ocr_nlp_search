require 'rails_helper'
require 'ostruct'
require 'modules/documents/seeds/documents_seed'
module Documents
  RSpec.describe Documents::DocumentsController, type: :controller do
    include Devise::Test::ControllerHelpers
    include_examples 'documents_seed'

    describe 'GET #index' do
      include_examples 'an user-only endpoint', :get, :index

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
                       :get,
                       :show,
                       -> { { id: pending_document.id } }

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
      before do
        allow(DocumentCreatedEvent).to receive(:call).and_return(nil)
      end
      include_examples 'an user-only endpoint',
                       :post,
                       :create,
                       -> { { file: file } }

      it 'creates a document when user signed in' do
        sign_in user

        expect {
          post :create, params: { file: file }, format: :json
        }.to change(Document, :count).by(1)

        expect(response).to have_http_status(:created)
        json = JSON.parse(response.body)
        expect(json['status']).to eq('pending')
      end

      it 'renders the expected fields for created document' do
        sign_in user
        post :create, params: { file: file }, format: :json

        expect(response.body).to match_schema('user_created_document')
      end
    end

    describe 'DELETE #destroy' do
      include_examples 'an user-only endpoint',
                       :delete,
                       :destroy,
                       -> { { id: pending_document.id } }

      it 'destroys document when user signed in' do
        sign_in user
        expect {
          delete :destroy, params: { id: pending_document.id }, format: :json
        }.to change(Document, :count).by(-1)

        expect(response).to have_http_status(:no_content)
      end

      it "returns 401 Unauthorized when user is not document's owner" do
        sign_in user
        expect {
          delete :destroy, params: { id: pending_document.id }, format: :json
        }.to change(Document, :count).by(-1)

        expect(response).to have_http_status(:no_content)
      end
    end
  end
end
