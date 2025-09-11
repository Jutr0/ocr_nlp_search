# == Schema Information
#
# Table name: document_history_logs
#
#  id             :uuid             not null, primary key
#  action         :string           not null
#  current_state  :string
#  previous_state :string
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  document_id    :uuid             not null
#
# Indexes
#
#  index_document_history_logs_on_document_id  (document_id)
#
# Foreign Keys
#
#  fk_rails_...  (document_id => documents.id)
#

module Documents
  class DocumentHistoryLog < ApplicationRecord
    enum :action, {
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
    }

    belongs_to :document

    validates :action, inclusion: { in: actions.values }

  end
end
