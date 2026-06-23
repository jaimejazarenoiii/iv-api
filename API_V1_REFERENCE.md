# API v1.0 Reference

**Base URL:** `http://localhost:3000/api/v1`

## Authentication Endpoints

All authentication endpoints are under `/api/v1`

### Sign Up

**Endpoint:** `POST /api/v1/signup`

**Request Body:**
```json
{
  "email": "user@example.com",
  "password": "password123",
  "password_confirmation": "password123"
}
```

**Success Response (200):**
```json
{
  "status": {
    "code": 200,
    "message": "Signed up successfully. Please login to get your token."
  },
  "data": {
    "user": {
      "id": 1,
      "email": "user@example.com"
    }
  }
}
```

**Note:** 
- When you sign up, a free subscription is automatically created with limits of **1 space**, **3 storages**, and **10 items**. Upgrade to premium for unlimited usage.
- After signup, you need to **login** to receive your JWT token.

---

### Login

**Endpoint:** `POST /api/v1/login`

**Request Body:**
```json
{
  "user": {
    "email": "user@example.com",
    "password": "password123"
  }
}
```

**Success Response (200):**
```json
{
  "status": {
    "code": 200,
    "message": "Logged in successfully."
  },
  "data": {
    "user": {
      "id": 1,
      "email": "user@example.com"
    },
    "token": "eyJhbGciOiJIUzI1NiJ9..."
  }
}
```

**Response Headers:**
```
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9...
```

**Important:** The JWT token is available in both:
- Response body: `data.token`
- Response header: `Authorization`

Save the token and include it in all subsequent API calls.

---

### Logout

**Endpoint:** `DELETE /api/v1/logout`

**Request Headers:**
```
Authorization: Bearer YOUR_JWT_TOKEN_HERE
```

**Success Response (200):**
```json
{
  "status": 200,
  "message": "Logged out successfully."
}
```

**Unauthorized Response (401):**
```json
{
  "status": 401,
  "message": "Couldn't find an active session."
}
```

---

## Using the API

### 1. Sign Up
```bash
curl -X POST http://localhost:3000/api/v1/signup \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@example.com",
    "password": "password123",
    "password_confirmation": "password123"
  }'
```

### 2. Login and Save Token
```bash
curl -i -X POST http://localhost:3000/api/v1/login \
  -H "Content-Type: application/json" \
  -d '{
    "user": {
      "email": "test@example.com",
      "password": "password123"
    }
  }'
```

Look for the `Authorization` header in the response. Example:
```
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIxIiwic2NwIjoidXNlciIsImF1ZCI6bnVsbCwiaWF0IjoxNjk3MDQ5NjAwLCJleHAiOjE2OTcxMzYwMDAsImp0aSI6ImFiYzEyMyJ9.xyz789
```

### 3. Make Authenticated Requests
```bash
curl -X GET http://localhost:3000/api/v1/storages \
  -H "Authorization: Bearer YOUR_JWT_TOKEN_HERE" \
  -H "Content-Type: application/json"
```

### 4. Logout
```bash
curl -X DELETE http://localhost:3000/api/v1/logout \
  -H "Authorization: Bearer YOUR_JWT_TOKEN_HERE"
```

---

## Resource Endpoints

### Authorization

All resource endpoints require authentication. Include the JWT token in the `Authorization` header:

```
Authorization: Bearer YOUR_JWT_TOKEN
```

### Available Endpoints:

### Dashboard
- `GET /api/v1/dashboard` - Get dashboard data (recent spaces, storages, and items)

**Dashboard Endpoint:**

**GET /api/v1/dashboard**

**Headers:**
```
Authorization: Bearer YOUR_JWT_TOKEN
```

