require "test_helper"

class Api::V1::BrowseControllerTest < ActionDispatch::IntegrationTest
  def setup
    @user = User.create!(
      email: "test@example.com",
      password: "password123",
      password_confirmation: "password123"
    )
    @token = get_auth_token(@user)

    @space = @user.spaces.create!(name: "Kitchen")
    @top_storage = @user.storages.create!(name: "Cabinet A", space: @space)
    @child_storage = @user.storages.create!(name: "Shelf 1", space: @space, parent: @top_storage)
  end

  test "should list spaces with has_children flag" do
    get "/api/v1/browse/spaces", headers: auth_headers(@token), as: :json

    assert_response :success
    json = JSON.parse(response.body)
    assert_equal 200, json["status"]["code"]
    assert_equal 1, json["data"]["spaces"].length
    space = json["data"]["spaces"].first
    assert_equal @space.id, space["id"]
    assert_equal true, space["has_children"]
  end

  test "should list top-level storages for a space" do
    get "/api/v1/browse/storages?space_id=#{@space.id}", headers: auth_headers(@token), as: :json

    assert_response :success
    json = JSON.parse(response.body)
    storages = json["data"]["storages"]
    assert_equal 1, storages.length
    assert_equal @top_storage.id, storages.first["id"]
    assert_equal true, storages.first["has_children"]
  end

  test "should list child storages for a parent storage" do
    get "/api/v1/browse/storages?parent_id=#{@top_storage.id}", headers: auth_headers(@token), as: :json

    assert_response :success
    json = JSON.parse(response.body)
    storages = json["data"]["storages"]
    assert_equal 1, storages.length
    assert_equal @child_storage.id, storages.first["id"]
    assert_equal false, storages.first["has_children"]
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


