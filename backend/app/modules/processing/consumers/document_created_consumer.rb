module Processing
  class DocumentCreatedConsumer < ApplicationConsumer
    def consume
      params_batch.each do |message|
        payload = JSON.parse(message.payload, object_class: OpenStruct)
        if payload.event == "document.created"
          OcrJob.perform_later(payload.data)
        end
      end
    end
  end
end