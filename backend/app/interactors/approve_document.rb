class ApproveDocument
  include Interactor
  include DocumentHistoryLogging
  include Transactional

  def call
    unless context.document.to_review?
      context.fail!(
        error: {
          message: "Document must be in to_review state to be approved",
          status: :unprocessable_entity
        }
      )
    end

    context.document.update!(status: Document.statuses[:approved])
    log_document_history(context.document, DocumentHistoryLog.actions[:approved])
  end
end