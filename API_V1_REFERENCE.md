# API v1.0 Reference

**Base URL:** `http://localhost:3000/api/v1`

## Authentication Endpoints

All authentication endpoints are under `/api/v1`

### Sign Up

**Endpoint:** `POST /api/v1/signup`

**Request Body:**
```json
{
  "user": {
    "email": "user@example.com",
    "password": "password123",
    "password_confirmation": "password123"
  }
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
- When you sign up, a free subscription is automatically created with a limit of 10 pantries.
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
    "user": {
      "email": "test@example.com",
      "password": "password123",
      "password_confirmation": "password123"
    }
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

## Resource Endpoints (Coming Soon)

The following endpoints will be available for managing your pantry:

### Storages
- `GET /api/v1/storages` - List all your storage locations
- `POST /api/v1/storages` - Create a new storage location
- `GET /api/v1/storages/:id` - Get storage details
- `PATCH /api/v1/storages/:id` - Update a storage
- `DELETE /api/v1/storages/:id` - Delete a storage

### Items
- `GET /api/v1/items` - List all your items
- `POST /api/v1/items` - Add a new item
- `GET /api/v1/items/:id` - Get item details
- `PATCH /api/v1/items/:id` - Update an item
- `DELETE /api/v1/items/:id` - Delete an item
- `GET /api/v1/items/low_stock` - Get items below minimum quantity

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

