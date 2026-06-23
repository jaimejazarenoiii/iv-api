class RemoveSpaceTypeFromSpaces < ActiveRecord::Migration[7.0]
  def change
    remove_index :spaces, [:user_id, :space_type]
    remove_column :spaces, :space_type, :string
  end
end
