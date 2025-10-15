class CreateSpaces < ActiveRecord::Migration[8.0]
  def change
    create_table :spaces do |t|
      t.references :user, null: false, foreign_key: true
      t.string :name, null: false, limit: 100
      t.string :space_type, null: false
      t.text :description, limit: 500

      t.timestamps
    end

    add_index :spaces, [:user_id, :name]
    add_index :spaces, [:user_id, :space_type]
  end
end


