# Database Models Documentation

This document describes all the models in the IV API application.

## Overview

The application is a **Pantry/Inventory Management System** with the following features:
- User authentication with JWT tokens
- Storage organization (nested/hierarchical)
- Item tracking with quantities and expiration dates
- Purchase tracking with sessions and items
- Subscription management (free/premium plans)

## Entity Relationship Diagram

```
User
├── Subscription (1:1)
├── Storages (1:many)
├── Items (1:many)
└── PurchaseSessions (1:many)

Storage
├── Parent Storage (optional, self-referential)
├── Children Storages (1:many)
└── Items (1:many)

Item
├── Storage (belongs to)
├── User (belongs to)
└── PurchaseItems (1:many)

PurchaseSession
├── User (belongs to)
└── PurchaseItems (1:many)

PurchaseItem
├── PurchaseSession (belongs to)
└── Item (belongs to)

JwtDenylist
└── Token revocation tracking
```

## Models

### 1. User

**Purpose:** Manages user accounts and authentication

**Fields:**
- `email` (string, required, unique) - User's email address
- `encrypted_password` (string, required) - Hashed password
- `reset_password_token` (string) - Token for password reset
- `reset_password_sent_at` (datetime) - When reset was requested
- `remember_created_at` (datetime) - Remember me token timestamp
- `sign_in_count` (integer, default: 0) - Number of sign-ins
- `current_sign_in_at` (datetime) - Current sign-in timestamp
- `last_sign_in_at` (datetime) - Previous sign-in timestamp
- `current_sign_in_ip` (string) - Current sign-in IP address
- `last_sign_in_ip` (string) - Previous sign-in IP address

**Associations:**
- `has_many :storages`
- `has_many :items`
- `has_many :purchase_sessions`
- `has_one :subscription`

**Callbacks:**
- After creation, automatically creates a free subscription

**Devise Modules:**
- `:database_authenticatable` - Password authentication
- `:registerable` - User registration
- `:recoverable` - Password recovery
- `:rememberable` - Remember user
- `:validatable` - Email & password validation
- `:trackable` - Track sign-in info
- `:jwt_authenticatable` - JWT token authentication

### 2. Subscription

**Purpose:** Manages user subscription plans and limits

**Fields:**
- `user_id` (integer, required, unique) - Associated user
- `plan` (string, required, default: 'free') - Plan type (free/premium)
- `pantry_limit` (integer) - Maximum number of pantries allowed
- `started_at` (datetime) - When subscription started
- `expires_at` (datetime) - When subscription expires (null = never)

**Associations:**
- `belongs_to :user`

**Methods:**
- `active?` - Returns true if subscription hasn't expired

**Default Values:**
- Free plan: 10 pantry limit
- Premium plan: Unlimited (nil)

### 3. Storage

**Purpose:** Represents storage locations (pantry, fridge, freezer, etc.) with hierarchical organization

**Fields:**
- `user_id` (integer, required) - Owner of the storage
- `parent_id` (integer, optional) - Parent storage for nesting
- `name` (string, required, max: 100) - Storage name
- `description` (text, max: 500) - Optional description

**Associations:**
- `belongs_to :user`
- `belongs_to :parent, class_name: 'Storage', optional: true`
- `has_many :children, class_name: 'Storage', foreign_key: 'parent_id'`
- `has_many :items`

**Example Hierarchy:**
```
Kitchen (parent)
├── Pantry (child of Kitchen)
│   ├── Shelf 1 (child of Pantry)
│   └── Shelf 2 (child of Pantry)
└── Fridge (child of Kitchen)
```

### 4. Item

**Purpose:** Represents items stored in storage locations

**Fields:**
- `user_id` (integer, required) - Owner of the item
- `storage_id` (integer, required) - Where item is stored
- `name` (string, required, max: 100) - Item name
- `quantity` (decimal, precision: 10, scale: 2) - Current quantity
- `unit` (string, required) - Unit of measurement (oz, lbs, count, etc.)
- `min_quantity` (decimal, precision: 10, scale: 2) - Minimum stock level
- `expiration_date` (date) - When item expires
- `notes` (text) - Additional notes

**Associations:**
- `belongs_to :user`
- `belongs_to :storage`
- `has_many :purchase_items`
- `has_many :purchase_sessions, through: :purchase_items`

**Methods:**
- `low_stock?` - Returns true if quantity is at or below min_quantity

**Example:**
```ruby
Item.create(
  name: "Olive Oil",
  quantity: 32,
  unit: "oz",
  min_quantity: 16,
  expiration_date: 1.year.from_now
)
```

### 5. PurchaseSession

**Purpose:** Represents a shopping trip or purchase event

**Fields:**
- `user_id` (integer, required) - User who made the purchase
- `store_name` (string, required) - Where items were purchased
- `total_amount` (decimal, precision: 10, scale: 2) - Total purchase cost
- `purchased_at` (datetime, required) - When purchase was made
- `notes` (text) - Additional notes about the purchase

**Associations:**
- `belongs_to :user`
- `has_many :purchase_items`
- `has_many :items, through: :purchase_items`

**Callbacks:**
- Sets `purchased_at` to current time if not provided

**Example Use Case:**
Track all items bought during a single shopping trip at Costco on 10/11/2024

