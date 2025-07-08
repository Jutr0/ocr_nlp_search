module Documents
  class RejectDocument
    include Interactor

    def call
      context.document.update!(status: Document.statuses[:failed])
      DocumentOcrRefreshEvent.call(context.document)
    end
  end
end