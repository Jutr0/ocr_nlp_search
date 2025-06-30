json.array!(@documents) do |document|
  json.extract! document, :id, :filename, :doc_type, :status, :gross_amount, :net_amount, :category
end