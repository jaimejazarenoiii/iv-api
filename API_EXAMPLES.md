# API v1.0 - Usage Examples

Complete examples for all API endpoints.

## Table of Contents
- [Authentication](#authentication)
- [Spaces API](#spaces-api) 🆕
- [Storages API](#storages-api)
- [Items API](#items-api)
- [Purchase Sessions API](#purchase-sessions-api)
- [Subscription API](#subscription-api)

---

## Authentication

### Sign Up
```bash
curl -X POST http://localhost:3000/api/v1/signup \
  -H "Content-Type: application/json" \
  -d '{
    "user": {
      "email": "user@example.com",
      "password": "password123",
      "password_confirmation": "password123"
    }
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

### Get Storage Details
```bash
curl -X GET http://localhost:3000/api/v1/storages/1 \
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
      "low_stock": false,
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
      "pantry_limit": 10,
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
      "pantry_limit": null,
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
    "user": {
      "email": "john@example.com",
      "password": "password123",
      "password_confirmation": "password123"
    }
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

