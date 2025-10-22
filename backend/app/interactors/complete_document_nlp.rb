class CompleteDocumentNlp
  include Interactor
  include DocumentHistoryLogging
  include Transactional

  def call
    attributes = { status: :to_review }.merge(context.extracted_data)
    updated_document = context.document.update(attributes)

    unless updated_document.valid?
      context.fail!(error: { message: updated_document.errors.full_messages.join(", "), status: :unprocessable_entity })
    end

    log_document_history(updated_document, :nlp_succeeded)
  end
end
