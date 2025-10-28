require 'rails_helper'
require 'seeds/documents_seed'

RSpec.describe CreateDocument, type: :interactor do
  subject(:context) { described_class.call(file: file, user_id: user.id) }

  before do
    allow(DocumentCreatedEvent).to receive(:call)
  end

  include_examples "documents_seed"



  it 'succeeds' do
    expect(context).to be_success
  end

  context 'raises RecordInvalid' do
    it 'when file is nil' do
      expect {
        described_class.call(file: nil, user_id: user.id)
      }.to raise_error(ActiveRecord::RecordInvalid)
    end

    it 'when file has wrong content type' do
      expect {
        described_class.call(file: fixture_file_upload('dummy.txt', 'text/plain'), user_id: user.id)
      }.to raise_error(ActiveRecord::RecordInvalid)
    end
  end
end
