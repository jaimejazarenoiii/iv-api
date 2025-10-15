# Location Path Guide

This guide explains how to use the location path feature to easily track where items are stored in your inventory hierarchy.

## Overview

Items now include location path helpers that trace the full hierarchy from Space → Storage → Sub-storage → Item, making it easy to see exactly where each item is located.

## Helper Methods

### `location_path`
Returns a human-readable string showing the full location path.

**Example Output:**
```
"Kitchen > Main Fridge > Freezer Drawer > Ice Cream"
```

**Structure:**
```
Space > Storage > Sub-storage > Sub-sub-storage > ... > Item Name
```

### `location_array`
Returns a structured array of objects representing each level of the hierarchy, useful for building breadcrumbs or navigation in your frontend.

**Example Output:**
```json
[
  { "type": "space", "id": 1, "name": "Kitchen" },
  { "type": "storage", "id": 5, "name": "Main Fridge" },
  { "type": "storage", "id": 12, "name": "Freezer Drawer" },
  { "type": "item", "id": 45, "name": "Ice Cream" }
]
```

## API Response

All item endpoints now include both location formats in the response:

```json
{
  "id": 45,
  "name": "Ice Cream",
  "quantity": 2.0,
  "unit": "pints",
  "storage_id": 12,
  "storage_name": "Freezer Drawer",
  "location_path": "Kitchen > Main Fridge > Freezer Drawer > Ice Cream",
  "location_array": [
    { "type": "space", "id": 1, "name": "Kitchen" },
    { "type": "storage", "id": 5, "name": "Main Fridge" },
    { "type": "storage", "id": 12, "name": "Freezer Drawer" },
    { "type": "item", "id": 45, "name": "Ice Cream" }
  ],
  "low_stock": false,
  "out_of_stock": false,
  "created_at": "2024-10-11T12:00:00.000Z",
  "updated_at": "2024-10-11T12:00:00.000Z"
}
```

## Usage Examples

### Example 1: Simple Storage (No Sub-storages)

**Hierarchy:**
- Space: "Garage"
- Storage: "Tool Cabinet"
- Item: "Hammer"

**Response:**
```json
{
  "location_path": "Garage > Tool Cabinet > Hammer",
  "location_array": [
    { "type": "space", "id": 2, "name": "Garage" },
    { "type": "storage", "id": 8, "name": "Tool Cabinet" },
    { "type": "item", "id": 23, "name": "Hammer" }
  ]
}
```

### Example 2: Nested Storage

**Hierarchy:**
- Space: "Bedroom"
- Storage: "Walk-in Closet"
- Sub-storage: "Upper Shelf"
- Sub-sub-storage: "Storage Box #3"
- Item: "Winter Gloves"

**Response:**
```json
{
  "location_path": "Bedroom > Walk-in Closet > Upper Shelf > Storage Box #3 > Winter Gloves",
  "location_array": [
    { "type": "space", "id": 3, "name": "Bedroom" },
    { "type": "storage", "id": 10, "name": "Walk-in Closet" },
    { "type": "storage", "id": 15, "name": "Upper Shelf" },
    { "type": "storage", "id": 20, "name": "Storage Box #3" },
    { "type": "item", "id": 67, "name": "Winter Gloves" }
  ]
}
```

### Example 3: Storage Without Space

**Hierarchy:**
- Storage: "Portable Toolbox" (no parent space)
- Item: "Screwdriver Set"

**Response:**
```json
{
  "location_path": "Portable Toolbox > Screwdriver Set",
  "location_array": [
    { "type": "storage", "id": 25, "name": "Portable Toolbox" },
    { "type": "item", "id": 89, "name": "Screwdriver Set" }
  ]
}
```

## Frontend Integration Examples

### Display Location Path (Simple)
```javascript
// Simple text display
const itemLocation = item.location_path;
// "Kitchen > Main Fridge > Freezer Drawer > Ice Cream"
```

### Build Breadcrumb Navigation
```javascript
// Using location_array for breadcrumbs
const breadcrumbs = item.location_array.map((segment, index) => {
  const isLast = index === item.location_array.length - 1;
  
  return (
    <span key={`${segment.type}-${segment.id}`}>
      {segment.type !== 'item' ? (
        <a href={`/${segment.type}s/${segment.id}`}>
          {segment.name}
        </a>
      ) : (
        <strong>{segment.name}</strong>
      )}
      {!isLast && ' > '}
    </span>
  );
});
```

### Filter by Location
```javascript
// Filter items by a specific space
const kitchenItems = items.filter(item => 
  item.location_array.some(segment => 
    segment.type === 'space' && segment.id === kitchenSpaceId
  )
);

// Find items in a specific storage
const fridgeItems = items.filter(item =>
  item.location_array.some(segment =>
    segment.type === 'storage' && segment.id === fridgeStorageId
  )
);
```

### Group Items by Location
```javascript
// Group items by their top-level space
const itemsBySpace = items.reduce((acc, item) => {
  const space = item.location_array.find(seg => seg.type === 'space');
  const spaceName = space ? space.name : 'No Space';
  
  if (!acc[spaceName]) {
    acc[spaceName] = [];
  }
  acc[spaceName].push(item);
  
  return acc;
}, {});
```

## Benefits

1. **Easy Navigation**: Users can quickly see where items are stored
2. **Breadcrumb Support**: The array format is perfect for building navigation breadcrumbs
3. **Search & Filter**: Easy to filter items by space or storage location
4. **Data Consistency**: Always shows the complete hierarchy regardless of nesting depth
5. **Frontend Flexibility**: Two formats (string and array) for different use cases

## Notes

- The location path is computed on-the-fly, not stored in the database
- The hierarchy is built by recursively traversing parent storages
- Storages without a space will start directly with the storage name
- The item's name is always the last element in the path
- Each segment in `location_array` includes `type`, `id`, and `name` for easy linking

## Performance Considerations

- The location path is calculated on each request
- For large lists, consider caching if performance becomes an issue
- The method uses efficient traversal (no N+1 queries if you properly eager-load associations)

## Related Documentation

- See [SPACES_GUIDE.md](SPACES_GUIDE.md) for information on managing spaces
- See [API_V1_REFERENCE.md](API_V1_REFERENCE.md) for complete API documentation

