module Processing
  class OcrFailedEvent < BasePublisher
    def self.call(document, error)
      publish(
        topic: :processing_stream,
        event: 'processing.ocr.failed',
        data: {
          document_id: document.document_id,
          error: error
        }
      )
    end

  end
end