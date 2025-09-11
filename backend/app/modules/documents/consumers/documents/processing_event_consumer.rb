module Documents
  class ProcessingEventConsumer < ApplicationConsumer
    def consume
      messages.each do |message|
        payload = JSON.parse(message.raw_payload, object_class: OpenStruct)
        event = payload.event
        data = OpenStruct.new(payload.data)
        document = Document.find_by(id: data.document_id)
        next unless document.present?

        action = nil
        case event
        when "processing.ocr.started"
          action = DocumentHistoryLog.actions[:ocr_started]
          document.update!(status: Document.statuses[:ocr_processing])
        when "processing.ocr.failed"
          action = DocumentHistoryLog.actions[:ocr_failed]
          document.update!(status: Document.statuses[:ocr_retrying])
        when "processing.ocr.succeeded"
          action = DocumentHistoryLog.actions[:ocr_succeeded]
          document.update!(text_ocr: data.text_ocr, status: Document.statuses[:ocr_succeeded])
        when "processing.nlp.started"
          action = DocumentHistoryLog.actions[:nlp_started]
          document.update!(status: Document.statuses[:nlp_processing])
        when "processing.nlp.failed"
          action = DocumentHistoryLog.actions[:nlp_failed]
          document.update!(status: Document.statuses[:nlp_retrying])
        when "processing.nlp.succeeded"
          action = DocumentHistoryLog.actions[:nlp_succeeded]
          document.update!(status: Document.statuses[:to_review], **data.extracted_fields.to_h)
        end

        CreateHistoryLog.call!(document:, action:)
      end
    end
  end
end