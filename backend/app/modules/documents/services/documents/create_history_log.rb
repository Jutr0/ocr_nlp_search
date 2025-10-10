module Documents
  class CreateHistoryLog
    include Interactor

    def call
      DocumentHistoryLog.create(document: context.document, action: context.action)
    end
  end
end