class AddRoleToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :role, :string
    User.update_all(role: "user")

    change_column_null :users, :role, false
    change_column_default :users, :email, from: "", to: nil
    change_column_default :users, :encrypted_password, from: "", to: nil
  end
end
