# == Schema Information
#
# Table name: document_history_logs
#
#  id          :uuid             not null, primary key
#  action      :string           not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  document_id :uuid             not null
#
# Indexes
#
#  index_document_history_logs_on_document_id  (document_id)
#
# Foreign Keys
#
#  fk_rails_...  (document_id => documents.id)
#
require 'rails_helper'
require 'seeds/documents_seed'

RSpec.describe DocumentHistoryLog, type: :model do
  include_examples 'documents_seed'

  describe 'associations' do
    it { is_expected.to belong_to(:document).class_name('Document') }
  end

  describe 'enums' do
    it do
      expect(subject).to define_enum_for(:action).
        with_values(
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
        ).
        backed_by_column_of_type(:string)
    end
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:document) }
  end
end
