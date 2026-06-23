class AddTrackableToUsers < ActiveRecord::Migration[8.0]
  def change
    unless column_exists?(:users, :sign_in_count)
      add_column :users, :sign_in_count, :integer, default: 0, null: false
      add_column :users, :current_sign_in_at, :datetime
      add_column :users, :last_sign_in_at, :datetime
      add_column :users, :current_sign_in_ip, :string
      add_column :users, :last_sign_in_ip, :string
    end
  end
end

