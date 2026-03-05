class ChangeDocumentStatus
  include Interactor
  include DocumentHistoryLogging
  include Transactional

  def call
    context.document.update(status: status_from_action(context.action))

    unless context.document.valid?
      context.fail!(error: { message: context.document.errors.full_messages.join(", "), status: :unprocessable_entity })
    end

    log_document_history(context.document, context.action)
  end

  private

  def status_from_action(action)
    case action
    when :ocr_started then :ocr_processing
    when :ocr_failed then :ocr_retrying
    when :nlp_started then :nlp_processing
    when :nlp_failed then :nlp_retrying
    else nil
    end
  end
end
