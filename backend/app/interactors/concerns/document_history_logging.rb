module DocumentHistoryLogging
  extend ActiveSupport::Concern

  private

  def log_document_history(document, action)
    log_result = CreateHistoryLog.call(document:, action:)

    if log_result.failure?
      context.fail!(error: log_result.error)
    end
  end
end
