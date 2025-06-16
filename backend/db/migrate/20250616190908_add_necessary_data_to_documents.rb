class AddNecessaryDataToDocuments < ActiveRecord::Migration[8.0]
  def change
    add_column :documents, :category, :string
    add_column :documents, :invoice_number, :string
    add_column :documents, :issue_date, :date
    add_column :documents, :company_name, :string
    rename_column :documents, :total_gross, :gross_amount
    rename_column :documents, :total_net, :net_amount
  end
end
