class AddProfileFieldsToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :first_name, :string, limit: 50
    add_column :users, :last_name, :string, limit: 50
    add_column :users, :middle_name, :string, limit: 50
    add_column :users, :gender, :string, limit: 20
  end
end

