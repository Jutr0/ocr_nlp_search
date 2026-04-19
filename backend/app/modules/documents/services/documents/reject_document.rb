module Documents
  class RejectDocument
    include Interactor

    def call
      unless context.document.to_review?
        context.fail!(
          error: {
            message: "Document must be in to_review state to be rejected",
            status: :unprocessable_entity
          }
        )
      end

      context.document.update!(status: Document.statuses[:ocr_retrying])
      CreateHistoryLog.call!(document: context.document, action: DocumentHistoryLog.actions[:rejected])

      Processing::OcrJob.perform_later(
        document_id: context.document.id,
        file_url: context.document.file.url,
        filename: context.document.filename,
        content_type: context.document.file.content_type,
        user_id: context.document.user_id
      )
    end
  end
end
