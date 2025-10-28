require 'rails_helper'
require 'seeds/documents_seed'

RSpec.describe CreateDocument, type: :interactor do
  include_examples "documents_seed"

  subject(:context) { CreateDocument.call(file: file, user_id: user.id) }

  before(:each) do
    allow(DocumentCreatedEvent).to receive(:call)
  end

  it 'succeeds' do
    expect(context).to be_success
  end

  context 'raises RecordInvalid' do
    it 'when file is nil' do
      expect {
        CreateDocument.call(file: nil, user_id: user.id)
      }.to raise_error(ActiveRecord::RecordInvalid)
    end

    it 'when file has wrong content type' do
      expect {
        CreateDocument.call(file: fixture_file_upload('dummy.txt', 'text/plain'), user_id: user.id)
      }.to raise_error(ActiveRecord::RecordInvalid)
    end
  end
end
