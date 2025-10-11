class PurchaseItem < ApplicationRecord
  belongs_to :purchase_session
  belongs_to :item

  validates :quantity, numericality: { greater_than: 0 }
  validates :unit_price, numericality: { greater_than_or_equal_to: 0 }
  validates :total_price, numericality: { greater_than_or_equal_to: 0 }

  before_validation :calculate_total

  private

  def calculate_total
    self.total_price = quantity.to_f * unit_price.to_f
  end
end

