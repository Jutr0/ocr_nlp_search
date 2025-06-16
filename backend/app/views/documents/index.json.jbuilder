json.array!(@documents) do |document|
  json.extract! document, :id, :created_at, :filename, :doc_type, :status, :gross_amount
end