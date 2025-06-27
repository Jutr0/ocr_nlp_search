module Processing
  class NlpSucceededEvent < BasePublisher
    def self.call(document)
      publish(
        topic: :processing_stream,
        event: 'processing.nlp.succeeded',
        data: {
          document_id: document.document_id,
          extracted_fields: document.extracted_fields
        }
      )
    end

  end
end