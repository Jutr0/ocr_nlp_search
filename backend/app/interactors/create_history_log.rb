class CreateHistoryLog
  include Interactor

  def call
    document_history_log = DocumentHistoryLog.create(document: context.document, action: context.action)

    unless document_history_log.valid?
      context.fail!(errors: { message: document_history_log.errors.full_messages.join(", "), status: :unprocessable_entity })
    end
  end
end
