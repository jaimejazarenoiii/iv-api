# Testing Guide

## Overview

This project includes comprehensive unit tests for models and controllers using Minitest (Rails default testing framework).

## Test Coverage

### ✅ Model Tests (4 files, 35 tests)

#### User Model Tests (`test/models/user_test.rb`)
- Valid user creation
- Email validation (presence, uniqueness, format)
- Password validation
- Password confirmation matching
- Automatic subscription creation
- Associated records (storages, items, purchase_sessions)
- Cascade deletion of associated records

#### Subscription Model Tests (`test/models/subscription_test.rb`)
- Valid subscription creation
- Plan requirement
- Default values for free and premium plans
- Active subscription check (expires_at logic)
- Enum functionality

#### Storage Model Tests (`test/models/storage_test.rb`)
- Valid storage creation
- Name validation (presence, length)
- Description length validation
- Parent-child relationships
- Cascade deletion of children

#### Item Model Tests (`test/models/item_test.rb`)
- Valid item creation
- Field validations (name, unit, quantity, min_quantity)
- Low stock detection logic
- Associations with user and storage

### ✅ Controller Tests (2 files, 20 tests)

#### Registrations Controller Tests (`test/controllers/api/v1/registrations_controller_test.rb`)
- Successful signup with valid credentials
- Invalid email handling
- Password mismatch handling
- Duplicate email prevention
- Automatic subscription creation on signup
- JSend format responses

#### Sessions Controller Tests (`test/controllers/api/v1/sessions_controller_test.rb`)
- Successful login with valid credentials
- Invalid email/password handling
- JWT token in response headers
- Sign-in count tracking
- Sign-in timestamp tracking
- Successful logout with valid token
- Failed logout without token
- JSend format responses

## Running Tests

### Run All Tests
```bash
docker-compose run --rm web rails test
```

### Run Specific Test File
```bash
docker-compose run --rm web rails test test/models/user_test.rb
```

### Run Specific Test
```bash
docker-compose run --rm web rails test test/models/user_test.rb:39
```

### Run Tests by Pattern
```bash
# Run all model tests
docker-compose run --rm web rails test test/models/

# Run all controller tests
docker-compose run --rm web rails test test/controllers/
```

## Test Results Summary

```
✅ 55 runs
✅ 111 assertions
✅ 0 failures
✅ 0 errors
✅ 0 skips
```

## Test Database Setup

The test database is automatically prepared before running tests. If you need to manually set it up:

```bash
# Create test database
docker-compose run --rm web rails db:create RAILS_ENV=test

# Run migrations
docker-compose run --rm web rails db:migrate RAILS_ENV=test

# Load schema (faster alternative to migrations)
docker-compose run --rm web rails db:schema:load RAILS_ENV=test

# Reset and prepare test database
docker-compose run --rm web rails db:test:prepare
```

## Writing New Tests

### Model Test Example

```ruby
require "test_helper"

class MyModelTest < ActiveSupport::TestCase
  def setup
    @model = MyModel.new(attribute: "value")
  end

  test "should be valid with valid attributes" do
    assert @model.valid?
  end

  test "should require attribute" do
    @model.attribute = nil
    assert_not @model.valid?
    assert_includes @model.errors[:attribute], "can't be blank"
  end
end
```

### Controller Test Example

```ruby
require "test_helper"

class Api::V1::MyControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get api_v1_my_resources_url, as: :json
    
    assert_response :success
    json = JSON.parse(response.body)
    assert json["data"].present?
  end

  test "should create resource" do
    assert_difference "MyModel.count", 1 do
      post api_v1_my_resources_url, params: {
        my_model: { attribute: "value" }
      }, as: :json
    end

    assert_response :success
  end
end
```

## Test Helpers

### Devise Test Helpers

The test suite includes Devise test helpers for authentication:

```ruby
# In controller tests
sign_in users(:one)  # Sign in a user from fixtures

# For integration tests with JWT
post login_url, params: { user: { email: "...", password: "..." } }, as: :json
token = response.headers["Authorization"]

# Use token in subsequent requests
get api_v1_protected_url, headers: { "Authorization" => token }
```

## Test Fixtures

Fixtures are located in `test/fixtures/` and can be used to create test data:

```ruby
# test/fixtures/users.yml
one:
  email: user1@example.com
  encrypted_password: <%= Devise::Encryptor.digest(User, 'password123') %>

# In tests
user = users(:one)
```

## Continuous Integration

To run tests in CI/CD pipelines:

```yaml
# Example for GitHub Actions
- name: Run tests
  run: docker-compose run --rm web rails test
```

## Coverage Goals

- ✅ Model validations
- ✅ Model associations
- ✅ Model callbacks
- ✅ API authentication endpoints
- 🔲 API resource endpoints (to be added)
- 🔲 Authorization tests (to be added)
- 🔲 Integration tests (to be added)

## Best Practices

1. **Arrange-Act-Assert** pattern
   - Setup test data (Arrange)
   - Execute the code being tested (Act)
   - Verify the results (Assert)

2. **One assertion per test** (when possible)
   - Makes failures easier to diagnose

3. **Descriptive test names**
   - Use "should" statements: `test "should require email"`

4. **Use factories or fixtures**
   - DRY principle for test data

5. **Test edge cases**
   - Nil values, empty strings, boundary conditions

6. **Keep tests fast**
   - Minimize database operations
   - Use transactions (automatic in Rails tests)

## Troubleshooting

### Tests Fail Due to Missing Tables

```bash
docker-compose run --rm web rails db:test:prepare
```

### Tests Pass Locally But Fail in CI

- Ensure test database is properly set up
- Check for time-dependent tests
- Verify environment variables

### Slow Tests

- Use database transactions (default in Rails)
- Avoid external API calls (use mocks/stubs)
- Run tests in parallel (default in Rails 6+)

## Additional Resources

- [Rails Testing Guide](https://guides.rubyonrails.org/testing.html)
- [Minitest Documentation](https://github.com/minitest/minitest)
- [Devise Testing](https://github.com/heartcombo/devise#test-helpers)

