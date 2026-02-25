module Documents
  class ProcessingEventConsumer < ApplicationConsumer
    def consume
      messages.each do |message|
        payload = parse_payload(message)
        process_event(payload)
      end
    end

    private

    def process_event(payload)
      document = Document.find_by(id: payload.data.document_id)
      return unless document

      handle_event(document, payload.event, payload.data)
    end

    def handle_event(document, event, data)
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