### 6. PurchaseItem

**Purpose:** Links items to purchase sessions with pricing details

**Fields:**
- `purchase_session_id` (integer, required) - The purchase session
- `item_id` (integer, required) - The item purchased
- `quantity` (decimal, required, precision: 10, scale: 2) - Quantity purchased
- `unit_price` (decimal, required, precision: 10, scale: 2) - Price per unit
- `total_price` (decimal, required, precision: 10, scale: 2) - Total cost (auto-calculated)

**Associations:**
- `belongs_to :purchase_session`
- `belongs_to :item`

**Callbacks:**
- Before validation, automatically calculates `total_price` from quantity × unit_price

**Constraints:**
- Unique index on `[purchase_session_id, item_id]` - Can't add same item twice to one session

### 7. JwtDenylist

**Purpose:** Tracks revoked JWT tokens for security

**Fields:**
- `jti` (string, required, unique) - JWT token ID
- `exp` (datetime, required) - Token expiration time

**Used By:**
- Devise-JWT for token revocation on logout

## Database Indexes

**Performance indexes created:**
- `users.email` - Unique index for fast lookups
- `jwt_denylist.jti` - Unique index for token validation
- `storages.[user_id, name]` - Composite index for user's storages
- `items.[user_id, name]` - Composite index for user's items
- `items.[storage_id, name]` - Composite index for storage contents
- `purchase_sessions.[user_id, purchased_at]` - For purchase history queries
- `purchase_items.[purchase_session_id, item_id]` - Unique index
- `subscriptions.user_id` - Unique index (one subscription per user)

## Setup Instructions

### 1. Run the setup script:

```bash
./setup-db.sh
```

This will:
- Build Docker containers
- Install gems
- Create the database
- Run all migrations

### 2. Or manually:

```bash
docker-compose build
docker-compose run --rm web bundle install
docker-compose run --rm web rails db:create
docker-compose run --rm web rails db:migrate
```

## Sample Data Creation

Create sample data in Rails console:

```ruby
# Create a user
user = User.create!(
  email: 'test@example.com',
  password: 'password123',
  password_confirmation: 'password123'
)

# User automatically gets a free subscription

# Create storages
kitchen = user.storages.create!(name: 'Kitchen')
pantry = user.storages.create!(name: 'Pantry', parent: kitchen)
fridge = user.storages.create!(name: 'Fridge', parent: kitchen)

# Create items
olive_oil = user.items.create!(
  storage: pantry,
  name: 'Olive Oil',
  quantity: 32,
  unit: 'oz',
  min_quantity: 16
)

milk = user.items.create!(
  storage: fridge,
  name: 'Milk',
  quantity: 1,
  unit: 'gallon',
  min_quantity: 1,
  expiration_date: 7.days.from_now
)

# Create a purchase session
session = user.purchase_sessions.create!(
  store_name: 'Costco',
  purchased_at: Time.current,
  total_amount: 45.99
)

# Add items to purchase
session.purchase_items.create!(
  item: olive_oil,
  quantity: 1,
  unit_price: 12.99
)

session.purchase_items.create!(
  item: milk,
  quantity: 1,
  unit_price: 3.99
)

# Check low stock
olive_oil.low_stock? # => true (32 <= 16 is false, but if quantity was 15, it would be true)
```

## API Endpoints (v1.0)

### ✅ Implemented Authentication Endpoints:

```ruby
# Authentication
POST   /api/v1/signup        # Create account
POST   /api/v1/login         # Login (returns JWT in Authorization header)
DELETE /api/v1/logout        # Logout (requires JWT token)
```

### 🔲 To Be Implemented Resource Endpoints:

```ruby
# Storages
GET    /api/v1/storages           # List all storages
POST   /api/v1/storages           # Create storage
GET    /api/v1/storages/:id       # Show storage
PATCH  /api/v1/storages/:id       # Update storage
DELETE /api/v1/storages/:id       # Delete storage

# Items
GET    /api/v1/items              # List all items
POST   /api/v1/items              # Create item
GET    /api/v1/items/:id          # Show item
PATCH  /api/v1/items/:id          # Update item
DELETE /api/v1/items/:id          # Delete item
GET    /api/v1/items/low_stock    # Get low stock items

# Purchase Sessions
GET    /api/v1/purchase_sessions           # List purchases
POST   /api/v1/purchase_sessions           # Create purchase
GET    /api/v1/purchase_sessions/:id       # Show purchase
PATCH  /api/v1/purchase_sessions/:id       # Update purchase
DELETE /api/v1/purchase_sessions/:id       # Delete purchase

# Subscriptions
GET    /api/v1/subscription                # Get current subscription
PATCH  /api/v1/subscription                # Update subscription
```

## Next Steps

1. ✅ Models created
2. ✅ Migrations created
3. ✅ Authentication setup
4. 🔲 Create API controllers
5. 🔲 Add API routes
6. 🔲 Add validations and tests
7. 🔲 Add serializers for JSON responses
8. 🔲 Add authorization (ensure users can only access their own data)

## Questions?

Refer to:
- [DEVISE_SETUP.md](DEVISE_SETUP.md) - Authentication setup
- [README.md](README.md) - General project information

