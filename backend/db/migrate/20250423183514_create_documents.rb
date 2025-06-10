class CreateDocuments < ActiveRecord::Migration[8.0]
  def change

    enable_extension "pgcrypto" unless extension_enabled?("pgcrypto")
    enable_extension "unaccent" unless extension_enabled?("unaccent")

    create_table :documents, id: :uuid do |t|
      t.string :filename
      t.string :content_type
      t.string :status, null: false

      t.string :doc_type
      t.decimal :total_net, precision: 15, scale: 2
      t.decimal :total_gross, precision: 15, scale: 2
      t.string :currency, limit: 3
      t.string :nip, limit: 10

      t.text :text_ocr

      t.tsvector :tsdoc,
                 as: "to_tsvector('simple', coalesce(text_ocr, ''))",
                 stored: true

      t.datetime :processed_at
      t.timestamps
    end

    add_index :documents, :tsdoc, using: :gin
    add_index :documents, :status
    add_index :documents, :doc_type
    add_index :documents, :created_at
  end
end
