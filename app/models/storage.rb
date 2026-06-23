class Storage < ApplicationRecord
  belongs_to :user
  belongs_to :space, optional: true
  belongs_to :parent, class_name: 'Storage', optional: true
  has_many :children, class_name: 'Storage', foreign_key: 'parent_id', dependent: :destroy
  has_many :items, dependent: :destroy
  
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

  # Count all substorages (children) recursively
  def substorages_count
    children.count + children.sum(&:substorages_count)
  end

  # Count all items including those in substorages recursively
  def total_items_count
    items.count + children.sum(&:total_items_count)
  end

  # Get breadcrumb-style location path (path TO this storage, not including self)
  def location_path
    path_parts = []
    
    # Add space name if storage has a space
    if space.present?
      path_parts << space.name
    end
    
    # Build storage hierarchy from root to parent (excluding self)
    storage_hierarchy = build_storage_hierarchy(parent)
    path_parts.concat(storage_hierarchy)
    
    path_parts.join(' > ')
  end

  private

  def build_storage_hierarchy(current_storage)
    hierarchy = []
    
    while current_storage.present?
      hierarchy.unshift(current_storage.name)
      current_storage = current_storage.parent
    end
    
    hierarchy
  end

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

