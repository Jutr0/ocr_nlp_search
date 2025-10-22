class CompleteDocumentNlp
  include Interactor
  include DocumentHistoryLogging

  def call
    ActiveRecord::Base.transaction do
      attributes = { status: status_from_action(context.action) }.merge(context.extracted_data)
      updated_document = context.document.update(attributes)

      unless updated_document.valid?
        context.fail!(errors: { message: updated_document.errors.full_messages.join(", "), status: :unprocessable_entity })
      end

      log_document_history(updated_document, :nlp_succeeded)
    end
  end
end
