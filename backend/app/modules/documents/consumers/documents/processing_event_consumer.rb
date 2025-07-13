module Documents
  class ProcessingEventConsumer < ApplicationConsumer
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
        when "processing.ocr.failed"
          document.update!(status: Document.statuses[:ocr_retrying])
        when "processing.ocr.succeeded"
          document.update!(text_ocr: data.text_ocr, status: Document.statuses[:ocr_succeeded])
        when "processing.nlp.started"
          document.update!(status: Document.statuses[:nlp_processing])
        when "processing.nlp.failed"
          document.update!(status: Document.statuses[:nlp_retrying])
        when "processing.nlp.succeeded"
          puts data.extracted_fields.to_h
          document.update!(status: Document.statuses[:to_review], **data.extracted_fields.to_h)
        end
      end
    end
  end
end