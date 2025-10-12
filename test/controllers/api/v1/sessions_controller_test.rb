require "test_helper"

class Api::V1::SessionsControllerTest < ActionDispatch::IntegrationTest
  def setup
    @user = User.create!(
      email: "test@example.com",
      password: "password123",
      password_confirmation: "password123"
    )
  end

  test "should login with valid credentials" do
    post login_url, params: {
      user: {
        email: @user.email,
        password: "password123"
      }
    }, as: :json

    assert_response :success
    json = JSON.parse(response.body)

    assert_equal 200, json["status"]["code"]
    assert_equal "Logged in successfully.", json["status"]["message"]
    assert_equal @user.email, json["data"]["user"]["email"]
    assert_equal @user.id, json["data"]["user"]["id"]

    # Should have JWT token in response body
    assert json["data"]["token"].present?
    assert json["data"]["token"].is_a?(String)
    assert json["data"]["token"].length > 20
  end

  test "should not login with invalid email" do
    post login_url, params: {
      user: {
        email: "wrong@example.com",
        password: "password123"
      }
    }, as: :json

    assert_response :unauthorized
    json = JSON.parse(response.body)

    assert_equal 401, json["status"]["code"]
    assert_includes json["errors"], "Invalid email or password."
  end

  test "should not login with invalid password" do
    post login_url, params: {
      user: {
        email: @user.email,
        password: "wrongpassword"
      }
    }, as: :json

    assert_response :unauthorized
    json = JSON.parse(response.body)

    assert_equal 401, json["status"]["code"]
    assert_includes json["errors"], "Invalid email or password."
  end

  test "should track sign in count" do
    initial_count = @user.sign_in_count

    post login_url, params: {
      user: {
        email: @user.email,
        password: "password123"
      }
    }, as: :json

    @user.reload
    assert_equal initial_count + 1, @user.sign_in_count
  end

  test "should update sign in timestamps" do
    post login_url, params: {
      user: {
        email: @user.email,
        password: "password123"
      }
    }, as: :json

    @user.reload
    assert_not_nil @user.current_sign_in_at
    assert_not_nil @user.last_sign_in_at
  end

  test "should logout with valid token" do
    # First login to get token
    post login_url, params: {
      user: {
        email: @user.email,
        password: "password123"
      }
    }, as: :json

    token = JSON.parse(response.body)["data"]["token"]
    assert token.present?, "Token should be present in login response"

    # Then logout
    delete logout_url, headers: { "Authorization" => "Bearer #{token}" }

    assert_response :success
    json = JSON.parse(response.body)
    assert_equal 200, json["status"]["code"]
    assert_equal "Logged out successfully.", json["status"]["message"]
  end

  test "should fail logout without token" do
    delete logout_url

    assert_response :unauthorized
    json = JSON.parse(response.body)
    assert_equal 401, json["status"]["code"]
  end
end
