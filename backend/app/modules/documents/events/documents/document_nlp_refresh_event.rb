module Documents
  class DocumentNlpRefreshEvent < BasePublisher
    def self.call(document)
      publish(
        topic: :documents_stream,
        event: 'documents.nlp.refresh',
        data: {
          document_id: document.id,
          text_ocr: document.text_ocr
        }
      )
    end
  end
end
