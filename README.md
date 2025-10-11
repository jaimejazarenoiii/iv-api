# IV API

A Rails 8.0 API application with PostgreSQL, fully dockerized.

## Requirements

- Docker
- Docker Compose

## Getting Started

### 1. Build the Docker containers

```bash
docker-compose build
```

### 2. Create the database

```bash
docker-compose run --rm web rails db:create
docker-compose run --rm web rails db:migrate
```

### 3. Start the application

```bash
docker-compose up
```

The API will be available at `http://localhost:3000`

## API Endpoints (v1.0)

### Authentication

**Base URL:** `http://localhost:3000/api/v1`

- **POST** `/api/v1/signup` - Create a new account
- **POST** `/api/v1/login` - Login and get JWT token
- **DELETE** `/api/v1/logout` - Logout and revoke token

### Example: Sign Up

```bash
curl -X POST http://localhost:3000/api/v1/signup \
  -H "Content-Type: application/json" \
  -d '{
    "user": {
      "email": "test@example.com",
      "password": "password123",
      "password_confirmation": "password123"
    }
  }'
```

### Example: Login

```bash
curl -X POST http://localhost:3000/api/v1/login \
  -H "Content-Type: application/json" \
  -d '{
    "user": {
      "email": "test@example.com",
      "password": "password123"
    }
  }'
```

The response will include the JWT token in both:
- The response body under `data.token`
- The `Authorization` header

### Example: Logout

```bash
curl -X DELETE http://localhost:3000/api/v1/logout \
  -H "Authorization: Bearer YOUR_JWT_TOKEN_HERE"
```

## Useful Commands

### Run Rails console

```bash
docker-compose run --rm web rails console
```

### Run migrations

```bash
docker-compose run --rm web rails db:migrate
```

### Generate a new controller

```bash
docker-compose run --rm web rails generate controller ControllerName
```

### Generate a new model

```bash
docker-compose run --rm web rails generate model ModelName
```

### Run tests

```bash
docker-compose run --rm web rails test
```

### Access PostgreSQL database directly

```bash
docker-compose exec db psql -U postgres -d iv_api_development
```

### View all API routes

```bash
docker-compose run --rm web rails routes
```

## Environment Variables

The following environment variables are configured in `docker-compose.yml`:

- `DATABASE_HOST`: PostgreSQL host (default: `db`)
- `DATABASE_USER`: PostgreSQL user (default: `postgres`)
- `DATABASE_PASSWORD`: PostgreSQL password (default: `password`)
- `RAILS_ENV`: Rails environment (default: `development`)

## Project Structure

```
.
├── app/
│   ├── channels/       # Action Cable channels
│   ├── controllers/    # API controllers
│   ├── jobs/          # Active Job classes
│   ├── mailers/       # Action Mailer classes
│   └── models/        # Active Record models
├── bin/               # Rails scripts
├── config/            # Application configuration
├── db/                # Database files
│   ├── migrate/       # Database migrations
│   └── seeds.rb       # Database seeds
├── lib/               # Library modules
├── log/               # Application logs
├── public/            # Static files
├── tmp/               # Temporary files
├── Dockerfile         # Docker configuration
├── docker-compose.yml # Docker Compose configuration
└── README.md          # This file
```

## API Endpoints

### Health Check

- **GET** `/up` - Returns 200 if the app is running

Add your custom API endpoints in `config/routes.rb` and create corresponding controllers in `app/controllers/`.

## Development

This is a Rails API-only application, which means:

- No views, helpers, or assets
- Uses `ActionController::API` instead of `ActionController::Base`
- Includes middleware for API functionality
- Configured with CORS support for cross-origin requests

## Database

This application uses PostgreSQL. The database configuration can be found in `config/database.yml`.

Database credentials are configured via environment variables for security and flexibility across different environments.

## CORS Configuration

CORS is configured in `config/initializers/cors.rb` to allow all origins. Modify this file to restrict access as needed for your use case.

## Key Features

✅ **Rails 8.0** with API-only mode  
✅ **Ruby 3.2.1**  
✅ **PostgreSQL 15** database  
✅ **Docker & Docker Compose** fully configured  
✅ **Devise + JWT** for authentication (setup required - see [DEVISE_SETUP.md](DEVISE_SETUP.md))  
✅ **CORS** enabled for cross-origin requests  
✅ **Auto-migration** on container startup  
✅ **Volume persistence** for database and gems  
✅ **Health check** endpoint at `/up`

## Quick Start

### First Time Setup

Run the database setup script:

```bash
./setup-db.sh
```

This will build containers, install gems, create the database, and run migrations.

### Start the Application

```bash
./start.sh
```

Or manually:

```bash
docker-compose up
```

## Documentation

- **[API_V1_REFERENCE.md](API_V1_REFERENCE.md)** - Complete API v1.0 endpoint reference
- **[MODELS.md](MODELS.md)** - Complete database schema and models documentation
- **[DEVISE_SETUP.md](DEVISE_SETUP.md)** - Authentication setup guide
- **[TESTING.md](TESTING.md)** - Testing guide and running tests
- **[ENV_SETUP.md](ENV_SETUP.md)** - Environment variables configuration guide

## Application Features

This is a **Pantry/Inventory Management API** with:
- 👤 **User Authentication** - JWT-based authentication with Devise
- 📦 **Storage Management** - Organize items in hierarchical storage locations
- 🥫 **Item Tracking** - Track quantities, expiration dates, and minimum stock levels
- 🛒 **Purchase Tracking** - Record shopping sessions and item purchases
- 💳 **Subscription System** - Free and premium plan support

## Models

- **User** - User accounts with authentication
- **Subscription** - Free/Premium plans with pantry limits
- **Storage** - Storage locations (pantry, fridge, etc.) with parent-child relationships
- **Item** - Items with quantities, units, and expiration tracking
- **PurchaseSession** - Shopping trips/purchases
- **PurchaseItem** - Items purchased in a session
- **JwtDenylist** - Token revocation for logout

See **[MODELS.md](MODELS.md)** for detailed documentation.

## License

This project is available as open source.

