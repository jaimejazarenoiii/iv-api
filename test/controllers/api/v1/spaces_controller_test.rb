require "test_helper"

class Api::V1::SpacesControllerTest < ActionDispatch::IntegrationTest
  def setup
    @user = User.create!(
      email: "test@example.com",
      password: "password123",
      password_confirmation: "password123"
    )
    @token = get_auth_token(@user)
    @space = @user.spaces.create!(name: "Kitchen", description: "Main kitchen area")
  end

  test "should get index" do
    get api_v1_spaces_url, headers: auth_headers(@token), as: :json

    assert_response :success
    json = JSON.parse(response.body)
    assert_equal 200, json["status"]["code"]
    assert json["data"]["spaces"].is_a?(Array)
    assert_equal 1, json["data"]["spaces"].length
  end

  test "should show space" do
    get api_v1_space_url(@space), headers: auth_headers(@token), as: :json

    assert_response :success
    json = JSON.parse(response.body)
    assert_equal 200, json["status"]["code"]
    assert_equal @space.name, json["data"]["space"]["name"]
  end

  test "should create space" do
    @user.subscription.update!(space_limit: 2)

    assert_difference "Space.count", 1 do
      post api_v1_spaces_url, params: {
        space: {
          name: "Bedroom",
          description: "Master bedroom"
        }
      }, headers: auth_headers(@token), as: :json
    end

    assert_response :created
    json = JSON.parse(response.body)
    assert_equal 201, json["status"]["code"]
    assert_equal "Bedroom", json["data"]["space"]["name"]
  end

  test "should not create space when limit reached" do
    assert_no_difference "Space.count" do
      post api_v1_spaces_url, params: {
        space: {
          name: "Living Room",
          description: "Main living area"
        }
      }, headers: auth_headers(@token), as: :json
    end

    assert_response :forbidden
    json = JSON.parse(response.body)
    assert_equal 403, json["status"]["code"]
    assert_includes json["errors"].first, "allows up to 1"
  end

  test "should update space" do
    patch api_v1_space_url(@space), params: {
      space: {
        name: "Updated Kitchen"
      }
    }, headers: auth_headers(@token), as: :json

    assert_response :success
    json = JSON.parse(response.body)
    assert_equal 200, json["status"]["code"]
    assert_equal "Updated Kitchen", json["data"]["space"]["name"]
  end

  test "should destroy space" do
    assert_difference "Space.count", -1 do
      delete api_v1_space_url(@space), headers: auth_headers(@token), as: :json
    end

    assert_response :success
    json = JSON.parse(response.body)
    assert_equal 200, json["status"]["code"]
  end

  test "should not allow access without authentication" do
    get api_v1_spaces_url, as: :json

    assert_response :unauthorized
    json = JSON.parse(response.body)
    assert_equal 401, json["status"]["code"]
  end


  test "should show space with storages when requested" do
    @space.storages.create!(user: @user, name: "Pantry")
    @space.storages.create!(user: @user, name: "Cabinet")

    get api_v1_space_url(@space), headers: auth_headers(@token), as: :json

    assert_response :success
    json = JSON.parse(response.body)
    assert_equal 2, json["data"]["space"]["storages"].length
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


