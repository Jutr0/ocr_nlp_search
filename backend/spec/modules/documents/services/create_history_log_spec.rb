require 'rails_helper'

RSpec.describe Documents::CreateHistoryLog, type: :interactor do
  let(:document) { create(:document) }

  it 'succeeds' do
    context = described_class.call(document: document, action: Documents::DocumentHistoryLog.actions[:created])
    expect(context).to be_success
  end

  context 'raises failure' do
    it 'when action is nil' do
      context = described_class.call(document: document, action: nil)

      expect(context).to be_failure
      expect(context.errors.map(&:full_message)).to include("Action can't be blank")
    end

    it 'when document is nil' do
      context = described_class.call(document: nil, action: Documents::DocumentHistoryLog.actions[:created])

      expect(context).to be_failure
      expect(context.errors.map(&:full_message)).to include("Document can't be blank")
    end
  end
end
