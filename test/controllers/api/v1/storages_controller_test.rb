require "test_helper"

class Api::V1::StoragesControllerTest < ActionDispatch::IntegrationTest
  def setup
    @user = User.create!(
      email: "test@example.com",
      password: "password123",
      password_confirmation: "password123"
    )
    @token = get_auth_token(@user)
    @storage = @user.storages.create!(name: "Pantry", description: "Main pantry")
  end

  test "should get index" do
    get api_v1_storages_url, headers: auth_headers(@token), as: :json

    assert_response :success
    json = JSON.parse(response.body)
    assert_equal 200, json["status"]["code"]
    assert json["data"]["storages"].is_a?(Array)
    assert_equal 1, json["data"]["storages"].length
  end

  test "should show storage" do
    get api_v1_storage_url(@storage), headers: auth_headers(@token), as: :json

    assert_response :success
    json = JSON.parse(response.body)
    assert_equal 200, json["status"]["code"]
    assert_equal @storage.name, json["data"]["storage"]["name"]
  end

  test "should create storage" do
    assert_difference "Storage.count", 1 do
      post api_v1_storages_url, params: {
        storage: {
          name: "Fridge",
          description: "Kitchen refrigerator"
        }
      }, headers: auth_headers(@token), as: :json
    end

    assert_response :created
    json = JSON.parse(response.body)
    assert_equal 201, json["status"]["code"]
    assert_equal "Fridge", json["data"]["storage"]["name"]
  end

  test "should not create storage when limit reached" do
    @user.subscription.update!(storage_limit: 1)

    assert_no_difference "Storage.count" do
      post api_v1_storages_url, params: {
        storage: {
          name: "Closet",
          description: "Bedroom closet"
        }
      }, headers: auth_headers(@token), as: :json
    end

    assert_response :forbidden
    json = JSON.parse(response.body)
    assert_equal 403, json["status"]["code"]
    assert_includes json["errors"].first, "allows up to 1"
  end

  test "should update storage" do
    patch api_v1_storage_url(@storage), params: {
      storage: {
        name: "Updated Pantry"
      }
    }, headers: auth_headers(@token), as: :json

    assert_response :success
    json = JSON.parse(response.body)
    assert_equal 200, json["status"]["code"]
    assert_equal "Updated Pantry", json["data"]["storage"]["name"]
  end

  test "should destroy storage" do
    assert_difference "Storage.count", -1 do
      delete api_v1_storage_url(@storage), headers: auth_headers(@token), as: :json
    end

    assert_response :success
    json = JSON.parse(response.body)
    assert_equal 200, json["status"]["code"]
  end

  test "should move storage under another parent" do
    space = @user.spaces.create!(name: "Kitchen")
    parent = @user.storages.create!(name: "Cabinet", space: space)

    post move_api_v1_storage_url(@storage), params: { destination_parent_id: parent.id }, headers: auth_headers(@token), as: :json

    assert_response :success
    json = JSON.parse(response.body)
    assert_equal 200, json["status"]["code"]
    assert_equal parent.id, Storage.find(@storage.id).parent_id
    assert_equal space.id, Storage.find(@storage.id).space_id
  end

  test "should move storage to top-level space" do
    space = @user.spaces.create!(name: "Garage")
    # Make storage a child first
    parent = @user.storages.create!(name: "Box", space: space)
    @storage.update!(parent: parent, space: space)

    post move_api_v1_storage_url(@storage), params: { destination_space_id: space.id }, headers: auth_headers(@token), as: :json

    assert_response :success
    s = Storage.find(@storage.id)
    assert_nil s.parent_id
    assert_equal space.id, s.space_id
  end

  test "should not allow access without authentication" do
    get api_v1_storages_url, as: :json

    assert_response :unauthorized
    json = JSON.parse(response.body)
    assert_equal 401, json["status"]["code"]
  end

  test "should not show storage belonging to another user" do
    other_user = User.create!(email: "other@example.com", password: "password123", password_confirmation: "password123")
    other_storage = other_user.storages.create!(name: "Other Pantry")

    get api_v1_storage_url(other_storage), headers: auth_headers(@token), as: :json

    assert_response :not_found
    json = JSON.parse(response.body)
    assert_equal 404, json["status"]["code"]
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


