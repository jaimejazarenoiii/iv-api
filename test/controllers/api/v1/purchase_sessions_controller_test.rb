require "test_helper"

class Api::V1::PurchaseSessionsControllerTest < ActionDispatch::IntegrationTest
  def setup
    @user = User.create!(
      email: "test@example.com",
      password: "password123",
      password_confirmation: "password123"
    )
    @token = get_auth_token(@user)
    @storage = @user.storages.create!(name: "Pantry")
    @item = @user.items.create!(name: "Olive Oil", storage: @storage, unit: "oz")
    @purchase_session = @user.purchase_sessions.create!(
      store_name: "Costco",
      total_amount: 45.99,
      purchased_at: Time.current
    )
  end

  test "should get index" do
    get api_v1_purchase_sessions_url, headers: auth_headers(@token), as: :json

    assert_response :success
    json = JSON.parse(response.body)
    assert_equal 200, json["status"]["code"]
    assert json["data"]["purchase_sessions"].is_a?(Array)
    assert_equal 1, json["data"]["purchase_sessions"].length
  end

  test "should show purchase session" do
    get api_v1_purchase_session_url(@purchase_session), headers: auth_headers(@token), as: :json

    assert_response :success
    json = JSON.parse(response.body)
    assert_equal 200, json["status"]["code"]
    assert_equal @purchase_session.store_name, json["data"]["purchase_session"]["store_name"]
  end

  test "should create purchase session" do
    assert_difference "PurchaseSession.count", 1 do
      post api_v1_purchase_sessions_url, params: {
        purchase_session: {
          store_name: "Walmart",
          total_amount: 29.99,
          purchased_at: Time.current
        }
      }, headers: auth_headers(@token), as: :json
    end

    assert_response :created
    json = JSON.parse(response.body)
    assert_equal 201, json["status"]["code"]
    assert_equal "Walmart", json["data"]["purchase_session"]["store_name"]
  end

  test "should create purchase session with items" do
    assert_difference ["PurchaseSession.count", "PurchaseItem.count"], 1 do
      post api_v1_purchase_sessions_url, params: {
        purchase_session: {
          store_name: "Target",
          total_amount: 15.99,
          purchased_at: Time.current
        },
        purchase_items: [
          {
            item_id: @item.id,
            quantity: 2,
            unit_price: 7.99
          }
        ]
      }, headers: auth_headers(@token), as: :json
    end

    assert_response :created
    json = JSON.parse(response.body)
    assert_equal 201, json["status"]["code"]
    assert_equal 1, json["data"]["purchase_session"]["items"].length
  end

  test "should update purchase session" do
    patch api_v1_purchase_session_url(@purchase_session), params: {
      purchase_session: {
        total_amount: 50.00
      }
    }, headers: auth_headers(@token), as: :json

    assert_response :success
    json = JSON.parse(response.body)
    assert_equal 200, json["status"]["code"]
    assert_equal "50.0", json["data"]["purchase_session"]["total_amount"].to_s
  end

  test "should destroy purchase session" do
    assert_difference "PurchaseSession.count", -1 do
      delete api_v1_purchase_session_url(@purchase_session), headers: auth_headers(@token), as: :json
    end

    assert_response :success
    json = JSON.parse(response.body)
    assert_equal 200, json["status"]["code"]
  end

  test "should not allow access without authentication" do
    get api_v1_purchase_sessions_url, as: :json

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


