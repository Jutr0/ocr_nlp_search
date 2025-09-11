class CreateDocumentHistoryLogs < ActiveRecord::Migration[8.0]
  def change
    create_table :document_history_logs, id: :uuid do |t|
      t.string :action, null: false
      t.string :previous_state
      t.string :current_state
      t.references :document, foreign_key: true, type: :uuid, index: true, null: false
      t.timestamps
    end
  end
end
