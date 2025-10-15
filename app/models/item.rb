class Item < ApplicationRecord
  belongs_to :user
  belongs_to :storage
  has_many :purchase_items, dependent: :destroy
  has_many :purchase_sessions, through: :purchase_items
  
  # Active Storage
  has_one_attached :image

  validates :name, presence: true, length: { maximum: 100 }
  validates :quantity, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
  validates :unit, presence: true
  validates :min_quantity, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
  validates :out_of_stock_threshold, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
  validate :acceptable_image

  def low_stock?
    return false unless low_stock_alert_enabled
    min_quantity.present? && quantity.to_f <= min_quantity
  end

  def out_of_stock?
    return false unless out_of_stock_alert_enabled
    out_of_stock_threshold.present? && quantity.to_f <= out_of_stock_threshold
  end

  def location_path
    path_parts = []
    
    # Add space name if storage has a space
    if storage.space.present?
      path_parts << storage.space.name
    end
    
    # Build storage hierarchy from root to current
    storage_hierarchy = build_storage_hierarchy(storage)
    path_parts.concat(storage_hierarchy)
    
    # Add item name at the end
    path_parts << name
    
    path_parts.join(' > ')
  end

  def location_array
    path_parts = []
    
    # Add space if present
    if storage.space.present?
      path_parts << { type: 'space', id: storage.space.id, name: storage.space.name }
    end
    
    # Build storage hierarchy
    current_storage = storage
    storage_chain = []
    
    while current_storage.present?
      storage_chain.unshift({ type: 'storage', id: current_storage.id, name: current_storage.name })
      current_storage = current_storage.parent
    end
    
    path_parts.concat(storage_chain)
    
    # Add item at the end
    path_parts << { type: 'item', id: id, name: name }
    
    path_parts
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

  # Get image URL
  def image_url
    return nil unless image.attached?
    
    Rails.application.routes.url_helpers.rails_blob_url(image, only_path: true)
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

