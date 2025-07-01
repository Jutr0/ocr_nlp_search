json.array!(@documents) do |document|
  json.extract! document, :id, :doc_type, :status, :gross_amount, :net_amount, :category
  json.file do
    json.url document.file.url
    json.filename document.filename
    json.type document.file.content_type
  end
end