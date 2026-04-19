module Documents
  class ChangeDocumentStatus
    include Interactor

    def call
      document = Document.find_by(id: context.document_id)
      return if document.nil?

      attrs = { status: context.status }
      attrs.merge!(context.attributes.to_h) if context.attributes.present?
      document.update!(attrs)

      CreateHistoryLog.call!(document: document, action: DocumentHistoryLog.actions[context.action])
    end
  end
end
