class AddStockAlertsToItems < ActiveRecord::Migration[8.0]
  def change
    add_column :items, :out_of_stock_threshold, :decimal, precision: 10, scale: 2
    add_column :items, :low_stock_alert_enabled, :boolean, default: true
    add_column :items, :out_of_stock_alert_enabled, :boolean, default: true
  end
end