**Success Response (200):**
```json
{
  "status": {
    "code": 200,
    "message": "Dashboard data retrieved successfully."
  },
  "data": {
    "spaces": [
      {
        "id": 1,
        "name": "Kitchen",
        "description": "Main kitchen area",
        "image_url": "http://localhost:3000/rails/active_storage/blobs/...",
        "storages_count": 2,
        "substorages_count": 2,
        "items_count": 4,
        "created_at": "2024-01-15T10:30:00.000Z",
        "updated_at": "2024-01-15T10:30:00.000Z"
      }
    ],
    "storages": [
      {
        "id": 1,
        "name": "Pantry",
        "description": "Kitchen pantry",
        "space_id": 1,
        "space_name": "Kitchen",
        "items_count": 2,
        "substorages_count": 1,
        "total_items_count": 4,
        "created_at": "2024-01-15T10:30:00.000Z",
        "updated_at": "2024-01-15T10:30:00.000Z"
      }
    ],
    "items": [
      {
        "id": 1,
        "name": "Rice",
        "notes": "White rice",
        "quantity": 5,
        "unit": "kg",
        "storage_id": 1,
        "storage_name": "Pantry",
        "space_name": "Kitchen",
        "image_url": "http://localhost:3000/rails/active_storage/blobs/...",
        "created_at": "2024-01-15T10:30:00.000Z",
        "updated_at": "2024-01-15T10:30:00.000Z"
      }
    ]
  }
}
```

**Notes:**
- Returns the 5 most recently updated spaces, storages, and items for the authenticated user
- Results are ordered by `updated_at` in descending order (most recent first)
- Each array is limited to 5 items maximum
- Includes related data (e.g., space names in storage items, storage names in item data)

**Field Explanations:**
- **Spaces:**
  - `storages_count`: Number of top-level storages (parent_id is null)
  - `substorages_count`: Total number of substorages (recursive count)
  - `items_count`: Total items in all storages and substorages (recursive count)

- **Storages:**
  - `items_count`: Number of direct items in this storage only
  - `substorages_count`: Number of direct substorages (children)
  - `total_items_count`: Total items including all substorages (recursive count)

- **Items:**
  - `notes`: Item notes/description (replaces old `description` field)
  - `unit`: Item unit of measurement (replaces old `unit_price` field)

- **Image URLs:**
  - All `image_url` fields return full URLs (e.g., `http://localhost:3000/rails/active_storage/blobs/...`)
  - Returns `null` if no image is attached

### Profile
- `GET /api/v1/profile` - Get current user's profile
- `PATCH /api/v1/profile` - Update profile information
- `DELETE /api/v1/profile/image` - Delete profile image

**Profile Fields:**
- `first_name`, `last_name`, `middle_name` (optional text fields)
- `gender` (optional: `male`, `female`, `other`, `prefer_not_to_say`)
- `profile_image` (optional file upload: JPEG, PNG, GIF, WebP, max 5MB)

See [PROFILE_GUIDE.md](PROFILE_GUIDE.md) for detailed usage examples.

**Image Upload Support:**
- All entities (spaces, storages, items) support image uploads
- Supported formats: JPEG, PNG, GIF, WebP (max 5MB)
- Images can be uploaded via PATCH requests using multipart/form-data
- Images can be deleted via DELETE endpoints
- See [IMAGE_UPLOAD_GUIDE.md](IMAGE_UPLOAD_GUIDE.md) for detailed examples

### Spaces
- `GET /api/v1/spaces` - List all your spaces
- `POST /api/v1/spaces` - Create a new space
- `GET /api/v1/spaces/:id` - Get space details
- `PATCH /api/v1/spaces/:id` - Update a space (supports image upload)
- `DELETE /api/v1/spaces/:id` - Delete a space
- `DELETE /api/v1/spaces/:id/image` - Delete space image

### Storages
- `GET /api/v1/storages` - List all your storage locations
- `POST /api/v1/storages` - Create a new storage location
- `GET /api/v1/storages/:id` - Get storage details (includes paginated sub-storages and items)
- `PATCH /api/v1/storages/:id` - Update a storage (supports image upload)
- `DELETE /api/v1/storages/:id` - Delete a storage
- `DELETE /api/v1/storages/:id/image` - Delete storage image
- `POST /api/v1/storages/:id/move` - Move a storage to another space or under a parent storage
- `GET /api/v1/spaces/:space_id/storages` - List storages within a specific space
- `POST /api/v1/spaces/:space_id/storages` - Create storage within a specific space

### Items
- `GET /api/v1/items` - List all your items
- `POST /api/v1/items` - Add a new item
- `GET /api/v1/items/:id` - Get item details
- `PATCH /api/v1/items/:id` - Update an item (supports image upload)
- `DELETE /api/v1/items/:id` - Delete an item
- `GET /api/v1/items/low_stock` - Get items below minimum quantity
- `GET /api/v1/items/out_of_stock` - Get items below out-of-stock threshold
- `DELETE /api/v1/items/:id/image` - Delete item image
- `POST /api/v1/items/:id/move` - Move an item to another storage

