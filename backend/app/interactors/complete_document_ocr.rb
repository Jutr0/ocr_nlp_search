class CompleteDocumentOcr
  include Interactor
  include DocumentHistoryLogging

  def call
    ActiveRecord::Base.transaction do
      updated_document = context.document.update(status: status_from_action(context.action), text_ocr: context.text_ocr)

      unless updated_document.valid?
        context.fail!(errors: { message: updated_document.errors.full_messages.join(", "), status: :unprocessable_entity })
      end

      log_document_history(updated_document, :ocr_succeeded)
    end
  end
end