# Devise + JWT Setup Guide

This guide will help you set up Devise with JWT token authentication for your Rails API.

## Step 1: Install Dependencies

Build and install the gems:

```bash
docker-compose build
docker-compose run --rm web bundle install
```

## Step 2: Install Devise

Generate Devise configuration:

```bash
docker-compose run --rm web rails generate devise:install
```

## Step 3: Create User Model

Generate a User model with Devise:

```bash
docker-compose run --rm web rails generate devise User
```

This creates:
- `app/models/user.rb`
- Migration file in `db/migrate/`

## Step 4: Configure JWT

### Add JWT Secret Key

Generate a secret key:

```bash
docker-compose run --rm web rails secret
```

Add this to your `config/credentials.yml.enc` or as an environment variable in `docker-compose.yml`:

```yaml
environment:
  DEVISE_JWT_SECRET_KEY: your_generated_secret_here
```

### Update User Model

Edit `app/models/user.rb`:

```ruby
class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :jwt_authenticatable, jwt_revocation_strategy: JwtDenylist
end
```

## Step 5: Create JWT Denylist

Generate the denylist model:

```bash
docker-compose run --rm web rails generate model JwtDenylist jti:string:index exp:datetime
```

Update `app/models/jwt_denylist.rb`:

```ruby
class JwtDenylist < ApplicationRecord
  include Devise::JWT::RevocationStrategies::Denylist

  self.table_name = 'jwt_denylist'
end
```

## Step 6: Configure Devise

Add to `config/initializers/devise.rb`:

```ruby
config.jwt do |jwt|
  jwt.secret = ENV['DEVISE_JWT_SECRET_KEY']
  jwt.dispatch_requests = [
    ['POST', %r{^/login$}]
  ]
  jwt.revocation_requests = [
    ['DELETE', %r{^/logout$}]
  ]
  jwt.expiration_time = 1.day.to_i
end

config.navigational_formats = []
```

## Step 7: Create API Controllers

### Sessions Controller

Create `app/controllers/api/v1/sessions_controller.rb`:

```ruby
class Api::V1::SessionsController < Devise::SessionsController
  respond_to :json

  private

  def respond_with(resource, _opts = {})
    render json: {
      status: { code: 200, message: 'Logged in successfully.' },
      data: UserSerializer.new(resource).serializable_hash[:data][:attributes]
    }, status: :ok
  end

  def respond_to_on_destroy
    if current_user
      render json: {
        status: 200,
        message: "Logged out successfully"
      }, status: :ok
    else
      render json: {
        status: 401,
        message: "Couldn't find an active session."
      }, status: :unauthorized
    end
  end
end
```

### Registrations Controller

Create `app/controllers/api/v1/registrations_controller.rb`:

```ruby
class Api::V1::RegistrationsController < Devise::RegistrationsController
  respond_to :json

  private

  def respond_with(resource, _opts = {})
    if resource.persisted?
      render json: {
        status: { code: 200, message: 'Signed up successfully.' },
        data: UserSerializer.new(resource).serializable_hash[:data][:attributes]
      }, status: :ok
    else
      render json: {
        status: { message: "User couldn't be created successfully. #{resource.errors.full_messages.to_sentence}" }
      }, status: :unprocessable_entity
    end
  end
end
```

## Step 8: Update Routes

Edit `config/routes.rb`:

```ruby
Rails.application.routes.draw do
  devise_for :users, path: '', path_names: {
    sign_in: 'login',
    sign_out: 'logout',
    registration: 'signup'
  },
  controllers: {
    sessions: 'api/v1/sessions',
    registrations: 'api/v1/registrations'
  }

  # Health check
  get "up" => "rails/health#show", as: :rails_health_check

  # API routes
  namespace :api do
    namespace :v1 do
      # Protected routes example
      resources :posts, only: [:index, :create, :show, :update, :destroy]
    end
  end
end
```

## Step 9: Run Migrations

```bash
docker-compose run --rm web rails db:migrate
```

## Step 10: Test Authentication

### Sign Up
```bash
curl -X POST http://localhost:3000/signup \
  -H "Content-Type: application/json" \
  -d '{
    "user": {
      "email": "test@example.com",
      "password": "password123",
      "password_confirmation": "password123"
    }
  }'
```

### Login
```bash
curl -X POST http://localhost:3000/login \
  -H "Content-Type: application/json" \
  -d '{
    "user": {
      "email": "test@example.com",
      "password": "password123"
    }
  }'
```

The login response will include an `Authorization` header with the JWT token.

### Access Protected Route
```bash
curl -X GET http://localhost:3000/api/v1/posts \
  -H "Authorization: Bearer YOUR_JWT_TOKEN_HERE"
```

### Logout
```bash
curl -X DELETE http://localhost:3000/logout \
  -H "Authorization: Bearer YOUR_JWT_TOKEN_HERE"
```

## Protecting Routes

To protect controller actions, add `before_action :authenticate_user!`:

```ruby
class Api::V1::PostsController < ApplicationController
  before_action :authenticate_user!

  def index
    render json: { message: "This is protected!", user: current_user.email }
  end
end
```

## Optional: User Serializer

For better JSON responses, consider adding a serializer gem like `jsonapi-serializer`:

```ruby
# Gemfile
gem 'jsonapi-serializer'
```

Then create `app/serializers/user_serializer.rb`:

```ruby
class UserSerializer
  include JSONAPI::Serializer
  attributes :id, :email, :created_at
end
```

## Environment Variables

Don't forget to add the JWT secret to your `docker-compose.yml`:

```yaml
environment:
  DATABASE_HOST: db
  DATABASE_USER: postgres
  DATABASE_PASSWORD: password
  RAILS_ENV: development
  RAILS_MAX_THREADS: 5
  DEVISE_JWT_SECRET_KEY: your_generated_secret_key_here
```

## Summary

You now have:
- ✅ User authentication with Devise
- ✅ JWT token-based authentication
- ✅ Login/Logout/Signup endpoints
- ✅ Token revocation with denylist
- ✅ Protected API routes

For more information, see:
- [Devise Documentation](https://github.com/heartcombo/devise)
- [Devise-JWT Documentation](https://github.com/waiting-for-dev/devise-jwt)

