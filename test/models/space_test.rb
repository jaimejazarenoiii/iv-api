require "test_helper"

class SpaceTest < ActiveSupport::TestCase
  def setup
    @user = User.create!(
      email: "test@example.com",
      password: "password123",
      password_confirmation: "password123"
    )
    @space = @user.spaces.build(name: "Kitchen")
  end

  test "should be valid with valid attributes" do
    assert @space.valid?
  end

  test "should require name" do
    @space.name = nil
    assert_not @space.valid?
    assert_includes @space.errors[:name], "can't be blank"
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


  test "should destroy associated storages when deleted" do
    @space.save
    @space.storages.create!(user: @user, name: "Pantry")
    @space.storages.create!(user: @user, name: "Cabinet")

    assert_difference "Storage.count", -2 do
      @space.destroy
    end
  end
end


