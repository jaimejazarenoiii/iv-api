class CreateItemsCategories < ActiveRecord::Migration[8.0]
  def change
    create_table :categories_items, id: false do |t|
      t.references :category, null: false, foreign_key: true
      t.references :item, null: false, foreign_key: true
    end

    add_index :categories_items, [:category_id, :item_id], unique: true
  end
end
