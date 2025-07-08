module Documents
  class ApproveDocument
    include Interactor

    def call
     context.document.update!(status: Document.statuses[:approved])
    end
  end
end