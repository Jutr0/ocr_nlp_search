require 'rails_helper'
require 'seeds/documents_seed'

RSpec.describe ApproveDocument, type: :interactor do
  subject(:context) { described_class.call(document: to_review_document) }

  include_examples "documents_seed"


  it 'succeeds' do
    expect(context).to be_success
  end

  it 'changes status to approved' do
    expect { context }.to change { to_review_document.reload.status }.from('to_review').to('approved')
  end

  context 'when update! raises' do
    it 'fails the interactor' do
      ctx = described_class.call(document: pending_document)
      expect(ctx).to be_failure
      expect(ctx.error[:status]).to eq(:unprocessable_entity)
      expect(ctx.error[:message]).to eq("Document must be in to_review state to be approved")
    end
  end
end
