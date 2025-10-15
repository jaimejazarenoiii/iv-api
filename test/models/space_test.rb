require "test_helper"

class SpaceTest < ActiveSupport::TestCase
  def setup
    @user = User.create!(
      email: "test@example.com",
      password: "password123",
      password_confirmation: "password123"
    )
    @space = @user.spaces.build(name: "Kitchen", space_type: "kitchen")
  end

  test "should be valid with valid attributes" do
    assert @space.valid?
  end

  test "should require name" do
    @space.name = nil
    assert_not @space.valid?
    assert_includes @space.errors[:name], "can't be blank"
  end

  test "should require space_type" do
    @space.space_type = nil
    assert_not @space.valid?
    assert_includes @space.errors[:space_type], "can't be blank"
  end

  test "should not allow name longer than 100 characters" do
    @space.name = "a" * 101
    assert_not @space.valid?
  end

  test "should not allow description longer than 500 characters" do
    @space.description = "a" * 501
    assert_not @space.valid?
  end

  test "should belong to user" do
    assert_respond_to @space, :user
  end

  test "should have many storages" do
    @space.save
    assert_respond_to @space, :storages
  end

  test "should only accept valid space types" do
    valid_types = %w[bedroom kitchen bathroom living_room garage basement]
    valid_types.each do |type|
      @space.space_type = type
      assert @space.valid?, "#{type} should be valid"
    end
  end

  test "should not accept invalid space types" do
    @space.space_type = "invalid_type"
    assert_not @space.valid?
    assert_includes @space.errors[:space_type], "is not included in the list"
  end

  test "should destroy associated storages when deleted" do
    @space.save
    @space.storages.create!(user: @user, name: "Pantry")
    @space.storages.create!(user: @user, name: "Cabinet")

    assert_difference "Storage.count", -2 do
      @space.destroy
    end
  end
end


