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
      DocumentOcrRefreshEvent.call(context.document)
    end
  end
end