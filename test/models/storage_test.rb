require "test_helper"

class StorageTest < ActiveSupport::TestCase
  def setup
    @user = User.create!(
      email: "test@example.com",
      password: "password123",
      password_confirmation: "password123"
    )
    @storage = @user.storages.build(name: "Pantry")
  end

  test "should be valid with valid attributes" do
    assert @storage.valid?
  end

  test "should require name" do
    @storage.name = nil
    assert_not @storage.valid?
    assert_includes @storage.errors[:name], "can't be blank"
  end

  test "should not allow name longer than 100 characters" do
    @storage.name = "a" * 101
    assert_not @storage.valid?
  end

  test "should allow name up to 100 characters" do
    @storage.name = "a" * 100
    assert @storage.valid?
  end

  test "should not allow description longer than 500 characters" do
    @storage.description = "a" * 501
    assert_not @storage.valid?
  end

  test "should belong to user" do
    assert_respond_to @storage, :user
  end

  test "should have optional parent" do
    @storage.save
    child = @user.storages.create!(name: "Shelf", parent: @storage)
    assert_equal @storage, child.parent
  end

  test "should have many children" do
    @storage.save
    assert_respond_to @storage, :children
    child = @user.storages.create!(name: "Shelf", parent: @storage)
    assert_includes @storage.children, child
  end

  test "should have many items" do
    @storage.save
    assert_respond_to @storage, :items
  end

  test "should destroy children when deleted" do
    @storage.save
    child = @user.storages.create!(name: "Shelf", parent: @storage)
    
    assert_difference "Storage.count", -2 do
      @storage.destroy
    end
  end
end

