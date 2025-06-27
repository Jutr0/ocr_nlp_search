module Processing
  class NlpFailedEvent < BasePublisher
    def self.call(document, error)
      publish(
        topic: :processing_stream,
        event: 'processing.nlp.failed',
        data: {
          document_id: document.document_id,
          error: error
        }
      )
    end

  end
end