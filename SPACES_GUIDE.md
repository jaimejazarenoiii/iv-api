# Spaces - Multi-Purpose Tracker Guide

## Concept

**Spaces** are the top-level organization for your inventory. This evolves your app from a simple pantry tracker to a **universal things tracker** for your entire home/life!

## Hierarchy

```
Space (Bedroom, Kitchen, Garage, etc.)
  └── Storage (Cabinet, Shelf, Box, etc.)
      └── Item (Clothes, Food, Tools, etc.)
```

## Use Cases

### 🍳 Kitchen
- **Space:** Kitchen
- **Storages:** Pantry, Fridge, Freezer, Cabinet
- **Items:** Food, spices, utensils

### 👔 Bedroom
- **Space:** Bedroom
- **Storages:** Closet, Dresser, Nightstand
- **Items:** Clothes, accessories, personal items

### 🔧 Garage/Basement
- **Space:** Garage
- **Storages:** Tool Cabinet, Storage Box, Shelf
- **Items:** Tools, hardware, seasonal items

### 🏢 Office
- **Space:** Home Office
- **Storages:** Desk Drawer, Filing Cabinet, Bookshelf
- **Items:** Office supplies, documents, electronics

### 🎮 Entertainment
- **Space:** Living Room
- **Storages:** Media Cabinet, Shelf
- **Items:** Games, movies, electronics

---

## Available Space Types

```ruby
Space::SPACE_TYPES = [
  'bedroom',
  'kitchen',
  'bathroom',
  'living_room',
  'dining_room',
  'garage',
  'basement',
  'attic',
  'office',
  'closet',
  'outdoor',
  'storage_unit',
  'other'
]
```

---

## API Endpoints

### List All Spaces
```bash
GET /api/v1/spaces
```

**Example:**
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
POST /api/v1/spaces
```

**Example:**
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

### Get Space Details (with storages)
```bash
GET /api/v1/spaces/:id
```

**Example:**
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
        {
          "id": 1,
          "name": "Pantry",
          "items_count": 15
        },
        {
          "id": 2,
          "name": "Fridge",
          "items_count": 8
        },
        {
          "id": 3,
          "name": "Freezer",
          "items_count": 12
        }
      ],
      "created_at": "2024-10-11T13:00:00.000Z",
      "updated_at": "2024-10-11T13:00:00.000Z"
    }
  }
}
```

### Update Space
```bash
PATCH /api/v1/spaces/:id
```

**Example:**
```bash
curl -X PATCH http://localhost:3000/api/v1/spaces/1 \
  -H "Authorization: Bearer YOUR_JWT_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "space": {
      "description": "Updated description"
    }
  }'
```

### Delete Space
```bash
DELETE /api/v1/spaces/:id
```

**Example:**
```bash
curl -X DELETE http://localhost:3000/api/v1/spaces/1 \
  -H "Authorization: Bearer YOUR_JWT_TOKEN"
```

**Note:** This will also delete all storages and items in this space!

---

## Complete Workflow Example

### 1. Create a Space (Bedroom)
```bash
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
**Save the space ID (e.g., `id: 1`)**

### 2. Create Storages in that Space
```bash
# Create closet
curl -X POST http://localhost:3000/api/v1/storages \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "storage": {
      "name": "Walk-in Closet",
      "space_id": 1
    }
  }'

# Create dresser
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

### 3. Add Items to Storages
```bash
# Add shirts to closet
curl -X POST http://localhost:3000/api/v1/items \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "item": {
      "name": "Blue Shirts",
      "storage_id": 1,
      "quantity": 5,
      "unit": "pieces",
      "min_quantity": 2
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
      "quantity": 10,
      "unit": "pairs",
      "min_quantity": 3
    }
  }'
```

### 4. View Everything in the Space
```bash
curl -X GET http://localhost:3000/api/v1/spaces/1 \
  -H "Authorization: Bearer $TOKEN"
```

---

## Real-World Examples

### Example 1: Track Tools in Garage

```bash
# Create garage space
POST /api/v1/spaces
{
  "space": {
    "name": "Garage Workshop",
    "space_type": "garage"
  }
}

# Create tool cabinet
POST /api/v1/storages
{
  "storage": {
    "name": "Tool Cabinet",
    "space_id": 1
  }
}

# Add tools
POST /api/v1/items
{
  "item": {
    "name": "Screwdriver Set",
    "storage_id": 1,
    "quantity": 1,
    "unit": "set",
    "notes": "Phillips and flathead, red handle"
  }
}
```

