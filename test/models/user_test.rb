require "test_helper"

class UserTest < ActiveSupport::TestCase
  def setup
    @user = User.new(
      email: "test@example.com",
      password: "password123",
      password_confirmation: "password123"
    )
  end

  test "should be valid with valid attributes" do
    assert @user.valid?
  end

  test "should require email" do
    @user.email = nil
    assert_not @user.valid?
    assert_includes @user.errors[:email], "can't be blank"
  end

  test "should require password" do
    @user.password = nil
    assert_not @user.valid?
  end

  test "should require password confirmation to match" do
    @user.password_confirmation = "different"
    assert_not @user.valid?
  end

  test "should have unique email" do
    @user.save
    duplicate_user = @user.dup
    assert_not duplicate_user.valid?
    assert_includes duplicate_user.errors[:email], "has already been taken"
  end

  test "should have valid email format" do
    invalid_emails = %w[user.example.com user@ @example.com]
    invalid_emails.each do |invalid_email|
      @user.email = invalid_email
      assert_not @user.valid?, "#{invalid_email} should be invalid"
    end
  end

  test "should create subscription after creation" do
    assert_difference "Subscription.count", 1 do
      @user.save
    end
  end

  test "should create free subscription with 10 pantry limit" do
    @user.save
    assert_not_nil @user.subscription
    assert_equal "free", @user.subscription.plan
    assert_equal 10, @user.subscription.pantry_limit
  end

  test "should have many storages" do
    @user.save
    assert_respond_to @user, :storages
  end

  test "should have many items" do
    @user.save
    assert_respond_to @user, :items
  end

  test "should have many purchase_sessions" do
    @user.save
    assert_respond_to @user, :purchase_sessions
  end

  test "should destroy associated records when deleted" do
    @user.save
    @user.storages.create!(name: "Pantry")
    @user.items.create!(name: "Item", storage: @user.storages.first, unit: "oz")
    
    assert_difference ["Storage.count", "Item.count", "Subscription.count"], -1 do
      @user.destroy
    end
  end
end

