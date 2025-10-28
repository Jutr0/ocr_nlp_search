class AddUserReferenceToDocument < ActiveRecord::Migration[8.0]
  def change
    add_reference :documents, :user, foreign_key: true, type: :uuid

    Document::Document.update_all(user_id: User.user.first.id)

    change_column_null :documents, :user_id, false
  end
end
