module Documents
  class DocumentOcrRefreshEvent < BasePublisher
    def self.call(document)
      publish(
        topic: :documents_stream,
        event: 'documents.ocr.refresh',
        data: {
          document_id: document.id,
          file_url: document.file.url,
          filename: document.filename,
          content_type: document.file.content_type,
          user_id: document.user_id
        }
      )
    end
  end
end
