class AddSpaceToStorages < ActiveRecord::Migration[8.0]
  def change
    add_reference :storages, :space, foreign_key: true, null: true
    add_index :storages, [:space_id, :name]
  end
end


