module Documents
  class DashboardService
    IN_FLIGHT_STATUSES = %w[pending ocr_processing ocr_retrying ocr_succeeded nlp_processing nlp_retrying to_review].freeze
    OCR_CONFIDENCE_THRESHOLD = 80
    NLP_CONFIDENCE_THRESHOLD = 70

    def initialize(user:)
      @scope = Document.unscoped.where(user: user)
    end

    def call
      {
        summary: summary,
        documents_per_category: documents_per_category,
        processing_documents: processing_documents,
        expenses_by_category: expenses_by_category,
        recent_documents: recent_documents,
        flagged_anomalies: flagged_anomalies
      }
    end

    private

    def summary
      counts = @scope.pick(
        Arel.sql("COUNT(*)"),
        Arel.sql("COUNT(*) FILTER (WHERE created_at >= date_trunc('month', now()))"),
        Arel.sql("COUNT(*) FILTER (WHERE status = 'to_review')")
      )

      {
        all_documents: counts[0],
        documents_this_month: counts[1],
        documents_to_review: counts[2]
      }
    end

    def documents_per_category
      @scope
        .group(:category)
        .order(Arel.sql("COUNT(*) DESC"))
        .count
        .map { |category, count| { category: category, count: count } }
    end

    def processing_documents
      @scope
        .where(status: IN_FLIGHT_STATUSES)
        .group(:status)
        .count
        .map { |status, count| { status: status, count: count } }
    end

    def expenses_by_category
      @scope
        .where.not(gross_amount: nil)
        .group(:category)
        .order(Arel.sql("SUM(gross_amount) DESC"))
        .sum(:gross_amount)
        .map { |category, total| { category: category, total: total.to_f } }
    end

    def recent_documents
      @scope
        .order(created_at: :desc)
        .limit(5)
        .pluck(:id, :invoice_number, :created_at, :category, :status, :gross_amount)
        .map do |id, doc_number, upload_date, category, status, amount|
          {
            id: id,
            doc_number: doc_number,
            upload_date: upload_date&.to_date,
            category: category,
            status: status,
            amount: amount&.to_f
          }
        end
    end

    def flagged_anomalies
      @scope
        .where(
          "ocr_confidence < :ocr OR nlp_confidence < :nlp",
          ocr: OCR_CONFIDENCE_THRESHOLD,
          nlp: NLP_CONFIDENCE_THRESHOLD
        )
        .order(Arel.sql("LEAST(COALESCE(ocr_confidence, 0), COALESCE(nlp_confidence, 0)) ASC"))
        .limit(5)
        .pluck(:id, :invoice_number, :category, :gross_amount, :ocr_confidence, :nlp_confidence)
        .map do |id, doc_number, category, amount, ocr_conf, nlp_conf|
          {
            id: id,
            doc_number: doc_number,
            category: category,
            amount: amount&.to_f,
            ocr_confidence: ocr_conf,
            nlp_confidence: nlp_conf
          }
        end
    end
  end
end
