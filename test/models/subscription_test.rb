require "test_helper"

class SubscriptionTest < ActiveSupport::TestCase
  def setup
    @user = User.create!(
      email: "test@example.com",
      password: "password123",
      password_confirmation: "password123"
    )
    # Destroy auto-created subscription to test manually
    @user.subscription.destroy
    @subscription = @user.build_subscription(plan: :free)
  end

  test "should be valid with valid attributes" do
    assert @subscription.valid?
  end

  test "should require plan" do
    @subscription.plan = nil
    assert_not @subscription.valid?
  end

  test "should belong to user" do
    assert_respond_to @subscription, :user
  end

  test "should set defaults on create for free plan" do
    sub = @user.create_subscription!(plan: :free)
    assert_equal 10, sub.pantry_limit
    assert_not_nil sub.started_at
  end

  test "should set defaults on create for premium plan" do
    sub = @user.create_subscription!(plan: :premium)
    assert_nil sub.pantry_limit
    assert_not_nil sub.started_at
  end

  test "should be active when expires_at is nil" do
    @subscription.expires_at = nil
    @subscription.save
    assert @subscription.active?
  end

  test "should be active when expires_at is in future" do
    @subscription.expires_at = 1.day.from_now
    @subscription.save
    assert @subscription.active?
  end

  test "should not be active when expires_at is in past" do
    @subscription.expires_at = 1.day.ago
    @subscription.save
    assert_not @subscription.active?
  end

  test "should have enum for plan" do
    @subscription.plan = :free
    assert_equal "free", @subscription.plan
    
    @subscription.plan = :premium
    assert_equal "premium", @subscription.plan
  end
end

