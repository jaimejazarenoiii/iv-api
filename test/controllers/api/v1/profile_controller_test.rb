require "test_helper"

class Api::V1::ProfileControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    @auth_token = generate_jwt_token(@user)
  end

  test "should get profile when authenticated" do
    get api_v1_profile_url, 
      headers: { 'Authorization' => "Bearer #{@auth_token}" },
      as: :json

    assert_response :success
    json_response = JSON.parse(response.body)
    assert_equal 200, json_response['status']['code']
    assert_equal @user.email, json_response['data']['profile']['email']
  end

  test "should not get profile when not authenticated" do
    get api_v1_profile_url, as: :json

    assert_response :unauthorized
  end

  test "should update profile fields" do
    patch api_v1_profile_url,
      params: {
        profile: {
          first_name: 'John',
          last_name: 'Doe',
          middle_name: 'Michael',
          gender: 'male'
        }
      },
      headers: { 'Authorization' => "Bearer #{@auth_token}" },
      as: :json

    assert_response :success
    json_response = JSON.parse(response.body)
    assert_equal 'John', json_response['data']['profile']['first_name']
    assert_equal 'Doe', json_response['data']['profile']['last_name']
    assert_equal 'Michael', json_response['data']['profile']['middle_name']
    assert_equal 'male', json_response['data']['profile']['gender']
    assert_equal 'John Michael Doe', json_response['data']['profile']['full_name']
  end

  test "should update partial profile fields" do
    patch api_v1_profile_url,
      params: {
        profile: {
          first_name: 'Jane'
        }
      },
      headers: { 'Authorization' => "Bearer #{@auth_token}" },
      as: :json

    assert_response :success
    json_response = JSON.parse(response.body)
    assert_equal 'Jane', json_response['data']['profile']['first_name']
  end

  test "should reject invalid gender" do
    patch api_v1_profile_url,
      params: {
        profile: {
          gender: 'invalid_gender'
        }
      },
      headers: { 'Authorization' => "Bearer #{@auth_token}" },
      as: :json

    assert_response :unprocessable_entity
    json_response = JSON.parse(response.body)
    assert_equal 422, json_response['status']['code']
    assert_not_empty json_response['errors']
  end

  test "should update profile with image" do
    file = fixture_file_upload('test_image.jpg', 'image/jpeg')
    
    patch api_v1_profile_url,
      params: {
        profile: {
          first_name: 'John',
          profile_image: file
        }
      },
      headers: { 'Authorization' => "Bearer #{@auth_token}" },
      as: :json

    assert_response :success
    json_response = JSON.parse(response.body)
    assert_not_nil json_response['data']['profile']['profile_image_url']
  end

  test "should delete profile image" do
    # First attach an image
    @user.profile_image.attach(
      io: File.open(Rails.root.join('test', 'fixtures', 'files', 'test_image.jpg')),
      filename: 'test_image.jpg',
      content_type: 'image/jpeg'
    )

    delete image_api_v1_profile_url,
      headers: { 'Authorization' => "Bearer #{@auth_token}" },
      as: :json

    assert_response :success
    json_response = JSON.parse(response.body)
    assert_nil json_response['data']['profile']['profile_image_url']
  end

  test "should return error when deleting non-existent profile image" do
    delete image_api_v1_profile_url,
      headers: { 'Authorization' => "Bearer #{@auth_token}" },
      as: :json

    assert_response :not_found
    json_response = JSON.parse(response.body)
    assert_equal 404, json_response['status']['code']
  end

  private

  def generate_jwt_token(user)
    Warden::JWTAuth::UserEncoder.new.call(user, :user, nil).first
  end
end

