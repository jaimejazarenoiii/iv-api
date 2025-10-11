class Subscription < ApplicationRecord
  belongs_to :user

  enum :plan, { free: 'free', premium: 'premium' }

  validates :plan, presence: true
  validates :pantry_limit, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true

  before_validation :set_defaults, on: :create

  def active?
    expires_at.nil? || expires_at > Time.current
  end

  private

  def set_defaults
    self.pantry_limit ||= plan == 'free' ? 10 : nil
    self.started_at ||= Time.current
  end
end

