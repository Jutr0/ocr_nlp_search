json.extract! @document, :id, :filename, :status, :text_ocr, :category, :issue_date, :invoice_number,
              :doc_type, :company_name, :net_amount, :gross_amount, :nip, :currency
json.file do
  json.url @document.file.url
  json.filename @document.filename
  json.type @document.file.content_type
end

json.history_logs @document.history_logs do |history_log|
  json.extract! history_log, :created_at, :action
end