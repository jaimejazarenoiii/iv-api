class Item < ApplicationRecord
  belongs_to :user
  belongs_to :storage
  has_many :purchase_items, dependent: :destroy
  has_many :purchase_sessions, through: :purchase_items

  validates :name, presence: true, length: { maximum: 100 }
  validates :quantity, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
  validates :unit, presence: true
  validates :min_quantity, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true

  def low_stock?
    min_quantity.present? && quantity.to_f <= min_quantity
  end
end

