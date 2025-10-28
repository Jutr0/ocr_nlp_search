require 'rails_helper'
require 'seeds/documents_seed'

RSpec.describe CreateHistoryLog, type: :interactor do
  include_examples "documents_seed"

  it 'succeeds' do
    context = CreateHistoryLog.call(document: pending_document, action: DocumentHistoryLog.actions[:created])
    expect(context).to be_success
  end

  context 'raises RecordInvalid' do
    it 'when action is nil' do
      context = CreateHistoryLog.call(document: pending_document, action: nil)

      expect(context).to be_failure
      expect(context.errors.map(&:full_message)).to include("Action can't be blank")
    end

    it 'when document is nil' do
      context = CreateHistoryLog.call(document: nil, action: DocumentHistoryLog.actions[:created])

      expect(context).to be_failure
      expect(context.errors.map(&:full_message)).to include("Document can't be blank")
    end
  end
end
