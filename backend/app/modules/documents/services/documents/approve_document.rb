module Documents
  class ApproveDocument
    include Interactor

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
      CreateHistoryLog.call!(document: context.document, action: DocumentHistoryLog.actions[:approved])
    end
  end
end