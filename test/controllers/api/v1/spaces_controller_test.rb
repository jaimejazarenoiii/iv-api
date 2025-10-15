require "test_helper"

class Api::V1::SpacesControllerTest < ActionDispatch::IntegrationTest
  def setup
    @user = User.create!(
      email: "test@example.com",
      password: "password123",
      password_confirmation: "password123"
    )
    @token = get_auth_token(@user)
    @space = @user.spaces.create!(name: "Kitchen", space_type: "kitchen", description: "Main kitchen area")
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
    assert_equal @space.space_type, json["data"]["space"]["space_type"]
  end

  test "should create space" do
    assert_difference "Space.count", 1 do
      post api_v1_spaces_url, params: {
        space: {
          name: "Bedroom",
          space_type: "bedroom",
          description: "Master bedroom"
        }
      }, headers: auth_headers(@token), as: :json
    end

    assert_response :created
    json = JSON.parse(response.body)
    assert_equal 201, json["status"]["code"]
    assert_equal "Bedroom", json["data"]["space"]["name"]
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

  test "should not create space with invalid type" do
    assert_no_difference "Space.count" do
      post api_v1_spaces_url, params: {
        space: {
          name: "Test Space",
          space_type: "invalid_type"
        }
      }, headers: auth_headers(@token), as: :json
    end

    assert_response :unprocessable_entity
    json = JSON.parse(response.body)
    assert_equal 422, json["status"]["code"]
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


