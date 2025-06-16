require 'net/http'
require 'json'

class NlpJob < ApplicationJob
  queue_as :default

  def perform(document_id)
    document = Document.find(document_id)
    return unless document.text_ocr.present?
    document.update!(status: Document.statuses[:nlp_processing])
    result = analyze_with_llm(document.text_ocr)
    puts result
    parsed = extract_json_from_response(result)

    document.update!(
      doc_type: parsed["document_type"],
      net_amount: extract_decimal(parsed["net_amount"]),
      gross_amount: extract_decimal(parsed["gross_amount"]),
      currency: parsed["currency"],
      category: parsed["category"],
      invoice_number: parsed["invoice_number"],
      issue_date: parsed["issue_date"],
      company_name: parsed["company_name"],
      nip: parsed["nip"],
      status: Document.statuses[:to_review]
    )
  rescue => e
    Rails.logger.error "[NlpJob] Error for Document #{document_id}: #{e.message}"
    document.update!(status: Document.statuses[:nlp_failed]) if document
    raise e
  end

  private

  def analyze_with_llm(ocr_text)
    uri = URI("http://localhost:11434/api/generate")
    req = Net::HTTP::Post.new(uri, 'Content-Type' => 'application/json')
    req.body = {
      model: "llama3",
      stream: false,
      prompt: <<~PROMPT
                You are a JSON extraction engine for financial documents.

        Given the OCR text of a scanned document, extract ONLY the following flat JSON object, using EXACT keys and no nesting:

        {
          "document_type": "invoice",            // one of: "invoice", "bill", "receipt", "other"
          "category": "IT services",             // free text but required! example: "Bills", "Utilities", "Food", "Travel", "Healthcare", "Other"
          "invoice_number": "FV-123/2024",
          "issue_date": "2024-04-12",            // YYYY-MM-DD
          "net_amount": 123.45,
          "gross_amount": 151.84,
          "currency": "PLN",                     // one of: [ "PLN", "EUR", "USD", ...]
          "nip": "1234567890",                   // optional but in strict schema: (just 10 numbers without dashes or spaces)
          "company_name": "Acme Sp. z o.o."
        }

        Output must be ONLY valid JSON with the specified fields.  
        Do not wrap in markdown, do not include explanations, headers, or comments.
        Remember to start with { and end with }
              OCR TEXT:
              \"\"\"
              #{truncate_ocr_text(ocr_text)}
              \"\"\"
      PROMPT
    }.to_json
    puts req.body
    res = Net::HTTP.start(uri.hostname, uri.port) { |http| http.request(req) }
    body = JSON.parse(res.body)
    body["response"]
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
