class CompleteDocumentOcr
  include Interactor
  include DocumentHistoryLogging
  include Transactional

  def call
    context.document.update(status: :ocr_succeeded, text_ocr: context.text_ocr)

    unless context.document.valid?
      context.fail!(error: { message: context.document.errors.full_messages.join(", "), status: :unprocessable_entity })
    end

    log_document_history(context.document, :ocr_succeeded)
  end
end
