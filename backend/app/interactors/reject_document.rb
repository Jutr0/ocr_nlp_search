class RejectDocument
  include Interactor
  include DocumentHistoryLogging
  include Transactional

  def call
    unless context.document.to_review?
      context.fail!(
        error: {
          message: "Document must be in to_review state to be rejected",
          status: :unprocessable_entity
        }
      )
    end

    context.document.update!(status: :ocr_retrying)
    log_document_history(context.document, :rejected)
    OcrJob.call(context.document)
  end
end