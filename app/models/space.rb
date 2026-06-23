class Space < ApplicationRecord
  belongs_to :user
  has_many :storages, dependent: :destroy
  has_many :items, through: :storages
  
  # Active Storage
  has_one_attached :image

  validates :name, presence: true, length: { maximum: 100 }
  validates :description, length: { maximum: 500 }, allow_blank: true
  validate :acceptable_image

  # Get image URL
  def image_url
    return nil unless image.attached?
    
    Rails.application.routes.url_helpers.rails_blob_url(image, only_path: true)
  end

  public :image_url

  # Count all substorages (including nested ones) for spaces
  def total_substorages_count
    # Only count top-level storages (those without a parent)
    top_level_storages = storages.where(parent_id: nil)
    top_level_storages.sum(&:substorages_count)
  end

  # Count all items including those in substorages recursively for spaces
  def total_items_count_for_space
    # Only count top-level storages (those without a parent)
    top_level_storages = storages.where(parent_id: nil)
    top_level_storages.sum(&:total_items_count)
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


