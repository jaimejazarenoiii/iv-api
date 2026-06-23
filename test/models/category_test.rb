require "test_helper"

class CategoryTest < ActiveSupport::TestCase
  def setup
    @user = User.create!(
      email: "test@example.com",
      password: "password123",
      password_confirmation: "password123"
    )
    @category = @user.categories.build(name: "Spices")
  end

  test "should be valid" do
    assert @category.valid?
  end

  test "should require name" do
    @category.name = nil
    assert_not @category.valid?
    assert_includes @category.errors[:name], "can't be blank"
  end

  test "should limit name length" do
    @category.name = "a" * 101
    assert_not @category.valid?
    assert_includes @category.errors[:name], "is too long (maximum is 100 characters)"
  end

  test "should require user" do
    @category.user = nil
    assert_not @category.valid?
  end

  test "should enforce unique name per user" do
    @category.save!
    duplicate = @user.categories.build(name: "Spices")
    assert_not duplicate.valid?
    assert_includes duplicate.errors[:name], "Category name already exists for this user"
  end

  test "should allow same name for different users" do
    @category.save!
    other_user = User.create!(
      email: "other@example.com",
      password: "password123",
      password_confirmation: "password123"
    )
    other_category = other_user.categories.build(name: "Spices")
    assert other_category.valid?
  end

  test "should have many items" do
    @category.save!
    storage = @user.storages.create!(name: "Pantry")
    item1 = @user.items.create!(name: "Salt", storage: storage, unit: "oz")
    item2 = @user.items.create!(name: "Pepper", storage: storage, unit: "oz")
    
    @category.items << item1
    @category.items << item2
    
    assert_equal 2, @category.items.count
    assert_includes @category.items, item1
    assert_includes @category.items, item2
  end

  test "should destroy join records when destroyed" do
    @category.save!
    storage = @user.storages.create!(name: "Pantry")
    item = @user.items.create!(name: "Salt", storage: storage, unit: "oz")
    @category.items << item
    
    assert_difference "Category.count", -1 do
      @category.destroy
    end
    
    # Join table records should be removed
    assert_equal 0, item.categories.count
  end
end

