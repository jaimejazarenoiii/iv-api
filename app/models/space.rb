class Space < ApplicationRecord
  belongs_to :user
  has_many :storages, dependent: :destroy
  has_many :items, through: :storages
  
  # Active Storage
  has_one_attached :image

  validates :name, presence: true, length: { maximum: 100 }
  validates :description, length: { maximum: 500 }, allow_blank: true
  validates :space_type, presence: true
  validate :acceptable_image

  # Common space types
  SPACE_TYPES = %w[
    bedroom
    kitchen
    bathroom
    living_room
    dining_room
    garage
    basement
    attic
    office
    closet
    outdoor
    storage_unit
    other
  ].freeze

  validates :space_type, inclusion: { in: SPACE_TYPES }

  # Get image URL
  def image_url
    return nil unless image.attached?
    
    Rails.application.routes.url_helpers.rails_blob_url(image, only_path: true)
  end

  private

  def acceptable_image
    return unless image.attached?

    unless image.byte_size <= 5.megabytes
      errors.add(:image, 'is too large (maximum is 5MB)')
    end

    acceptable_types = ['image/jpeg', 'image/png', 'image/gif', 'image/webp']
    unless acceptable_types.include?(image.content_type)
      errors.add(:image, 'must be a JPEG, PNG, GIF, or WebP image')
    end
  end
end


