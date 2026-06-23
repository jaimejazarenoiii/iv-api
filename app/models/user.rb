class User < ApplicationRecord
  # Devise modules
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :trackable, :jwt_authenticatable,
         jwt_revocation_strategy: JwtDenylist

  # Associations
  has_many :spaces, dependent: :destroy
  has_many :storages, dependent: :destroy
  has_many :items, dependent: :destroy
  has_many :purchase_sessions, dependent: :destroy
  has_one :subscription, dependent: :destroy
  has_many :categories, dependent: :destroy
  
  # Active Storage
  has_one_attached :profile_image

  # Validations
  validates :first_name, length: { maximum: 50 }, allow_blank: true
  validates :last_name, length: { maximum: 50 }, allow_blank: true
  validates :middle_name, length: { maximum: 50 }, allow_blank: true
  validates :gender, inclusion: { in: %w[male female other prefer_not_to_say] }, allow_blank: true
  validate :acceptable_profile_image

  # Callbacks
  after_create :assign_default_subscription

  # Helper method to get full name
  def full_name
    [first_name, middle_name, last_name].compact.join(' ').presence || email
  end

  # Get profile image URL
  def profile_image_url
    return nil unless profile_image.attached?
    
    Rails.application.routes.url_helpers.rails_blob_url(profile_image, only_path: true)
  end

  LIMITABLE_RESOURCES = {
    spaces: {
      association: :spaces,
      limit_attribute: :space_limit,
      label: "space"
    },
    storages: {
      association: :storages,
      limit_attribute: :storage_limit,
      label: "storage"
    },
    items: {
      association: :items,
      limit_attribute: :item_limit,
      label: "item"
    }
  }.freeze

  def limit_value_for(resource)
    mapping = LIMITABLE_RESOURCES[resource]
    return nil unless mapping

    subscription&.public_send(mapping[:limit_attribute])
  end

  def limit_reached?(resource)
    mapping = LIMITABLE_RESOURCES[resource]
    return false unless mapping

    limit = limit_value_for(resource)
    return false if limit.nil?

    send(mapping[:association]).count >= limit
  end

  def limit_label_for(resource)
    LIMITABLE_RESOURCES.dig(resource, :label)
  end

  def limit_error_message(resource)
    limit = limit_value_for(resource)
    label = limit_label_for(resource) || resource.to_s.singularize
    return nil if limit.nil?

    pluralized_label = limit == 1 ? label : ActiveSupport::Inflector.pluralize(label)
    "Your current plan allows up to #{limit} #{pluralized_label}. Upgrade your subscription to increase this limit."
  end

  private

  def assign_default_subscription
    create_subscription!(
      plan: :free,
      space_limit: 1,
      storage_limit: 3,
      item_limit: 10,
      started_at: Time.current
    )
  end

  def acceptable_profile_image
    return unless profile_image.attached?

    unless profile_image.byte_size <= 5.megabytes
      errors.add(:profile_image, 'is too large (maximum is 5MB)')
    end

    acceptable_types = ['image/jpeg', 'image/png', 'image/gif', 'image/webp']
    unless acceptable_types.include?(profile_image.content_type)
      errors.add(:profile_image, 'must be a JPEG, PNG, GIF, or WebP image')
    end
  end
end