### Example 2: Track Clothes in Bedroom

```bash
# Create bedroom space
POST /api/v1/spaces
{
  "space": {
    "name": "Master Bedroom",
    "space_type": "bedroom"
  }
}

# Create closet
POST /api/v1/storages
{
  "storage": {
    "name": "Main Closet",
    "space_id": 1
  }
}

# Add clothes
POST /api/v1/items
{
  "item": {
    "name": "Winter Jackets",
    "storage_id": 1,
    "quantity": 3,
    "unit": "pieces",
    "min_quantity": 1
  }
}
```

### Example 3: Track Seasonal Items in Basement

```bash
# Create basement space
POST /api/v1/spaces
{
  "space": {
    "name": "Basement Storage",
    "space_type": "basement"
  }
}

# Create storage boxes
POST /api/v1/storages
{
  "storage": {
    "name": "Christmas Decorations Box",
    "space_id": 1
  }
}

# Add decorations
POST /api/v1/items
{
  "item": {
    "name": "String Lights",
    "storage_id": 1,
    "quantity": 5,
    "unit": "sets"
  }
}
```

---

## Updated Data Model

```
User
├── Spaces (NEW!)
│   └── Storages
│       └── Items
├── Items (direct access)
├── Purchase Sessions
└── Subscription
```

### Benefits

✅ **Better Organization** - Group storages by physical location
✅ **Flexibility** - Track anything, anywhere
✅ **Scalability** - Easily add new rooms/areas
✅ **Search/Filter** - Find items by space type (all bedroom items, all garage items)
✅ **Reporting** - See inventory breakdown by space

---

## Migration Path

### For Existing Storages (without space)
Storages can exist without a space (optional relationship):

```ruby
# Storage with space
Storage.create(name: "Pantry", space_id: 1)

# Storage without space (legacy support)
Storage.create(name: "Misc Storage")
```

### Adding Spaces to Existing Data

```bash
# 1. Create spaces
curl -X POST /api/v1/spaces \
  -H "Authorization: Bearer $TOKEN" \
  -d '{"space":{"name":"Kitchen","space_type":"kitchen"}}'

# 2. Update existing storages
curl -X PATCH /api/v1/storages/1 \
  -H "Authorization: Bearer $TOKEN" \
  -d '{"storage":{"space_id":1}}'
```

---

## Best Practices

### Naming Conventions
- **Space Name:** Physical location (Kitchen, Master Bedroom, Garage)
- **Storage Name:** Container/furniture (Pantry, Closet, Tool Box)
- **Item Name:** The actual thing (Olive Oil, Blue Shirt, Screwdriver)

### Organization Tips
1. Start with spaces (rooms/areas)
2. Add storages within each space
3. Then add items to storages
4. Use `space_type` for filtering/reporting

### For Food Tracking
```
Space: Kitchen (space_type: kitchen)
  Storage: Pantry
    Items: Dry goods, canned food
  Storage: Fridge
    Items: Perishables
  Storage: Freezer
    Items: Frozen foods
```

### For Clothing Tracking
```
Space: Bedroom (space_type: bedroom)
  Storage: Closet
    Items: Hanging clothes, shoes
  Storage: Dresser
    Items: Folded clothes, underwear
```

### For Tools Tracking
```
Space: Garage (space_type: garage)
  Storage: Tool Cabinet
    Items: Hand tools, power tools
  Storage: Workbench
    Items: Hardware, supplies
```

---

## Future Enhancements

Possible features to add:
- [ ] Floor plans / location mapping
- [ ] QR code labels for spaces/storages
- [ ] Photo attachments
- [ ] Space templates (quick setup for common rooms)
- [ ] Analytics (most used spaces, item distribution)
- [ ] Sharing spaces with family members
- [ ] Moving checklist (track items when relocating)

---

## Summary

With **Spaces**, your app can now track:
- 🍳 Food in the kitchen
- 👔 Clothes in the bedroom
- 🔧 Tools in the garage
- 📚 Books in the office
- 🎮 Games in the living room
- 🎄 Seasonal items in the basement
- ...and **anything else** in your home!

Your inventory tracker is now **universal**! 🎉


