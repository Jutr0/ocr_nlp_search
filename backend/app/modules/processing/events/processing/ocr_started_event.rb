module Processing
  class OcrStartedEvent < BasePublisher
    def self.call(document)
      publish(
        topic: :processing_stream,
        event: 'processing.ocr.started',
        data: {
          document_id: document.document_id
        }
      )
    end

  end
end