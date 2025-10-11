class CreateSubscriptions < ActiveRecord::Migration[8.0]
  def change
    create_table :subscriptions do |t|
      t.references :user, null: false, foreign_key: true, index: { unique: true }
      t.string :plan, null: false, default: 'free'
      t.integer :pantry_limit
      t.datetime :started_at
      t.datetime :expires_at

      t.timestamps
    end
  end
end

