module Documents
  class OcrEventConsumer < ApplicationConsumer
    def consume
      messages.each do |message|
        payload = JSON.parse(message.raw_payload, object_class: OpenStruct)
        event = payload.event
        data = OpenStruct.new(payload.data)
        document = Document.find_by(id: data.document_id)
        next unless document.present?

        case event
        when "processing.ocr.started"
          document.update!(status: Document.statuses[:ocr_processing])
        when "processing.ocr.retrying"
          document.update!(status: Document.statuses[:ocr_retrying])
        when "processing.ocr.succeeded"
          document.update!(text_ocr: data.text_ocr, status: Document.statuses[:ocr_succeeded])
        end
      end
    end
  end
end