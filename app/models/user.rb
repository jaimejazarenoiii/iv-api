class User < ApplicationRecord
  # Devise modules
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :trackable, :jwt_authenticatable,
         jwt_revocation_strategy: JwtDenylist

  # Associations
  has_many :storages, dependent: :destroy
  has_many :items, dependent: :destroy
  has_many :purchase_sessions, dependent: :destroy
  has_one :subscription, dependent: :destroy

  # Callbacks
  after_create :assign_default_subscription

  private

  def assign_default_subscription
    create_subscription!(
      plan: :free,
      pantry_limit: 10,
      started_at: Time.current
    )
  end
end
