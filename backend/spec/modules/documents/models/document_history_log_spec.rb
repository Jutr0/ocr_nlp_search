require 'rails_helper'

RSpec.describe Documents::DocumentHistoryLog, type: :model do
  describe 'associations' do
    it { is_expected.to belong_to(:document) }
  end

  describe 'validations' do
    it 'is valid with valid attributes' do
      expect(build(:document_history_log)).to be_valid
    end

    it 'is invalid without an action' do
      expect(build(:document_history_log, action: nil)).not_to be_valid
    end

    it 'is invalid without a document' do
      log = build(:document_history_log, document: nil)
      expect(log).not_to be_valid
      expect(log.errors[:document]).to be_present
    end
  end

  describe 'enums' do
    it {
      expect(subject).to define_enum_for(:action)
        .with_values(
          created: "created",
          ocr_started: "ocr_started",
          ocr_failed: "ocr_failed",
          ocr_succeeded: "ocr_succeeded",
          nlp_started: "nlp_started",
          nlp_failed: "nlp_failed",
          nlp_succeeded: "nlp_succeeded",
          approved: "approved",
          rejected: "rejected",
          edited: "edited"
        )
        .backed_by_column_of_type(:string)
    }
  end

  describe 'action predicates' do
    it 'returns true for created? when action is created' do
      expect(build(:document_history_log, action: :created)).to be_created
    end

    it 'returns true for approved? when action is approved' do
      expect(build(:document_history_log, :approved)).to be_approved
    end

    it 'returns true for rejected? when action is rejected' do
      expect(build(:document_history_log, :rejected)).to be_rejected
    end
  end
end
