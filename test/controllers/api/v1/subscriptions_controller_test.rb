require "test_helper"

class Api::V1::SubscriptionsControllerTest < ActionDispatch::IntegrationTest
  def setup
    @user = User.create!(
      email: "test@example.com",
      password: "password123",
      password_confirmation: "password123"
    )
    @token = get_auth_token(@user)
  end

  test "should show subscription" do
    get api_v1_subscription_url, headers: auth_headers(@token), as: :json

    assert_response :success
    json = JSON.parse(response.body)
    assert_equal 200, json["status"]["code"]
    assert_equal "free", json["data"]["subscription"]["plan"]
    assert_equal 10, json["data"]["subscription"]["pantry_limit"]
    assert_equal true, json["data"]["subscription"]["active"]
  end

  test "should update subscription to premium" do
    patch api_v1_subscription_url, params: {
      subscription: {
        plan: "premium"
      }
    }, headers: auth_headers(@token), as: :json

    assert_response :success
    json = JSON.parse(response.body)
    assert_equal 200, json["status"]["code"]
    assert_equal "premium", json["data"]["subscription"]["plan"]
  end

  test "should not allow access without authentication" do
    get api_v1_subscription_url, as: :json

    assert_response :unauthorized
    json = JSON.parse(response.body)
    assert_equal 401, json["status"]["code"]
  end

  private

  def get_auth_token(user)
    post login_url, params: {
      user: { email: user.email, password: "password123" }
    }, as: :json
    JSON.parse(response.body)["data"]["token"]
  end

  def auth_headers(token)
    { "Authorization" => "Bearer #{token}" }
  end
end


