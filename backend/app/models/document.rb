# == Schema Information
#
# Table name: documents
#
#  id           :uuid             not null, primary key
#  content_type :string
#  currency     :string(3)
#  doc_type     :string
#  filename     :string
#  nip          :string(10)
#  processed_at :datetime
#  status       :string           default("pending"), not null
#  text_ocr     :text
#  total_gross  :decimal(15, 2)
#  total_net    :decimal(15, 2)
#  tsdoc        :tsvector
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#
# Indexes
#
#  index_documents_on_created_at  (created_at)
#  index_documents_on_doc_type    (doc_type)
#  index_documents_on_status      (status)
#  index_documents_on_tsdoc       (tsdoc) USING gin
#
class Document < ApplicationRecord
  has_one_attached :file

  enum :status, {
    pending:    "pending",
    processing: "processing",
    ready:      "ready",
    failed:     "failed"
  }, default: :pending

  validates :status, presence: true
  validates :currency, length: { is: 3 }, allow_blank: true
  validates :nip, length: { is: 10 }, allow_blank: true

  scope :full_text, ->(q) {
    return all if q.blank?

    sanitized = sanitize_sql_like(q)
    where("tsdoc @@ plainto_tsquery(?)", sanitized)
      .order(Arel.sql("ts_rank(tsdoc, plainto_tsquery('#{sanitized}')) DESC"))
  }

end
