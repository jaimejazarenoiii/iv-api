class CreateStorages < ActiveRecord::Migration[8.0]
  def change
    create_table :storages do |t|
      t.references :user, null: false, foreign_key: true
      t.references :parent, foreign_key: { to_table: :storages }, null: true
      t.string :name, null: false, limit: 100
      t.text :description, limit: 500

      t.timestamps
    end

    add_index :storages, [:user_id, :name]
  end
end

