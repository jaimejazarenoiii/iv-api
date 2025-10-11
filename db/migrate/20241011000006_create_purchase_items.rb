class CreatePurchaseItems < ActiveRecord::Migration[8.0]
  def change
    create_table :purchase_items do |t|
      t.references :purchase_session, null: false, foreign_key: true
      t.references :item, null: false, foreign_key: true
      t.decimal :quantity, precision: 10, scale: 2, null: false
      t.decimal :unit_price, precision: 10, scale: 2, null: false
      t.decimal :total_price, precision: 10, scale: 2, null: false

      t.timestamps
    end

    add_index :purchase_items, [:purchase_session_id, :item_id], unique: true
  end
end

