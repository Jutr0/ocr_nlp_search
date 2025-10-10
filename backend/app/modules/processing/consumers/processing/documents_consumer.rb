module Processing
  class DocumentsConsumer < ApplicationConsumer
    def consume
      messages.each do |message|
        payload = parse_payload(message)
        process_event(payload)
      end
    end

    private

    def process_event(payload)
      handle_event(payload.event, payload.data)
    end

    def handle_event(event, data)
      case event
      when "documents.created", "documents.ocr.refresh"
        OcrJob.perform_later(data)
      when "documents.nlp.refresh"
        NlpJob.perform_later(data)
      end
    end
  end
end