**Get Item Details:**

**Endpoint:** `GET /api/v1/items/:id`

**Headers:**
```
Authorization: Bearer YOUR_JWT_TOKEN
```

**Success Response (200):**
```json
{
  "status": { "code": 200, "message": "Item retrieved successfully." },
  "data": {
    "item": {
      "id": 1,
      "name": "Olive Oil",
      "quantity": 32.0,
      "unit": "oz",
      "min_quantity": 16.0,
      "out_of_stock_threshold": null,
      "low_stock_alert_enabled": true,
      "out_of_stock_alert_enabled": false,
      "expiration_date": "2025-12-31",
      "notes": "Extra virgin olive oil",
      "storage_id": 2,
      "storage_name": "Top Shelf",
      "image_url": "http://localhost:3000/rails/active_storage/blobs/...",
      "location_path": "Kitchen > Pantry > Top Shelf > Olive Oil",
      "location_array": [
        { "type": "space", "id": 1, "name": "Kitchen" },
        { "type": "storage", "id": 1, "name": "Pantry" },
        { "type": "storage", "id": 2, "name": "Top Shelf" },
        { "type": "item", "id": 1, "name": "Olive Oil" }
      ],
      "categories": [
        { "id": 1, "name": "Spices" },
        { "id": 2, "name": "Cooking Oils" }
      ],
      "low_stock": false,
      "out_of_stock": false,
      "created_at": "2024-10-11T13:00:00.000Z",
      "updated_at": "2024-10-11T13:00:00.000Z"
    }
  }
}
```

**Response Fields:**
- `id` (integer) - Item ID
- `name` (string) - Item name
- `quantity` (decimal) - Current quantity
- `unit` (string, required) - Unit of measurement (e.g., "oz", "kg", "pieces")
- `min_quantity` (decimal) - Minimum quantity threshold for low stock alerts
- `out_of_stock_threshold` (decimal, nullable) - Threshold for out-of-stock alerts
- `low_stock_alert_enabled` (boolean) - Whether low stock alerts are enabled
- `out_of_stock_alert_enabled` (boolean) - Whether out-of-stock alerts are enabled
- `expiration_date` (string, nullable) - Expiration date in YYYY-MM-DD format
- `notes` (string, nullable) - Item notes/description
- `storage_id` (integer) - ID of the storage containing this item
- `storage_name` (string) - Name of the storage
- `image_url` (string, nullable) - Full URL to the item image, or null if no image
- `location_path` (string) - Breadcrumb string showing full location hierarchy (e.g., "Kitchen > Pantry > Item")
- `location_array` (array) - Structured array of location hierarchy, each object contains:
  - `type` (string) - Type of location ("space", "storage", or "item")
  - `id` (integer) - ID of the location
  - `name` (string) - Name of the location
- `categories` (array) - Array of category objects associated with this item, each containing:
  - `id` (integer) - Category ID
  - `name` (string) - Category name
- `low_stock` (boolean) - True if item quantity is below `min_quantity`
- `out_of_stock` (boolean) - True if item quantity is below `out_of_stock_threshold`
- `created_at` (string) - ISO 8601 timestamp of creation
- `updated_at` (string) - ISO 8601 timestamp of last update

**Error Response (404):**
```json
{
  "status": { "code": 404, "message": "Item not found." },
  "errors": ["Item does not exist or you do not have permission to access it."]
}
```

**Error Response (401):**
```json
{
  "status": { "code": 401, "message": "You need to sign in or sign up before continuing." }
}
```

### Browse & Location Picker

These endpoints support incremental selection with minimal payloads and a `has_children` flag.

- `GET /api/v1/browse/spaces` - Minimal list of spaces for the first step
- `GET /api/v1/browse/storages?space_id=:space_id` - Top‑level storages in a space
- `GET /api/v1/browse/storages?parent_id=:storage_id` - Child storages of a storage

Example responses:

Spaces
```json
{
  "status": { "code": 200, "message": "Spaces retrieved successfully." },
  "data": { "spaces": [ { "id": 1, "name": "Kitchen", "has_children": true } ] }
}
```

