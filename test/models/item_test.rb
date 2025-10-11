require "test_helper"

class ItemTest < ActiveSupport::TestCase
  def setup
    @user = User.create!(
      email: "test@example.com",
      password: "password123",
      password_confirmation: "password123"
    )
    @storage = @user.storages.create!(name: "Pantry")
    @item = @user.items.build(
      name: "Olive Oil",
      storage: @storage,
      unit: "oz",
      quantity: 32,
      min_quantity: 16
    )
  end

  test "should be valid with valid attributes" do
    assert @item.valid?
  end

  test "should require name" do
    @item.name = nil
    assert_not @item.valid?
  end

  test "should require unit" do
    @item.unit = nil
    assert_not @item.valid?
  end

  test "should not allow name longer than 100 characters" do
    @item.name = "a" * 101
    assert_not @item.valid?
  end

  test "should require quantity to be non-negative" do
    @item.quantity = -1
    assert_not @item.valid?
  end

  test "should require min_quantity to be non-negative" do
    @item.min_quantity = -1
    assert_not @item.valid?
  end

  test "should belong to user" do
    assert_respond_to @item, :user
  end

  test "should belong to storage" do
    assert_respond_to @item, :storage
  end

  test "low_stock? should return true when quantity is below min" do
    @item.quantity = 10
    @item.min_quantity = 16
    assert @item.low_stock?
  end

  test "low_stock? should return true when quantity equals min" do
    @item.quantity = 16
    @item.min_quantity = 16
    assert @item.low_stock?
  end

  test "low_stock? should return false when quantity is above min" do
    @item.quantity = 20
    @item.min_quantity = 16
    assert_not @item.low_stock?
  end

  test "low_stock? should return false when min_quantity is nil" do
    @item.min_quantity = nil
    assert_not @item.low_stock?
  end
end

