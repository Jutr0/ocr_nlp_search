module Documents
  class CreateHistoryLog
    include Interactor

    def call
      document_history_log = DocumentHistoryLog.create(document: context.document, action: context.action)

      unless document_history_log.valid?
        context.fail!(errors: document_history_log.errors)
      end
    end
  end
end