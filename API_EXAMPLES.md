# API v1.0 - Usage Examples

Complete examples for all API endpoints.

## Table of Contents
- [Authentication](#authentication)
- [Spaces API](#spaces-api) 🆕
- [Storages API](#storages-api)
- [Browse API](#browse-api)
- [Items API](#items-api)
- [Categories API](#categories-api)
- [Complete Workflow: Create Item with Categories](#complete-workflow-create-item-with-categories)
- [Move API](#move-api)
- [Purchase Sessions API](#purchase-sessions-api)
- [Subscription API](#subscription-api)

---

## Authentication

### Sign Up
```bash
curl -X POST http://localhost:3000/api/v1/signup \
  -H "Content-Type: application/json" \
  -d '{
    "email": "user@example.com",
    "password": "password123",
    "password_confirmation": "password123"
  }'
```

### Login (Get Token)
```bash
curl -X POST http://localhost:3000/api/v1/login \
  -H "Content-Type: application/json" \
  -d '{
    "user": {
      "email": "user@example.com",
      "password": "password123"
    }
  }'
```

**Save the token from `data.token` for all subsequent requests!**

---

## Spaces API

**Spaces** are top-level locations (rooms/areas) that contain storages. Think: Kitchen, Bedroom, Garage, etc.

All requests require: `-H "Authorization: Bearer YOUR_JWT_TOKEN"`

### Available Space Types
`bedroom`, `kitchen`, `bathroom`, `living_room`, `dining_room`, `garage`, `basement`, `attic`, `office`, `closet`, `outdoor`, `storage_unit`, `other`

### List All Spaces
```bash
curl -X GET http://localhost:3000/api/v1/spaces \
  -H "Authorization: Bearer YOUR_JWT_TOKEN"
```

**Response:**
```json
{
  "status": { "code": 200, "message": "Spaces retrieved successfully." },
  "data": {
    "spaces": [
      {
        "id": 1,
        "name": "Kitchen",
        "space_type": "kitchen",
        "description": "Main kitchen area",
        "storages_count": 3,
        "created_at": "2024-10-11T13:00:00.000Z",
        "updated_at": "2024-10-11T13:00:00.000Z"
      }
    ]
  }
}
```

### Create Space
```bash
curl -X POST http://localhost:3000/api/v1/spaces \
  -H "Authorization: Bearer YOUR_JWT_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "space": {
      "name": "Master Bedroom",
      "space_type": "bedroom",
      "description": "Main bedroom with walk-in closet"
    }
  }'
```

**Success Response (201):**
```json
{
  "status": { "code": 201, "message": "Space created successfully." },
  "data": {
    "space": {
      "id": 1,
      "name": "Master Bedroom",
      "description": "Main bedroom with walk-in closet",
      "image_url": null,
      "storages_count": 0,
      "created_at": "2024-10-11T13:00:00.000Z",
      "updated_at": "2024-10-11T13:00:00.000Z"
    }
  }
}
```

**Error Response (403) - Limit Reached (Free Plan):**
When a free user tries to create more than 1 space:
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

### Get Space Details (includes storages)
```bash
curl -X GET http://localhost:3000/api/v1/spaces/1 \
  -H "Authorization: Bearer YOUR_JWT_TOKEN"
```

**Response:**
```json
{
  "status": { "code": 200, "message": "Space retrieved successfully." },
  "data": {
    "space": {
      "id": 1,
      "name": "Kitchen",
      "space_type": "kitchen",
      "description": "Main kitchen area",
      "storages_count": 3,
      "storages": [
        { "id": 1, "name": "Pantry", "items_count": 15 },
        { "id": 2, "name": "Fridge", "items_count": 8 },
        { "id": 3, "name": "Freezer", "items_count": 12 }
      ],
      "created_at": "2024-10-11T13:00:00.000Z",
      "updated_at": "2024-10-11T13:00:00.000Z"
    }
  }
}
```

### Update Space
```bash
curl -X PATCH http://localhost:3000/api/v1/spaces/1 \
  -H "Authorization: Bearer YOUR_JWT_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "space": {
      "name": "Renovated Kitchen",
      "description": "Updated description"
    }
  }'
```

### Delete Space
```bash
curl -X DELETE http://localhost:3000/api/v1/spaces/1 \
  -H "Authorization: Bearer YOUR_JWT_TOKEN"
```

**⚠️ Warning:** Deletes all storages and items in this space!

---

## Storages API

**Storages** are containers within spaces. Think: Pantry, Closet, Tool Box, etc.

All requests require: `-H "Authorization: Bearer YOUR_JWT_TOKEN"`

### List All Storages
```bash
curl -X GET http://localhost:3000/api/v1/storages \
  -H "Authorization: Bearer YOUR_JWT_TOKEN"
```

**Response:**
```json
{
  "status": { "code": 200, "message": "Storages retrieved successfully." },
  "data": {
    "storages": [
      {
        "id": 1,
        "name": "Kitchen Pantry",
        "description": "Main kitchen storage",
        "parent_id": null,
        "children_count": 2,
        "items_count": 5,
        "created_at": "2024-10-11T13:00:00.000Z",
        "updated_at": "2024-10-11T13:00:00.000Z"
      }
    ]
  }
}
```

### Create Storage (in a Space)
```bash
curl -X POST http://localhost:3000/api/v1/storages \
  -H "Authorization: Bearer YOUR_JWT_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "storage": {
      "name": "Kitchen Pantry",
      "space_id": 1,
      "description": "Main kitchen storage area"
    }
  }'
```

**Success Response (201):**
```json
{
  "status": { "code": 201, "message": "Storage created successfully." },
  "data": {
    "storage": {
      "id": 1,
      "name": "Kitchen Pantry",
      "description": "Main kitchen storage area",
      "space_id": 1,
      "space_name": "Kitchen",
      "parent_id": null,
      "image_url": null,
      "location_path": "Kitchen > Kitchen Pantry",
      "children_count": 0,
      "items_count": 0,
      "created_at": "2024-10-11T13:00:00.000Z",
      "updated_at": "2024-10-11T13:00:00.000Z"
    }
  }
}
```

**Error Response (403) - Limit Reached (Free Plan):**
When a free user tries to create more than 3 storages:
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

### Create Storage via Nested Route (recommended)
```bash
curl -X POST http://localhost:3000/api/v1/spaces/1/storages \
  -H "Authorization: Bearer YOUR_JWT_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "storage": {
      "name": "Kitchen Pantry",
      "description": "Main kitchen storage area"
    }
  }'
```

### Create Storage (standalone, no space)
```bash
curl -X POST http://localhost:3000/api/v1/storages \
  -H "Authorization: Bearer YOUR_JWT_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "storage": {
      "name": "Misc Storage",
      "description": "General storage"
    }
  }'
```

### Create Nested Storage (with parent)
```bash
curl -X POST http://localhost:3000/api/v1/storages \
  -H "Authorization: Bearer YOUR_JWT_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "storage": {
      "name": "Top Shelf",
      "description": "Upper shelf in pantry",
      "parent_id": 1
    }
  }'
```

### Get Storage Details (with paginated sub-storages and items)
```bash
curl -X GET http://localhost:3000/api/v1/storages/1 \
  -H "Authorization: Bearer YOUR_JWT_TOKEN"
```

**Response:**
```json
{
  "status": { "code": 200, "message": "Storage retrieved successfully." },
  "data": {
    "storage": {
      "id": 1,
      "name": "Kitchen Pantry",
      "description": "Main kitchen storage",
      "space_id": 1,
      "space_name": "Kitchen",
      "parent_id": null,
      "image_url": null,
      "children_count": 3,
      "items_count": 15,
      "children": {
        "data": [
          {
            "id": 2,
            "name": "Top Shelf",
            "description": "Upper shelf",
            "space_id": 1,
            "space_name": "Kitchen",
            "parent_id": 1,
            "image_url": null,
            "children_count": 0,
            "items_count": 5,
            "created_at": "2024-10-11T13:00:00.000Z",
            "updated_at": "2024-10-11T13:00:00.000Z"
          }
        ],
        "pagination": {
          "current_page": 1,
          "per_page": 10,
          "total_count": 3,
          "total_pages": 1,
          "has_next_page": false,
          "has_prev_page": false
        }
      },
      "items": {
        "data": [
          {
            "id": 1,
            "name": "Olive Oil",
            "quantity": 32.0,
            "unit": "oz",
            "min_quantity": 16.0,
            "out_of_stock_threshold": null,
            "low_stock_alert_enabled": true,
            "out_of_stock_alert_enabled": false,
            "expiration_date": "2025-12-31",
            "notes": "Extra virgin",
            "image_url": null,
            "low_stock": false,
            "out_of_stock": false,
            "created_at": "2024-10-11T13:00:00.000Z",
            "updated_at": "2024-10-11T13:00:00.000Z"
          }
        ],
        "pagination": {
          "current_page": 1,
          "per_page": 10,
          "total_count": 15,
          "total_pages": 2,
          "has_next_page": true,
          "has_prev_page": false
        }
      },
      "created_at": "2024-10-11T13:00:00.000Z",
      "updated_at": "2024-10-11T13:00:00.000Z"
    }
  }
}
```

### Get Storage Details with Pagination
```bash
# Get page 2 of sub-storages and page 1 of items
curl -X GET "http://localhost:3000/api/v1/storages/1?sub_storage_page=2&items_page=1" \
  -H "Authorization: Bearer YOUR_JWT_TOKEN"
```

### List Storages within a Space (nested index)
```bash
curl -X GET http://localhost:3000/api/v1/spaces/1/storages \
  -H "Authorization: Bearer YOUR_JWT_TOKEN"
```

### Update Storage
```bash
curl -X PATCH http://localhost:3000/api/v1/storages/1 \
  -H "Authorization: Bearer YOUR_JWT_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "storage": {
      "name": "Updated Pantry Name",
      "description": "New description"
    }
  }'
```

### Delete Storage
```bash
curl -X DELETE http://localhost:3000/api/v1/storages/1 \
  -H "Authorization: Bearer YOUR_JWT_TOKEN"
```

---

## Browse API

Use these minimal endpoints to power the incremental selector (spaces → storages → child storages).

All requests require: `-H "Authorization: Bearer YOUR_JWT_TOKEN"`

### List Spaces (first step)
```bash
curl -X GET http://localhost:3000/api/v1/browse/spaces \
  -H "Authorization: Bearer YOUR_JWT_TOKEN"
```

**Response:**
```json
{
  "status": { "code": 200, "message": "Spaces retrieved successfully." },
  "data": {
    "spaces": [
      { "id": 1, "name": "Kitchen", "description": null, "image_url": null, "has_children": true, "storages_count": 4 }
    ]
  }
}
```

### List Top‑level Storages in a Space
```bash
curl -X GET "http://localhost:3000/api/v1/browse/storages?space_id=1" \
  -H "Authorization: Bearer YOUR_JWT_TOKEN"
```

### List Child Storages under a Storage
```bash
curl -X GET "http://localhost:3000/api/v1/browse/storages?parent_id=10" \
  -H "Authorization: Bearer YOUR_JWT_TOKEN"
```

**Response (for either):**
```json
{
  "status": { "code": 200, "message": "Storages retrieved successfully." },
  "data": {
    "storages": [
      { "id": 10, "name": "Top right cabinet", "space_id": 1, "parent_id": null, "image_url": null, "has_children": true, "children_count": 3 }
    ]
  }
}
```

---

## Items API

### List All Items
```bash
curl -X GET http://localhost:3000/api/v1/items \
  -H "Authorization: Bearer YOUR_JWT_TOKEN"
```

### Filter Items by Storage
```bash
curl -X GET "http://localhost:3000/api/v1/items?storage_id=1" \
  -H "Authorization: Bearer YOUR_JWT_TOKEN"
```

### Get Low Stock Items
```bash
curl -X GET http://localhost:3000/api/v1/items/low_stock \
  -H "Authorization: Bearer YOUR_JWT_TOKEN"
```

**Response:**
```json
{
  "status": { "code": 200, "message": "Low stock items retrieved successfully." },
  "data": {
    "items": [
      {
        "id": 2,
        "name": "Rice",
        "quantity": 3.0,
        "unit": "lbs",
        "min_quantity": 5.0,
        "low_stock": true,
        ...
      }
    ]
  }
}
```

### Create Item

**Basic Item Creation:**
```bash
curl -X POST http://localhost:3000/api/v1/items \
  -H "Authorization: Bearer YOUR_JWT_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "item": {
      "name": "Olive Oil",
      "storage_id": 1,
      "quantity": 32,
      "unit": "oz",
      "min_quantity": 16,
      "expiration_date": "2025-12-31",
      "notes": "Extra virgin"
    }
  }'
```

**Error Response (403) - Limit Reached (Free Plan):**
When a free user tries to create more than 10 items:
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

**Create Item with Existing Categories:**
```bash
curl -X POST http://localhost:3000/api/v1/items \
  -H "Authorization: Bearer YOUR_JWT_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "item": {
      "name": "Olive Oil",
      "storage_id": 1,
      "quantity": 32,
      "unit": "oz",
      "min_quantity": 16,
      "expiration_date": "2025-12-31",
      "notes": "Extra virgin",
      "category_ids": [1, 3]
    }
  }'
```

**Response:**
```json
{
  "status": { "code": 201, "message": "Item created successfully." },
  "data": {
    "item": {
      "id": 1,
      "name": "Olive Oil",
      "quantity": 32.0,
      "unit": "oz",
      "min_quantity": 16.0,
      "expiration_date": "2025-12-31",
      "notes": "Extra virgin",
      "storage_id": 1,
      "storage_name": "Kitchen Pantry",
      "categories": [
        { "id": 1, "name": "Spices" },
        { "id": 3, "name": "Cooking Oils" }
      ],
      "low_stock": false,
      "out_of_stock": false,
      "created_at": "2024-10-11T13:00:00.000Z",
      "updated_at": "2024-10-11T13:00:00.000Z"
    }
  }
}
```

### Get Item Details
```bash
curl -X GET http://localhost:3000/api/v1/items/1 \
  -H "Authorization: Bearer YOUR_JWT_TOKEN"
```

**Response:**
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
- `id` - Item ID
- `name` - Item name
- `quantity` - Current quantity (decimal)
- `unit` - Unit of measurement (required)
- `min_quantity` - Minimum quantity threshold for low stock alerts
- `out_of_stock_threshold` - Threshold for out-of-stock alerts
- `low_stock_alert_enabled` - Whether low stock alerts are enabled
- `out_of_stock_alert_enabled` - Whether out-of-stock alerts are enabled
- `expiration_date` - Expiration date (YYYY-MM-DD format)
- `notes` - Item notes/description
- `storage_id` - ID of the storage containing this item
- `storage_name` - Name of the storage
- `image_url` - URL to the item image (null if no image)
- `location_path` - Breadcrumb string showing full location (e.g., "Kitchen > Pantry > Item")
- `location_array` - Structured array of location hierarchy with type, id, and name
- `categories` - Array of category objects with id and name
- `low_stock` - Boolean indicating if item is below min_quantity
- `out_of_stock` - Boolean indicating if item is below out_of_stock_threshold
- `created_at` - Creation timestamp
- `updated_at` - Last update timestamp

### Update Item (Update Quantity)
```bash
curl -X PATCH http://localhost:3000/api/v1/items/1 \
  -H "Authorization: Bearer YOUR_JWT_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "item": {
      "quantity": 20
    }
  }'
```

### Delete Item
```bash
curl -X DELETE http://localhost:3000/api/v1/items/1 \
  -H "Authorization: Bearer YOUR_JWT_TOKEN"
```

---

## Categories API

**Categories** are tags/labels that can be assigned to items for organization and filtering.

All requests require: `-H "Authorization: Bearer YOUR_JWT_TOKEN"`

### List All Categories
```bash
curl -X GET http://localhost:3000/api/v1/categories \
  -H "Authorization: Bearer YOUR_JWT_TOKEN"
```

**Response:**
```json
{
  "status": { "code": 200, "message": "Categories retrieved successfully." },
  "data": {
    "categories": [
      {
        "id": 1,
        "name": "Spices",
        "items_count": 5,
        "created_at": "2024-10-11T13:00:00.000Z",
        "updated_at": "2024-10-11T13:00:00.000Z"
      },
      {
        "id": 2,
        "name": "Cooking Oils",
        "items_count": 3,
        "created_at": "2024-10-11T13:00:00.000Z",
        "updated_at": "2024-10-11T13:00:00.000Z"
      }
    ]
  }
}
```

### Create Category
```bash
curl -X POST http://localhost:3000/api/v1/categories \
  -H "Authorization: Bearer YOUR_JWT_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "category": {
      "name": "Spices"
    }
  }'
```

**Response:**
```json
{
  "status": { "code": 201, "message": "Category created successfully." },
  "data": {
    "category": {
      "id": 1,
      "name": "Spices",
      "items_count": 0,
      "created_at": "2024-10-11T13:00:00.000Z",
      "updated_at": "2024-10-11T13:00:00.000Z"
    }
  }
}
```

### Get Category Details (with items)
```bash
curl -X GET http://localhost:3000/api/v1/categories/1 \
  -H "Authorization: Bearer YOUR_JWT_TOKEN"
```

**Response:**
```json
{
  "status": { "code": 200, "message": "Category retrieved successfully." },
  "data": {
    "category": {
      "id": 1,
      "name": "Spices",
      "items_count": 2,
      "items": [
        {
          "id": 1,
          "name": "Salt",
          "storage_id": 1,
          "storage_name": "Pantry",
          "quantity": 5.0,
          "unit": "oz"
        },
        {
          "id": 2,
          "name": "Pepper",
          "storage_id": 1,
          "storage_name": "Pantry",
          "quantity": 3.0,
          "unit": "oz"
        }
      ],
      "created_at": "2024-10-11T13:00:00.000Z",
      "updated_at": "2024-10-11T13:00:00.000Z"
    }
  }
}
```

### Update Category
```bash
curl -X PATCH http://localhost:3000/api/v1/categories/1 \
  -H "Authorization: Bearer YOUR_JWT_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "category": {
      "name": "Spices & Herbs"
    }
  }'
```

### Delete Category
```bash
curl -X DELETE http://localhost:3000/api/v1/categories/1 \
  -H "Authorization: Bearer YOUR_JWT_TOKEN"
```

---

## Complete Workflow: Create Item with Categories

### Step 1: Create Categories (if they don't exist)
```bash
# Create "Spices" category
curl -X POST http://localhost:3000/api/v1/categories \
  -H "Authorization: Bearer YOUR_JWT_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "category": {
      "name": "Spices"
    }
  }'
```

**Save the category ID from response (e.g., `id: 1`)**

```bash
# Create "Cooking Oils" category
curl -X POST http://localhost:3000/api/v1/categories \
  -H "Authorization: Bearer YOUR_JWT_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "category": {
      "name": "Cooking Oils"
    }
  }'
```

**Save the category ID from response (e.g., `id: 2`)**

### Step 2: Create Item with Categories
```bash
curl -X POST http://localhost:3000/api/v1/items \
  -H "Authorization: Bearer YOUR_JWT_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "item": {
      "name": "Olive Oil",
      "storage_id": 1,
      "quantity": 32,
      "unit": "oz",
      "min_quantity": 16,
      "expiration_date": "2025-12-31",
      "notes": "Extra virgin olive oil",
      "category_ids": [1, 2]
    }
  }'
```

**Response:**
```json
{
  "status": { "code": 201, "message": "Item created successfully." },
  "data": {
    "item": {
      "id": 1,
      "name": "Olive Oil",
      "quantity": 32.0,
      "unit": "oz",
      "min_quantity": 16.0,
      "expiration_date": "2025-12-31",
      "notes": "Extra virgin olive oil",
      "storage_id": 1,
      "storage_name": "Kitchen Pantry",
      "categories": [
        { "id": 1, "name": "Spices" },
        { "id": 2, "name": "Cooking Oils" }
      ],
      "image_url": null,
      "location_path": "Kitchen > Pantry > Olive Oil",
      "low_stock": false,
      "out_of_stock": false,
      "created_at": "2024-10-11T13:00:00.000Z",
      "updated_at": "2024-10-11T13:00:00.000Z"
    }
  }
}
```

### Step 3: Update Item Categories (Optional)
```bash
# Add more categories to existing item
curl -X PATCH http://localhost:3000/api/v1/items/1 \
  -H "Authorization: Bearer YOUR_JWT_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "item": {
      "category_ids": [1, 2, 3]
    }
  }'
```

**Note:** You can also list all categories first to see which ones exist before creating items.

---

## Move API

Trigger these after the user selects the final destination (deepest storage).

All requests require: `-H "Authorization: Bearer YOUR_JWT_TOKEN"`

### Move Item to Another Storage
```bash
curl -X POST http://localhost:3000/api/v1/items/123/move \
  -H "Authorization: Bearer YOUR_JWT_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "destination_storage_id": 555
  }'
```

### Move Storage
Move under another storage (inherits that storage's space):
```bash
curl -X POST http://localhost:3000/api/v1/storages/42/move \
  -H "Authorization: Bearer YOUR_JWT_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "destination_parent_id": 10
  }'
```

Move to the top level of a space:
```bash
curl -X POST http://localhost:3000/api/v1/storages/42/move \
  -H "Authorization: Bearer YOUR_JWT_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "destination_space_id": 1
  }'
```

**Success Response (example):**
```json
{
  "status": { "code": 200, "message": "Item moved successfully." },
  "data": { /* updated item or storage */ }
}
```

---

## Purchase Sessions API

### List All Purchase Sessions
```bash
curl -X GET http://localhost:3000/api/v1/purchase_sessions \
  -H "Authorization: Bearer YOUR_JWT_TOKEN"
```

**Response:**
```json
{
  "status": { "code": 200, "message": "Purchase sessions retrieved successfully." },
  "data": {
    "purchase_sessions": [
      {
        "id": 1,
        "store_name": "Costco",
        "total_amount": 45.99,
        "purchased_at": "2024-10-11T10:00:00.000Z",
        "notes": "Weekly shopping",
        "items_count": 3,
        "created_at": "2024-10-11T13:00:00.000Z",
        "updated_at": "2024-10-11T13:00:00.000Z"
      }
    ]
  }
}
```

### Create Purchase Session (Simple)
```bash
curl -X POST http://localhost:3000/api/v1/purchase_sessions \
  -H "Authorization: Bearer YOUR_JWT_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "purchase_session": {
      "store_name": "Costco",
      "total_amount": 45.99,
      "purchased_at": "2024-10-11T10:00:00Z",
      "notes": "Weekly grocery shopping"
    }
  }'
```

### Create Purchase Session with Items
```bash
curl -X POST http://localhost:3000/api/v1/purchase_sessions \
  -H "Authorization: Bearer YOUR_JWT_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "purchase_session": {
      "store_name": "Costco",
      "total_amount": 45.99,
      "purchased_at": "2024-10-11T10:00:00Z"
    },
    "purchase_items": [
      {
        "item_id": 1,
        "quantity": 2,
        "unit_price": 12.99
      },
      {
        "item_id": 2,
        "quantity": 1,
        "unit_price": 19.99
      }
    ]
  }'
```

**Response:**
```json
{
  "status": { "code": 201, "message": "Purchase session created successfully." },
  "data": {
    "purchase_session": {
      "id": 1,
      "store_name": "Costco",
      "total_amount": 45.99,
      "purchased_at": "2024-10-11T10:00:00.000Z",
      "notes": null,
      "items_count": 2,
      "items": [
        {
          "id": 1,
          "item_id": 1,
          "item_name": "Olive Oil",
          "quantity": 2.0,
          "unit_price": 12.99,
          "total_price": 25.98
        },
        {
          "id": 2,
          "item_id": 2,
          "item_name": "Rice",
          "quantity": 1.0,
          "unit_price": 19.99,
          "total_price": 19.99
        }
      ],
      "created_at": "2024-10-11T13:00:00.000Z",
      "updated_at": "2024-10-11T13:00:00.000Z"
    }
  }
}
```

### Get Purchase Session Details
```bash
curl -X GET http://localhost:3000/api/v1/purchase_sessions/1 \
  -H "Authorization: Bearer YOUR_JWT_TOKEN"
```

### Update Purchase Session
```bash
curl -X PATCH http://localhost:3000/api/v1/purchase_sessions/1 \
  -H "Authorization: Bearer YOUR_JWT_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "purchase_session": {
      "total_amount": 50.00,
      "notes": "Updated total"
    }
  }'
```

### Delete Purchase Session
```bash
curl -X DELETE http://localhost:3000/api/v1/purchase_sessions/1 \
  -H "Authorization: Bearer YOUR_JWT_TOKEN"
```

---

## Subscription API

### Get Your Subscription
```bash
curl -X GET http://localhost:3000/api/v1/subscription \
  -H "Authorization: Bearer YOUR_JWT_TOKEN"
```

**Response:**
```json
{
  "status": { "code": 200, "message": "Subscription retrieved successfully." },
  "data": {
    "subscription": {
      "id": 1,
      "plan": "free",
      "space_limit": 1,
      "storage_limit": 3,
      "item_limit": 10,
      "started_at": "2024-10-11T13:00:00.000Z",
      "expires_at": null,
      "active": true,
      "created_at": "2024-10-11T13:00:00.000Z",
      "updated_at": "2024-10-11T13:00:00.000Z"
    }
  }
}
```

### Upgrade to Premium
```bash
curl -X PATCH http://localhost:3000/api/v1/subscription \
  -H "Authorization: Bearer YOUR_JWT_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "subscription": {
      "plan": "premium",
      "expires_at": "2025-10-11T00:00:00Z"
    }
  }'
```

**Response:**
```json
{
  "status": { "code": 200, "message": "Subscription updated successfully." },
  "data": {
    "subscription": {
      "id": 1,
      "plan": "premium",
      "space_limit": null,
      "storage_limit": null,
      "item_limit": null,
      "started_at": "2024-10-11T13:00:00.000Z",
      "expires_at": "2025-10-11T00:00:00.000Z",
      "active": true,
      "created_at": "2024-10-11T13:00:00.000Z",
      "updated_at": "2024-10-11T13:05:00.000Z"
    }
  }
}
```

---

## Complete Workflow Example

This example shows setting up a complete bedroom inventory:

### 1. Sign Up
```bash
curl -X POST http://localhost:3000/api/v1/signup \
  -H "Content-Type: application/json" \
  -d '{
    "email": "john@example.com",
    "password": "password123",
    "password_confirmation": "password123"
  }'
```

### 2. Login (Get Token)
```bash
curl -X POST http://localhost:3000/api/v1/login \
  -H "Content-Type: application/json" \
  -d '{
    "user": {
      "email": "john@example.com",
      "password": "password123"
    }
  }'
```

**Save the token from response:**
```json
{
  "data": {
    "token": "eyJhbGciOiJIUzI1NiJ9..."
  }
}
```

### 3. Create a Space (Bedroom)
```bash
TOKEN="eyJhbGciOiJIUzI1NiJ9..."

curl -X POST http://localhost:3000/api/v1/spaces \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "space": {
      "name": "Master Bedroom",
      "space_type": "bedroom"
    }
  }'
```

**Save the space ID from response (e.g., `id: 1`)**

### 4. Create Storages in the Space
```bash
curl -X POST http://localhost:3000/api/v1/storages \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "storage": {
      "name": "Walk-in Closet",
      "space_id": 1
    }
  }'

curl -X POST http://localhost:3000/api/v1/storages \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "storage": {
      "name": "Dresser",
      "space_id": 1
    }
  }'
```

**Save the storage IDs from response (e.g., `id: 1`, `id: 2`)**

### 5. Add Items to Storages
```bash
# Add shirts to closet
curl -X POST http://localhost:3000/api/v1/items \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "item": {
      "name": "Dress Shirts",
      "storage_id": 1,
      "quantity": 8,
      "unit": "pieces",
      "min_quantity": 3
    }
  }'

# Add socks to dresser
curl -X POST http://localhost:3000/api/v1/items \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "item": {
      "name": "White Socks",
      "storage_id": 2,
      "quantity": 12,
      "unit": "pairs",
      "min_quantity": 4
    }
  }'
```

### 6. Record a Purchase
```bash
curl -X POST http://localhost:3000/api/v1/purchase_sessions \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "purchase_session": {
      "store_name": "Costco",
      "total_amount": 45.98,
      "purchased_at": "2024-10-11T14:30:00Z"
    },
    "purchase_items": [
      {
        "item_id": 1,
        "quantity": 1,
        "unit_price": 12.99
      },
      {
        "item_id": 2,
        "quantity": 1,
        "unit_price": 32.99
      }
    ]
  }'
```

### 7. Check Low Stock Items
```bash
curl -X GET http://localhost:3000/api/v1/items/low_stock \
  -H "Authorization: Bearer $TOKEN"
```

### 8. View Your Subscription
```bash
curl -X GET http://localhost:3000/api/v1/subscription \
  -H "Authorization: Bearer $TOKEN"
```

### 9. Logout
```bash
curl -X DELETE http://localhost:3000/api/v1/logout \
  -H "Authorization: Bearer $TOKEN"
```

---

## Error Responses

### 401 Unauthorized (Missing/Invalid Token)
```json
{
  "status": {
    "code": 401,
    "message": "Unauthorized. Please login."
  },
  "errors": ["Invalid or missing authentication token."]
}
```

### 404 Not Found (Resource Doesn't Exist)
```json
{
  "status": {
    "code": 404,
    "message": "Storage not found."
  },
  "errors": ["Storage does not exist or you do not have permission to access it."]
}
```

### 422 Unprocessable Entity (Validation Error)
```json
{
  "status": {
    "code": 422,
    "message": "Item could not be created."
  },
  "errors": [
    "Name can't be blank",
    "Unit can't be blank"
  ]
}
```

---

## Response Format (JSend-like)

All responses follow this format:

### Success (2xx)
```json
{
  "status": {
    "code": 200,
    "message": "Success message"
  },
  "data": {
    // Response data here
  }
}
```

### Error (4xx, 5xx)
```json
{
  "status": {
    "code": 422,
    "message": "Error message"
  },
  "errors": [
    "Error detail 1",
    "Error detail 2"
  ]
}
```

---

## Tips

### Using jq for Pretty Output
```bash
curl -X GET http://localhost:3000/api/v1/items \
  -H "Authorization: Bearer $TOKEN" | jq
```

### Save Token to Environment Variable
```bash
# Login and save token
TOKEN=$(curl -X POST http://localhost:3000/api/v1/login \
  -H "Content-Type: application/json" \
  -d '{"user":{"email":"user@example.com","password":"password123"}}' \
  | jq -r '.data.token')

# Use token
curl -H "Authorization: Bearer $TOKEN" http://localhost:3000/api/v1/storages
```

### Postman Collection
Import these endpoints into Postman:
1. Create an environment variable `base_url` = `http://localhost:3000/api/v1`
2. Create an environment variable `token` = (login to get token)
3. Add `Authorization: Bearer {{token}}` to headers

---

## Rate Limits

Currently, there are **no rate limits** implemented. Consider adding rate limiting for production.

---

## Pagination

Currently, **no pagination** is implemented. All results are returned. For large datasets, consider adding pagination:

```ruby
# Future implementation example
GET /api/v1/items?page=1&per_page=20
```

---

## Additional Resources

- [API_V1_REFERENCE.md](API_V1_REFERENCE.md) - Full API reference
- [MODELS.md](MODELS.md) - Database schema
- [TESTING.md](TESTING.md) - Running tests

