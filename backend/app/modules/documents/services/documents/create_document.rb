module Documents
  class CreateDocument
    include Interactor

    def call
      ActiveRecord::Base.transaction do
        document = Document.create!(status: :pending, file: context.file, filename: context.file&.original_filename, user_id: context.user_id)
        context.document = document

        CreateHistoryLog.call!(document: document, action: DocumentHistoryLog.actions[:created])
      end

      Processing::OcrJob.perform_later(
        document_id: context.document.id,
        file_url: context.document.file.url,
        filename: context.document.filename,
        content_type: context.document.file.content_type,
        user_id: context.document.user_id
      )
    end
  end
end
