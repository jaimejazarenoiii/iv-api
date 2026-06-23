require "test_helper"

class HierarchicalCountsTest < ActiveSupport::TestCase
  def setup
    @user = User.create!(
      email: "test@example.com",
      password: "password123",
      password_confirmation: "password123"
    )
    
    # Create spaces
    @space = @user.spaces.create!(name: "Kitchen", description: "Test kitchen")
    
    # Create storages
    @storage1 = @user.storages.create!(name: "Pantry", description: "Main pantry", space: @space)
    @storage2 = @user.storages.create!(name: "Cabinet", description: "Main cabinet", space: @space)
    
    # Create substorages
    @substorage1 = @user.storages.create!(name: "Spice Rack", description: "Spice substorage", space: @space, parent: @storage1)
    @substorage2 = @user.storages.create!(name: "Top Shelf", description: "Top shelf substorage", space: @space, parent: @storage1)
    @substorage3 = @user.storages.create!(name: "Bottom Shelf", description: "Bottom shelf substorage", space: @space, parent: @storage2)
    
    # Create sub-substorages (nested deeper)
    @subsubstorage = @user.storages.create!(name: "Inner Rack", description: "Inner substorage", space: @space, parent: @substorage1)
    
    # Create items in various storages
    @user.items.create!(name: "Rice", quantity: 1, unit: "kg", storage: @storage1)
    @user.items.create!(name: "Pasta", quantity: 1, unit: "box", storage: @storage2)
    @user.items.create!(name: "Salt", quantity: 1, unit: "g", storage: @substorage1)
    @user.items.create!(name: "Pepper", quantity: 1, unit: "g", storage: @substorage2)
    @user.items.create!(name: "Sugar", quantity: 1, unit: "kg", storage: @substorage3)
    @user.items.create!(name: "Cinnamon", quantity: 1, unit: "g", storage: @subsubstorage)
  end

  test "storage should count direct children correctly" do
    # @storage1 has @substorage1 and @substorage2 (2 direct children)
    # @storage2 has @substorage3 (1 direct child)
    # @substorage3 has no children
    assert_equal 3, @storage1.substorages_count  # 2 direct + 1 nested (@subsubstorage)
    assert_equal 1, @storage2.substorages_count  # 1 direct (@substorage3)
    assert_equal 0, @substorage3.substorages_count  # no children
  end

  test "storage should count nested substorages recursively" do
    # @storage1 has @substorage1 and @substorage2, @substorage1 has @subsubstorage
    # So @storage1 should have 3 total substorages (2 direct + 1 nested)
    assert_equal 3, @storage1.substorages_count
  end

  test "storage should count direct items correctly" do
    assert_equal 1, @storage1.items.count  # Rice
    assert_equal 1, @storage2.items.count  # Pasta
    assert_equal 1, @subsubstorage.items.count  # Cinnamon
  end

  test "storage should count items in substorages recursively" do
    # @storage1 has 1 direct item (Rice) + 1 item in @substorage1 (Salt) + 1 item in @substorage2 (Pepper) + 1 item in @subsubstorage (Cinnamon)
    # Total: 1 + 1 + 1 + 1 = 4 items
    assert_equal 4, @storage1.total_items_count
    
    # @storage2 has 1 direct item (Pasta) + 1 item in @substorage3 (Sugar)
    # Total: 1 + 1 = 2 items
    assert_equal 2, @storage2.total_items_count
  end

  test "space should count total substorages correctly" do
    # @space has @storage1 (3 substorages) + @storage2 (1 substorage) = 4 total substorages
    assert_equal 4, @space.total_substorages_count
  end

  test "space should count total items correctly" do
    # @space has all items: @storage1 (4 items) + @storage2 (2 items) = 6 total items
    # Wait, let me recount: Rice(1) + Pasta(1) + Salt(1) + Pepper(1) + Sugar(1) + Cinnamon(1) = 6 items
    assert_equal 6, @space.total_items_count_for_space
  end

  test "concern should handle empty associations gracefully" do
    empty_space = @user.spaces.create!(name: "Empty Space", description: "No storages")
    empty_storage = @user.storages.create!(name: "Empty Storage", description: "No items or children", space: empty_space)
    
    assert_equal 0, empty_space.total_substorages_count
    assert_equal 0, empty_space.total_items_count_for_space
    assert_equal 0, empty_storage.substorages_count
    assert_equal 0, empty_storage.total_items_count
  end
end
