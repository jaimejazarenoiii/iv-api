class Storage < ApplicationRecord
  belongs_to :user
  belongs_to :parent, class_name: 'Storage', optional: true
  has_many :children, class_name: 'Storage', foreign_key: 'parent_id', dependent: :destroy
  has_many :items, dependent: :destroy

  validates :name, presence: true, length: { maximum: 100 }
  validates :description, length: { maximum: 500 }, allow_blank: true
end

