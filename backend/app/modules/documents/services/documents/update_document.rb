module Documents
  class UpdateDocument
    include Interactor

    EDITABLE_ATTRIBUTES = %i[
      doc_type category invoice_number issue_date
      company_name nip net_amount gross_amount currency
    ].freeze

    def call
      document = context.document
      attributes = context.attributes.slice(*EDITABLE_ATTRIBUTES).compact_blank

      context.fail!(
        error: { message: "No editable attributes provided", status: :unprocessable_entity }
      ) if attributes.empty?

      document.update!(attributes)
      CreateHistoryLog.call!(document: document, action: DocumentHistoryLog.actions[:edited])
    end
  end
end
