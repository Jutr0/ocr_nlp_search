module Documents
  class CreateDocument
    include Interactor

    def call
      ActiveRecord::Base.transaction do
        document = Document.create!(status: :pending, file: context.file, filename: context.file&.original_filename, user_id: context.user_id)
        context.document = document

        CreateHistoryLog.call!(document: document, action: DocumentHistoryLog.actions[:created])
        DocumentCreatedEvent.call(document)
      end
    end
  end
end