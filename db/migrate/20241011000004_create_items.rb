class CreateItems < ActiveRecord::Migration[8.0]
  def change
    create_table :items do |t|
      t.references :user, null: false, foreign_key: true
      t.references :storage, null: false, foreign_key: true
      t.string :name, null: false, limit: 100
      t.decimal :quantity, precision: 10, scale: 2
      t.string :unit, null: false
      t.decimal :min_quantity, precision: 10, scale: 2
      t.date :expiration_date
      t.text :notes

      t.timestamps
    end

    add_index :items, [:user_id, :name]
    add_index :items, [:storage_id, :name]
  end
end

