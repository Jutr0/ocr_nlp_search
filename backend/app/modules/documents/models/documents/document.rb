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

module Documents
  class Document < ApplicationRecord
    belongs_to :user, class_name: "Users::User"
    has_one_attached :file
    before_validation :truncate_nip_to_10_chars

    enum :status, {
      pending: "pending",
      ocr_processing: "ocr_processing",
      ocr_retrying: "ocr_retrying",
      ocr_succeeded: "ocr_succeeded",
      nlp_processing: "nlp_processing",
      nlp_retrying: "nlp_retrying",
      to_review: "to_review",
      approved: "approved",
      failed: "failed"
    }, default: :pending

    validates :file, attached: true, content_type: %w[application/pdf image/png image/jpeg]
    validates :status, presence: true

    scope :full_text, ->(q) {
      return all if q.blank?

      sanitized = sanitize_sql_like(q)
      where("tsdoc @@ plainto_tsquery(?)", sanitized)
        .order(Arel.sql("ts_rank(tsdoc, plainto_tsquery('#{sanitized}')) DESC"))
    }

    private

    def truncate_nip_to_10_chars
      self.nip = nip.to_s[0, 10] if nip.present?
    end
  end
end
