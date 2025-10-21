require 'rails_helper'
require 'modules/documents/seeds/documents_seed'

module Documents
  RSpec.describe CreateHistoryLog, type: :interactor do
    include_examples "documents_seed"

    subject(:context) { CreateHistoryLog.call(document: pending_document, action: DocumentHistoryLog.actions[:created]) }

    it 'succeeds' do
      expect(context).to be_success
    end

    context 'raises RecordInvalid' do
      it 'when action is nil' do
        expect {
          CreateHistoryLog.call(document: pending_document, action: nil)
        }.to raise_error(ActiveRecord::RecordInvalid)
      end

      it 'when document is nil' do
        expect {
          CreateHistoryLog.call(document: nil, action: DocumentHistoryLog.actions[:created])
        }.to raise_error(ActiveRecord::RecordInvalid)
      end
    end
  end
end
