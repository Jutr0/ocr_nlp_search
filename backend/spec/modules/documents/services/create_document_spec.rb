require 'rails_helper'

RSpec.describe Documents::CreateDocument, type: :interactor do
  let(:user) { create(:user) }
  let(:file) { fixture_file_upload('dummy.pdf', 'application/pdf') }

  before do
    ActiveStorage::Current.url_options = { host: "http://localhost:4000" }
    allow(Processing::OcrJob).to receive(:perform_later)
  end

  subject(:context) { described_class.call(file: file, user_id: user.id) }

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
