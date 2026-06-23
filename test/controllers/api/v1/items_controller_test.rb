require "test_helper"

class Api::V1::ItemsControllerTest < ActionDispatch::IntegrationTest
  def setup
    @user = User.create!(
      email: "test@example.com",
      password: "password123",
      password_confirmation: "password123"
    )
    @token = get_auth_token(@user)
    @storage = @user.storages.create!(name: "Pantry")
    @item = @user.items.create!(
      name: "Olive Oil",
      storage: @storage,
      unit: "oz",
      quantity: 32,
      min_quantity: 16
    )
  end

  test "should get index" do
    get api_v1_items_url, headers: auth_headers(@token), as: :json

    assert_response :success
    json = JSON.parse(response.body)
    assert_equal 200, json["status"]["code"]
    assert json["data"]["items"].is_a?(Array)
    assert_equal 1, json["data"]["items"].length
  end

  test "should filter items by storage_id" do
    another_storage = @user.storages.create!(name: "Fridge")
    another_item = @user.items.create!(name: "Milk", storage: another_storage, unit: "gallon", quantity: 1)

    get api_v1_items_url(storage_id: @storage.id), headers: auth_headers(@token), as: :json

    assert_response :success
    json = JSON.parse(response.body)
    assert_equal 1, json["data"]["items"].length
    assert_equal "Olive Oil", json["data"]["items"][0]["name"]
  end

  test "should get low stock items" do
    get low_stock_api_v1_items_url, headers: auth_headers(@token), as: :json

    assert_response :success
    json = JSON.parse(response.body)
    assert_equal 200, json["status"]["code"]
    assert json["data"]["items"].is_a?(Array)
  end

  test "should show item" do
    get api_v1_item_url(@item), headers: auth_headers(@token), as: :json

    assert_response :success
    json = JSON.parse(response.body)
    assert_equal 200, json["status"]["code"]
    assert_equal @item.name, json["data"]["item"]["name"]
    assert_equal @item.quantity.to_s, json["data"]["item"]["quantity"].to_s
  end

  test "should create item" do
    assert_difference "Item.count", 1 do
      post api_v1_items_url, params: {
        item: {
          name: "Rice",
          storage_id: @storage.id,
          unit: "lbs",
          quantity: 10,
          min_quantity: 5
        }
      }, headers: auth_headers(@token), as: :json
    end

    assert_response :created
    json = JSON.parse(response.body)
    assert_equal 201, json["status"]["code"]
    assert_equal "Rice", json["data"]["item"]["name"]
  end

  test "should not create item when limit reached" do
    @user.subscription.update!(item_limit: 1)

    assert_no_difference "Item.count" do
      post api_v1_items_url, params: {
        item: {
          name: "Beans",
          storage_id: @storage.id,
          unit: "lbs",
          quantity: 5
        }
      }, headers: auth_headers(@token), as: :json
    end

    assert_response :forbidden
    json = JSON.parse(response.body)
    assert_equal 403, json["status"]["code"]
    assert_includes json["errors"].first, "allows up to 1"
  end

  test "should update item" do
    patch api_v1_item_url(@item), params: {
      item: {
        quantity: 20
      }
    }, headers: auth_headers(@token), as: :json

    assert_response :success
    json = JSON.parse(response.body)
    assert_equal 200, json["status"]["code"]
    assert_equal "20.0", json["data"]["item"]["quantity"].to_s
  end

  test "should destroy item" do
    assert_difference "Item.count", -1 do
      delete api_v1_item_url(@item), headers: auth_headers(@token), as: :json
    end

    assert_response :success
    json = JSON.parse(response.body)
    assert_equal 200, json["status"]["code"]
  end

  test "should move item to another storage" do
    destination = @user.storages.create!(name: "Drawer")

    post move_api_v1_item_url(@item), params: { destination_storage_id: destination.id }, headers: auth_headers(@token), as: :json

    assert_response :success
    json = JSON.parse(response.body)
    assert_equal 200, json["status"]["code"]
    assert_equal destination.id, Item.find(@item.id).storage_id
  end

  test "should not allow access without authentication" do
    get api_v1_items_url, as: :json

    assert_response :unauthorized
    json = JSON.parse(response.body)
    assert_equal 401, json["status"]["code"]
  end

  test "should include low_stock indicator" do
    get api_v1_item_url(@item), headers: auth_headers(@token), as: :json

    json = JSON.parse(response.body)
    assert_includes json["data"]["item"].keys, "low_stock"
  end

  test "should create item with categories" do
    category1 = @user.categories.create!(name: "Spices")
    category2 = @user.categories.create!(name: "Cooking")

    post api_v1_items_url, params: {
      item: {
        name: "Salt",
        storage_id: @storage.id,
        unit: "oz",
        category_ids: [category1.id, category2.id]
      }
    }, headers: auth_headers(@token), as: :json

    assert_response :created
    json = JSON.parse(response.body)
    item = Item.find(json["data"]["item"]["id"])
    assert_equal 2, item.categories.count
    assert_includes item.categories, category1
    assert_includes item.categories, category2
  end

  test "should include categories in item response" do
    category = @user.categories.create!(name: "Spices")
    @item.categories << category

    get api_v1_item_url(@item), headers: auth_headers(@token), as: :json

    json = JSON.parse(response.body)
    assert_includes json["data"]["item"].keys, "categories"
    assert_equal 1, json["data"]["item"]["categories"].length
    assert_equal category.id, json["data"]["item"]["categories"][0]["id"]
    assert_equal category.name, json["data"]["item"]["categories"][0]["name"]
  end

  test "should update item categories" do
    category1 = @user.categories.create!(name: "Spices")
    category2 = @user.categories.create!(name: "Beverages")
    @item.categories << category1

    patch api_v1_item_url(@item), params: {
      item: {
        category_ids: [category2.id]
      }
    }, headers: auth_headers(@token), as: :json

    assert_response :success
    @item.reload
    assert_equal 1, @item.categories.count
    assert_includes @item.categories, category2
    assert_not_includes @item.categories, category1
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

