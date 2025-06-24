# app/modules/documents/publish_document_created.rb
module Documents
  class PublishDocumentCreated < BasePublisher
    def self.call(document)
      file_url = document.file.service_url(
        expires_in: 10.minutes,
        disposition: :inline
      )

      publish(
        topic: :documents_stream,
        event: 'document.created',
        data: {
          document_id: document.id,
          file_url:,
          filename: document.filename,
          content_type: document.file.content_type,
          user_id: document.user_id
        }
      )
    end
  end
end
