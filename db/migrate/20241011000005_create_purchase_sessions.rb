class CreatePurchaseSessions < ActiveRecord::Migration[8.0]
  def change
    create_table :purchase_sessions do |t|
      t.references :user, null: false, foreign_key: true
      t.string :store_name, null: false
      t.decimal :total_amount, precision: 10, scale: 2
      t.datetime :purchased_at, null: false
      t.text :notes

      t.timestamps
    end

    add_index :purchase_sessions, [:user_id, :purchased_at]
  end
end

