class CompleteDocumentNlp
  include Interactor
  include DocumentHistoryLogging
  include Transactional

  def call
    attributes = { status: :to_review }.merge(context.extracted_data)
    context.document.update(attributes)

    unless context.document.valid?
      context.fail!(error: { message: context.document.errors.full_messages.join(", "), status: :unprocessable_entity })
    end

    log_document_history(context.document, :nlp_succeeded)
  end
end
