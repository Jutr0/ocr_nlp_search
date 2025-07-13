require 'net/http'
require 'json'
require 'openai'

module Processing
  class NlpJob < ApplicationJob
    queue_as :default

    def perform(document)

      document = StructUtils.deep_ostruct(document)
      return unless document&.text_ocr.present?

      NlpStartedEvent.call(document)

      result = analyze_with_llm(document.text_ocr)
      parsed = extract_json_from_response(result)

      document.extracted_fields = {
        doc_type: parsed["document_type"],
        net_amount: extract_decimal(parsed["net_amount"]),
        gross_amount: extract_decimal(parsed["gross_amount"]),
        currency: parsed["currency"],
        category: parsed["category"],
        invoice_number: parsed["invoice_number"],
        issue_date: parsed["issue_date"],
        company_name: parsed["company_name"],
        nip: parsed["nip"]
      }

      NlpSucceededEvent.call(document)
    rescue => e
      Rails.logger.error "[NlpJob] Error for Document #{document.document_id}: #{e.message}"
      NlpFailedEvent.call(document, { message: e.message })
      raise e
    end

    private

    def analyze_with_llm(ocr_text)
      client = OpenAI::Client.new(access_token: Rails.configuration.open_ai_api_key)

      res = client.chat(
        parameters: {
          model: "gpt-3.5-turbo",
          temperature: 0,
          messages: [
            {
              role: "system",
              content: "You are a financial document parser. Extract structured data from messy OCR text and return valid JSON."
            },
            {
              role: "user",
              content: <<~TEXT
                OCR TEXT:
                \"\"\"
                #{ocr_text}
                \"\"\"

                Return this JSON format (no explanations!):

                {
                  "document_type": "invoice", // one of: invoice, bill, receipt, other
                  "category": "it_services", // one of: it_services, office_supplies, travel_&_transportation, marketing_&_advertising, legal_&_accounting, utilities_&_subscriptions, other
                  "invoice_number": "...",
                  "issue_date": "YYYY-MM-DD",
                  "net_amount": ...,
                  "gross_amount": ...,
                  "currency": "PLN", //currency in 3 letters
                  "nip": "...", //must be 10 digits (no dashes)
                  "company_name": "..."
                }
              TEXT
            }
          ]
        }).to_json
      JSON.parse(res).dig("choices", 0, "message", "content")
    end

    def extract_decimal(val)
      return nil unless val
      val.to_s[/[\d,.]+/].to_s.gsub(",", ".").to_d rescue nil
    end

    def extract_json_from_response(response_text)
      json_start = response_text.index('{')
      json_end = response_text.rindex('}')
      raise "No JSON found in response" unless json_start && json_end

      json_str = response_text[json_start..json_end]
      JSON.parse(json_str)
    end

    def truncate_ocr_text(text, max_tokens: 1000)
      max_chars = max_tokens * 4

      return text if text.length <= max_chars

      truncated = text[0...max_chars]
      last_newline = truncated.rindex("\n") || max_chars
      truncated[0...last_newline].strip
    end
  end
end
