require 'rails_helper'
require 'modules/documents/seeds/documents_seed'
module Documents
  RSpec.describe DocumentHistoryLog, type: :model do
    include_examples 'documents_seed'

    describe 'associations' do
      it { is_expected.to belong_to(:document).class_name('Document') }
    end

    describe 'enums' do
      it do
        is_expected.to define_enum_for(:action).
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
end
