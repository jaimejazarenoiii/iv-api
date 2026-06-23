require "test_helper"

class Api::V1::CategoriesControllerTest < ActionDispatch::IntegrationTest
  def setup
    @user = User.create!(
      email: "test@example.com",
      password: "password123",
      password_confirmation: "password123"
    )
    @token = get_auth_token(@user)
    @category = @user.categories.create!(name: "Spices")
  end

  test "should get index" do
    get api_v1_categories_url, headers: auth_headers(@token), as: :json

    assert_response :success
    json = JSON.parse(response.body)
    assert_equal 200, json["status"]["code"]
    assert json["data"]["categories"].is_a?(Array)
    assert_equal 1, json["data"]["categories"].length
  end

  test "should show category" do
    get api_v1_category_url(@category), headers: auth_headers(@token), as: :json

    assert_response :success
    json = JSON.parse(response.body)
    assert_equal 200, json["status"]["code"]
    assert_equal @category.name, json["data"]["category"]["name"]
  end

  test "should show category with items" do
    storage = @user.storages.create!(name: "Pantry")
    item = @user.items.create!(name: "Salt", storage: storage, unit: "oz")
    @category.items << item

    get api_v1_category_url(@category), headers: auth_headers(@token), as: :json

    assert_response :success
    json = JSON.parse(response.body)
    assert_equal 1, json["data"]["category"]["items"].length
    assert_equal item.id, json["data"]["category"]["items"][0]["id"]
  end

  test "should create category" do
    assert_difference "Category.count", 1 do
      post api_v1_categories_url, params: {
        category: {
          name: "Beverages"
        }
      }, headers: auth_headers(@token), as: :json
    end

    assert_response :created
    json = JSON.parse(response.body)
    assert_equal 201, json["status"]["code"]
    assert_equal "Beverages", json["data"]["category"]["name"]
  end

  test "should not create duplicate category for same user" do
    @category.save!

    assert_no_difference "Category.count" do
      post api_v1_categories_url, params: {
        category: {
          name: "Spices"
        }
      }, headers: auth_headers(@token), as: :json
    end

    assert_response :unprocessable_entity
    json = JSON.parse(response.body)
    assert_equal 422, json["status"]["code"]
  end

  test "should update category" do
    patch api_v1_category_url(@category), params: {
      category: {
        name: "Spices & Herbs"
      }
    }, headers: auth_headers(@token), as: :json

    assert_response :success
    json = JSON.parse(response.body)
    assert_equal 200, json["status"]["code"]
    assert_equal "Spices & Herbs", json["data"]["category"]["name"]
  end

  test "should destroy category" do
    assert_difference "Category.count", -1 do
      delete api_v1_category_url(@category), headers: auth_headers(@token), as: :json
    end

    assert_response :success
    json = JSON.parse(response.body)
    assert_equal 200, json["status"]["code"]
  end

  test "should not allow access without authentication" do
    get api_v1_categories_url, as: :json

    assert_response :unauthorized
    json = JSON.parse(response.body)
    assert_equal 401, json["status"]["code"]
  end

  test "should not show category belonging to another user" do
    other_user = User.create!(
      email: "other@example.com",
      password: "password123",
      password_confirmation: "password123"
    )
    other_category = other_user.categories.create!(name: "Other Category")

    get api_v1_category_url(other_category), headers: auth_headers(@token), as: :json

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

