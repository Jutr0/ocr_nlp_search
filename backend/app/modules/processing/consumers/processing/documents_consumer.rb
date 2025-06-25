module Processing
  class DocumentsConsumer < ApplicationConsumer
    def consume
      messages.each do |message|
        payload = JSON.parse(message.raw_payload)
        if ["documents.created", "documents.ocr.refresh"].include?(payload["event"])
          OcrJob.perform_later(payload["data"])
        elsif ["documents.nlp.refresh"].include?(payload["event"])
          NlpJob.perform_later(payload["data"])
        end
      end
    end
  end
end