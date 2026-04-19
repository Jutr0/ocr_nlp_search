class AddConfidenceColumnsToDocuments < ActiveRecord::Migration[8.0]
  def change
    add_column :documents, :ocr_confidence, :integer
    add_column :documents, :nlp_confidence, :integer
  end
end
