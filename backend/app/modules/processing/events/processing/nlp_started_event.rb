module Processing
  class NlpStartedEvent < BasePublisher
    def self.call(document)
      publish(
        topic: :processing_stream,
        event: 'processing.nlp.started',
        data: {
          document_id: document.document_id
        }
      )
    end

  end
end