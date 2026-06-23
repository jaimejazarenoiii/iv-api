class Subscription < ApplicationRecord
  belongs_to :user

  enum :plan, { free: 'free', premium: 'premium' }

  validates :plan, presence: true
  validates :space_limit, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
  validates :storage_limit, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
  validates :item_limit, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true

  before_validation :set_defaults, on: :create

  def active?
    expires_at.nil? || expires_at > Time.current
  end

  private

  def set_defaults
    if plan == 'free'
      self.space_limit ||= 1
      self.storage_limit ||= 3
      self.item_limit ||= 10
    else
      self.space_limit = nil if space_limit.nil?
      self.storage_limit = nil if storage_limit.nil?
      self.item_limit = nil if item_limit.nil?
    end
    self.started_at ||= Time.current
  end
end

