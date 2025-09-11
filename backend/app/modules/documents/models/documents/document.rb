# == Schema Information
#
# Table name: documents
#
#  id             :uuid             not null, primary key
#  category       :string
#  company_name   :string
#  content_type   :string
#  currency       :string(3)
#  doc_type       :string
#  filename       :string
#  gross_amount   :decimal(15, 2)
#  invoice_number :string
#  issue_date     :date
#  net_amount     :decimal(15, 2)
#  nip            :string(10)
#  processed_at   :datetime
#  status         :string           default("pending"), not null
#  text_ocr       :text
#  tsdoc          :tsvector
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  user_id        :uuid             not null
#
# Indexes
#
#  index_documents_on_created_at  (created_at)
#  index_documents_on_doc_type    (doc_type)
#  index_documents_on_status      (status)
#  index_documents_on_tsdoc       (tsdoc) USING gin
#  index_documents_on_user_id     (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#
#  fk_rails_...  (user_id => users.id)

module Documents
  class Document < ApplicationRecord

    enum :status, {
      pending: "pending",
      ocr_processing: "ocr_processing",
      ocr_retrying: "ocr_retrying",
      ocr_succeeded: "ocr_succeeded",
      nlp_processing: "nlp_processing",
      nlp_retrying: "nlp_retrying",
      to_review: "to_review",
      approved: "approved"
    }, default: :pending

    enum :category, {
      it_services: "it_services",
      office_supplies: "office_supplies",
      travel_and_transportation: "marketing_and_advertising",
      marketing_and_advertising: "marketing_and_advertising",
      legal_and_accounting: "legal_and_accounting",
      utilities_and_subscriptions: "utilities_and_subscriptions",
      other: "other"
    }, default: :other

    belongs_to :user, class_name: "Users::User"
    has_many :history_logs, class_name: "DocumentHistoryLog", dependent: :destroy
    has_one_attached :file

    validates :file, attached: true, content_type: %w[application/pdf image/png image/jpeg]
    validates :status, presence: true
    validate :only_to_review_can_be_approved, if: :will_save_change_to_status?

    before_validation :truncate_nip_to_10_chars

    private

    def truncate_nip_to_10_chars
      self.nip = nip.to_s[0, 10] if nip.present?
    end

    def only_to_review_can_be_approved
      if self.id.present? && self.approved? && self.status_was != "to_review"
        errors.add(
          :status,
          "can only be changed to approved when it is in the to_review state"
        )
      end
    end
  end
end
