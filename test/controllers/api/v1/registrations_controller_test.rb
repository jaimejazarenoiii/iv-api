require "test_helper"

class Api::V1::RegistrationsControllerTest < ActionDispatch::IntegrationTest
  test "should signup with valid credentials" do
    assert_difference "User.count", 1 do
      post signup_url, params: {
        user: {
          email: "newuser@example.com",
          password: "password123",
          password_confirmation: "password123"
        }
      }, as: :json
    end

    assert_response :success
    json = JSON.parse(response.body)

    assert_equal 200, json["status"]["code"]
    assert_equal "Signed up successfully. Please login to get your token.", json["status"]["message"]
    assert_equal "newuser@example.com", json["data"]["user"]["email"]
    assert json["data"]["user"]["id"].present?

    # No token on signup
    assert_nil json["data"]["token"]
  end

  test "should not signup with invalid email" do
    assert_no_difference "User.count" do
      post signup_url, params: {
        user: {
          email: "invalid",
          password: "password123",
          password_confirmation: "password123"
        }
      }, as: :json
    end

    assert_response :unprocessable_entity
    json = JSON.parse(response.body)

    assert_equal 422, json["status"]["code"]
    assert json["errors"].present?
  end

  test "should not signup with mismatched passwords" do
    assert_no_difference "User.count" do
      post signup_url, params: {
        user: {
          email: "test@example.com",
          password: "password123",
          password_confirmation: "different"
        }
      }, as: :json
    end

    assert_response :unprocessable_entity
    json = JSON.parse(response.body)
    assert json["errors"].present?
  end

  test "should not signup with duplicate email" do
    User.create!(
      email: "existing@example.com",
      password: "password123",
      password_confirmation: "password123"
    )

    assert_no_difference "User.count" do
      post signup_url, params: {
        user: {
          email: "existing@example.com",
          password: "password123",
          password_confirmation: "password123"
        }
      }, as: :json
    end

    assert_response :unprocessable_entity
    json = JSON.parse(response.body)
    assert_includes json["errors"].join, "already been taken"
  end

  test "should create subscription automatically on signup" do
    assert_difference "Subscription.count", 1 do
      post signup_url, params: {
        user: {
          email: "newuser@example.com",
          password: "password123",
          password_confirmation: "password123"
        }
      }, as: :json
    end

    user = User.find_by(email: "newuser@example.com")
    assert_not_nil user.subscription
    assert_equal "free", user.subscription.plan
  end
end
