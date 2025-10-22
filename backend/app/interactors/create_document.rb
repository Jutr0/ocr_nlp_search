class CreateDocument
  include Interactor
  include DocumentHistoryLogging
  include Transactional

  def call
    document = Document.create(status: :pending, file: context.file, filename: context.file&.original_filename, user_id: context.user_id)

    unless document.valid?
      context.fail!(error: { message: document.errors.full_messages.join(", "), status: :unprocessable_entity })
    end

    context.document = document

    log_document_history(document, DocumentHistoryLog.actions[:created])
    OcrJob.perform_later(document)
  end
end