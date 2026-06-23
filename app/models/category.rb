class Category < ApplicationRecord
  belongs_to :user
  has_and_belongs_to_many :items

  validates :name, presence: true, length: { maximum: 100 }
  validates :name, uniqueness: { scope: :user_id, message: "Category name already exists for this user" }
end

