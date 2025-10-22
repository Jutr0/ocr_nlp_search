class CompleteDocumentOcr
  include Interactor
  include DocumentHistoryLogging
  include Transactional

  def call
    updated_document = context.document.update(status: :ocr_succeeded, text_ocr: context.text_ocr)

    unless updated_document.valid?
      context.fail!(error: { message: updated_document.errors.full_messages.join(", "), status: :unprocessable_entity })
    end

    log_document_history(updated_document, :ocr_succeeded)
  end
end