Storages
```json
{
  "status": { "code": 200, "message": "Storages retrieved successfully." },
  "data": { "storages": [ { "id": 10, "name": "Top right cabinet", "has_children": true } ] }
}
```

### Purchase Sessions
- `GET /api/v1/purchase_sessions` - List all purchase sessions
- `POST /api/v1/purchase_sessions` - Record a new purchase
- `GET /api/v1/purchase_sessions/:id` - Get purchase details
- `PATCH /api/v1/purchase_sessions/:id` - Update a purchase
- `DELETE /api/v1/purchase_sessions/:id` - Delete a purchase

### Subscription
- `GET /api/v1/subscription` - Get your subscription details
- `PATCH /api/v1/subscription` - Update subscription (upgrade to premium)

---

## Error Responses

### 401 Unauthorized
```json
{
  "error": "You need to sign in or sign up before continuing."
}
```

### 422 Unprocessable Entity (Validation Error)
```json
{
  "status": {
    "message": "User couldn't be created successfully. Email has already been taken"
  }
}
```

### 403 Forbidden (Subscription Limit Reached)

This error occurs when a free plan user tries to create resources beyond their plan limits.

**Free Plan Limits:**
- **1 space** maximum
- **3 storages** maximum
- **10 items** maximum

**Premium Plan:**
- Unlimited spaces, storages, and items

**Error Response Format:**
```json
{
  "status": {
    "code": 403,
    "message": "Limit reached for current plan."
  },
  "errors": [
    "Your current plan allows up to {limit} {resource}. Upgrade your subscription to increase this limit."
  ]
}
```

**Example - Space Limit Reached:**
```json
{
  "status": {
    "code": 403,
    "message": "Limit reached for current plan."
  },
  "errors": [
    "Your current plan allows up to 1 space. Upgrade your subscription to increase this limit."
  ]
}
```

**Example - Storage Limit Reached:**
```json
{
  "status": {
    "code": 403,
    "message": "Limit reached for current plan."
  },
  "errors": [
    "Your current plan allows up to 3 storages. Upgrade your subscription to increase this limit."
  ]
}
```

**Example - Item Limit Reached:**
```json
{
  "status": {
    "code": 403,
    "message": "Limit reached for current plan."
  },
  "errors": [
    "Your current plan allows up to 10 items. Upgrade your subscription to increase this limit."
  ]
}
```

**When This Error Occurs:**
- `POST /api/v1/spaces` - When user already has 1 space (free plan)
- `POST /api/v1/storages` - When user already has 3 storages (free plan)
- `POST /api/v1/items` - When user already has 10 items (free plan)

**How to Handle in Flutter:**
1. Check for `status.code == 403`
2. Display the error message from `errors[0]` to the user
3. Optionally show an "Upgrade to Premium" button/link
4. The error message automatically uses correct singular/plural forms

---

## Token Expiration

JWT tokens expire after **24 hours** (1 day). After expiration, you'll need to login again to get a new token.

---

## CORS

CORS is enabled for all origins (`*`). You can make requests from any domain. To restrict this in production, modify `config/initializers/cors.rb`.

---

## API Versioning

This is version **1.0** of the API. All endpoints are under the `/api/v1` namespace. Future versions (if needed) will be under `/api/v2`, `/api/v3`, etc.

---

## Rate Limiting

Currently, there is **no rate limiting** implemented. Consider adding rate limiting for production use.

---

## Health Check

**Endpoint:** `GET /up`

This endpoint is outside the API namespace and is used for health checks (load balancers, uptime monitoring).

**Success Response (200):**
```
ok
```

---

## Next Steps for Development

1. ✅ Authentication implemented
2. 🔲 Implement Storages CRUD
3. 🔲 Implement Items CRUD
4. 🔲 Implement Purchase Sessions CRUD
5. 🔲 Add authorization (users can only access their own data)
6. 🔲 Add serializers for consistent JSON responses
7. 🔲 Add tests
8. 🔲 Add rate limiting
9. 🔲 Add API documentation (Swagger/OpenAPI)

---

## Support

For issues or questions, refer to:
- [README.md](README.md) - Project overview
- [MODELS.md](MODELS.md) - Database schema and models
- [DEVISE_SETUP.md](DEVISE_SETUP.md) - Authentication details

