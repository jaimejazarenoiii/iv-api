class UpdateSubscriptionLimits < ActiveRecord::Migration[7.1]
  class Subscription < ApplicationRecord
    self.table_name = "subscriptions"
  end

  def up
    rename_column :subscriptions, :pantry_limit, :storage_limit
    add_column :subscriptions, :space_limit, :integer
    add_column :subscriptions, :item_limit, :integer

    Subscription.reset_column_information

    Subscription.find_each do |subscription|
      if subscription.plan == "free"
        subscription.update_columns(
          storage_limit: 3,
          space_limit: 1,
          item_limit: 10
        )
      else
        subscription.update_columns(
          storage_limit: nil,
          space_limit: nil,
          item_limit: nil
        )
      end
    end
  end

  def down
    Subscription.reset_column_information

    Subscription.find_each do |subscription|
      if subscription.plan == "free"
        subscription.update_columns(storage_limit: 10)
      end
    end

    remove_column :subscriptions, :item_limit
    remove_column :subscriptions, :space_limit
    rename_column :subscriptions, :storage_limit, :pantry_limit
  end
end



