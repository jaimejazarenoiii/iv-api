require "test_helper"

class Api::V1::DashboardControllerTest < ActionDispatch::IntegrationTest
  def setup
    @user = User.create!(
      email: "test@example.com",
      password: "password123",
      password_confirmation: "password123"
    )
    @token = get_auth_token(@user)
    
    # Create test data
    @space1 = @user.spaces.create!(name: "Kitchen", description: "Main kitchen")
    @space2 = @user.spaces.create!(name: "Bedroom", description: "Master bedroom")
    @space3 = @user.spaces.create!(name: "Garage", description: "Storage garage")
    
    @storage1 = @user.storages.create!(name: "Pantry", description: "Kitchen pantry", space: @space1)
    @storage2 = @user.storages.create!(name: "Cabinet", description: "Kitchen cabinet", space: @space1)
    @storage3 = @user.storages.create!(name: "Closet", description: "Bedroom closet", space: @space2)
    
    # Create substorages
    @substorage1 = @user.storages.create!(name: "Spice Rack", description: "Spice substorage", space: @space1, parent: @storage1)
    @substorage2 = @user.storages.create!(name: "Top Shelf", description: "Top shelf substorage", space: @space1, parent: @storage2)
    
    @item1 = @user.items.create!(
      name: "Rice",
      notes: "White rice",
      quantity: 5,
      unit: "kg",
      storage: @storage1
    )
    @item2 = @user.items.create!(
      name: "Pasta",
      notes: "Spaghetti pasta",
      quantity: 3,
      unit: "box",
      storage: @storage1
    )
    @item3 = @user.items.create!(
      name: "Shirt",
      notes: "Cotton shirt",
      quantity: 2,
      unit: "piece",
      storage: @storage3
    )
    # Items in substorages
    @item4 = @user.items.create!(
      name: "Salt",
      notes: "Table salt",
      quantity: 1,
      unit: "g",
      storage: @substorage1
    )
    @item5 = @user.items.create!(
      name: "Pepper",
      notes: "Black pepper",
      quantity: 1,
      unit: "g",
      storage: @substorage1
    )
  end

  test "should get dashboard data" do
    get api_v1_dashboard_url, headers: auth_headers(@token), as: :json

    assert_response :success
    json = JSON.parse(response.body)
    
    # Check response structure
    assert_equal 200, json["status"]["code"]
    assert_equal "Dashboard data retrieved successfully.", json["status"]["message"]
    
    # Check data structure
    assert json["data"]["spaces"].is_a?(Array)
    assert json["data"]["storages"].is_a?(Array)
    assert json["data"]["items"].is_a?(Array)
    
    # Check spaces data (ordered by updated_at, most recent first)
    spaces = json["data"]["spaces"]
    assert_equal 3, spaces.length
    assert_equal "Garage", spaces[0]["name"] # Most recently updated first
    assert_equal "Bedroom", spaces[1]["name"]
    assert_equal "Kitchen", spaces[2]["name"]
    
    # Check storages data (ordered by updated_at, most recent first)
    storages = json["data"]["storages"]
    assert_equal 5, storages.length  # 3 main storages + 2 substorages
    assert_equal "Top Shelf", storages[0]["name"] # Most recently updated first (substorage2)
    assert_equal "Spice Rack", storages[1]["name"] # substorage1
    assert_equal "Closet", storages[2]["name"] # storage3
    assert_equal "Cabinet", storages[3]["name"] # storage2
    assert_equal "Pantry", storages[4]["name"] # storage1 (oldest)
    
    # Check items data (ordered by updated_at, most recent first)
    items = json["data"]["items"]
    assert_equal 5, items.length  # 5 items total
    assert_equal "Pepper", items[0]["name"] # Most recently updated first
    assert_equal "Salt", items[1]["name"]
    assert_equal "Shirt", items[2]["name"]
    assert_equal "Pasta", items[3]["name"]
    assert_equal "Rice", items[4]["name"] # oldest
  end

  test "should limit results to 5 items each" do
    # Create more than 5 items of each type
    6.times do |i|
      @user.spaces.create!(name: "Space #{i}", description: "Test space")
      @user.storages.create!(name: "Storage #{i}", description: "Test storage", space: @space1)
      @user.items.create!(name: "Item #{i}", notes: "Test item", quantity: 1, unit: "piece", storage: @storage1)
    end

    get api_v1_dashboard_url, headers: auth_headers(@token), as: :json

    assert_response :success
    json = JSON.parse(response.body)
    
    # Should only return 5 of each type
    assert_equal 5, json["data"]["spaces"].length
    assert_equal 5, json["data"]["storages"].length
    assert_equal 5, json["data"]["items"].length
  end

  test "should include related data in responses" do
    get api_v1_dashboard_url, headers: auth_headers(@token), as: :json

    assert_response :success
    json = JSON.parse(response.body)
    
    # Check space data includes storages_count
    space = json["data"]["spaces"].find { |s| s["name"] == "Kitchen" }
    assert_equal 2, space["storages_count"]  # 2 main storages (Pantry, Cabinet)
    assert_equal 2, space["substorages_count"]  # 2 substorages (Spice Rack, Top Shelf)
    assert_equal 4, space["items_count"]  # 4 items total in Kitchen space (Rice, Pasta, Salt, Pepper)
    
    # Check storage data includes space info (find any storage in the response)
    storage = json["data"]["storages"].first  # Get the most recent storage
    assert_not_nil storage["space_id"]
    assert_not_nil storage["space_name"]
    assert storage["items_count"] >= 0
    assert storage["substorages_count"] >= 0
    assert storage["total_items_count"] >= 0
    
    # Check item data includes storage and space info
    item = json["data"]["items"].find { |i| i["name"] == "Rice" }
    assert_equal @storage1.id, item["storage_id"]
    assert_equal "Pantry", item["storage_name"]
    assert_equal "Kitchen", item["space_name"]
  end

  test "should not allow access without authentication" do
    get api_v1_dashboard_url, as: :json

    assert_response :unauthorized
    json = JSON.parse(response.body)
    assert_equal 401, json["status"]["code"]
  end

  test "should return empty arrays when user has no data" do
    # Create a new user with no data
    new_user = User.create!(
      email: "empty@example.com",
      password: "password123",
      password_confirmation: "password123"
    )
    new_token = get_auth_token(new_user)

    get api_v1_dashboard_url, headers: auth_headers(new_token), as: :json

    assert_response :success
    json = JSON.parse(response.body)
    
    assert_equal 200, json["status"]["code"]
    assert_equal 0, json["data"]["spaces"].length
    assert_equal 0, json["data"]["storages"].length
    assert_equal 0, json["data"]["items"].length
  end

  test "should order by updated_at not created_at" do
    # Update the first space to make it the most recently updated
    @space1.update!(name: "Updated Kitchen")
    
    get api_v1_dashboard_url, headers: auth_headers(@token), as: :json

    assert_response :success
    json = JSON.parse(response.body)
    
    # The updated space should now be first
    spaces = json["data"]["spaces"]
    assert_equal "Updated Kitchen", spaces[0]["name"]
    assert_equal "Garage", spaces[1]["name"]
    assert_equal "Bedroom", spaces[2]["name"]
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
