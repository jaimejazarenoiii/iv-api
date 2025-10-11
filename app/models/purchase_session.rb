class PurchaseSession < ApplicationRecord
  belongs_to :user
  has_many :purchase_items, dependent: :destroy
  has_many :items, through: :purchase_items

  validates :store_name, presence: true
  validates :total_amount, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
  validates :purchased_at, presence: true

  before_validation :set_default_date

  private

  def set_default_date
    self.purchased_at ||= Time.current
  end
end

