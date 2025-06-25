module Processing
  class OcrSucceededEvent < BasePublisher
    def self.call(document)
      publish(
        topic: :processing_stream,
        event: 'processing.ocr.succeeded',
        data: {
          document_id: document.document_id,
          text_ocr: document.text_ocr
        }
      )
    end

  end
end