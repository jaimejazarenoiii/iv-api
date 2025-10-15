# Image Upload Guide

This guide explains how to use the image upload features for spaces, storages, and items in the Inventory API.

## Overview

All three main entities (spaces, storages, and items) now support image uploads using Active Storage. Images are optional and can be uploaded, updated, or deleted independently.

## Image Specifications

### Supported Formats
- **JPEG** (.jpg, .jpeg)
- **PNG** (.png)
- **GIF** (.gif)
- **WebP** (.webp)

### File Size Limit
- **Maximum size:** 5MB per image
- Images larger than 5MB will be rejected with validation error

## API Endpoints

### Spaces

#### Upload/Update Space Image
**PATCH** `/api/v1/spaces/:id`

**Request Body (Form Data):**
```
Content-Type: multipart/form-data

space[name]: Kitchen
space[description]: Main kitchen area
space[image]: <file>
```

**Response:**
```json
{
  "status": {
    "code": 200,
    "message": "Space updated successfully."
  },
  "data": {
    "space": {
      "id": 1,
      "name": "Kitchen",
      "space_type": "kitchen",
      "description": "Main kitchen area",
      "image_url": "/rails/active_storage/blobs/.../kitchen.jpg",
      "storages_count": 3,
      "created_at": "2024-10-11T12:00:00.000Z",
      "updated_at": "2024-10-14T15:30:00.000Z"
    }
  }
}
```

#### Delete Space Image
**DELETE** `/api/v1/spaces/:id/image`

**Response:**
```json
{
  "status": {
    "code": 200,
    "message": "Space image deleted successfully."
  },
  "data": {
    "space": {
      "id": 1,
      "name": "Kitchen",
      "space_type": "kitchen",
      "description": "Main kitchen area",
      "image_url": null,
      "storages_count": 3,
      "created_at": "2024-10-11T12:00:00.000Z",
      "updated_at": "2024-10-14T15:35:00.000Z"
    }
  }
}
```

### Storages

#### Upload/Update Storage Image
**PATCH** `/api/v1/storages/:id`

**Request Body (Form Data):**
```
Content-Type: multipart/form-data

storage[name]: Main Fridge
storage[description]: Primary refrigerator
storage[image]: <file>
```

**Response:**
```json
{
  "status": {
    "code": 200,
    "message": "Storage updated successfully."
  },
  "data": {
    "storage": {
      "id": 5,
      "name": "Main Fridge",
      "description": "Primary refrigerator",
      "space_id": 1,
      "space_name": "Kitchen",
      "parent_id": null,
      "image_url": "/rails/active_storage/blobs/.../fridge.jpg",
      "children_count": 2,
      "items_count": 15,
      "created_at": "2024-10-11T12:00:00.000Z",
      "updated_at": "2024-10-14T15:30:00.000Z"
    }
  }
}
```

#### Delete Storage Image
**DELETE** `/api/v1/storages/:id/image`

**Response:**
```json
{
  "status": {
    "code": 200,
    "message": "Storage image deleted successfully."
  },
  "data": {
    "storage": {
      "id": 5,
      "name": "Main Fridge",
      "description": "Primary refrigerator",
      "space_id": 1,
      "space_name": "Kitchen",
      "parent_id": null,
      "image_url": null,
      "children_count": 2,
      "items_count": 15,
      "created_at": "2024-10-11T12:00:00.000Z",
      "updated_at": "2024-10-14T15:35:00.000Z"
    }
  }
}
```

### Items

#### Upload/Update Item Image
**PATCH** `/api/v1/items/:id`

**Request Body (Form Data):**
```
Content-Type: multipart/form-data

item[name]: Organic Milk
item[quantity]: 2.0
item[unit]: liters
item[image]: <file>
```

**Response:**
```json
{
  "status": {
    "code": 200,
    "message": "Item updated successfully."
  },
  "data": {
    "item": {
      "id": 45,
      "name": "Organic Milk",
      "quantity": 2.0,
      "unit": "liters",
      "min_quantity": 1.0,
      "out_of_stock_threshold": 0.5,
      "low_stock_alert_enabled": true,
      "out_of_stock_alert_enabled": true,
      "expiration_date": "2024-10-20",
      "notes": "Organic whole milk",
      "storage_id": 5,
      "storage_name": "Main Fridge",
      "image_url": "/rails/active_storage/blobs/.../milk.jpg",
      "location_path": "Kitchen > Main Fridge > Organic Milk",
      "location_array": [
        { "type": "space", "id": 1, "name": "Kitchen" },
        { "type": "storage", "id": 5, "name": "Main Fridge" },
        { "type": "item", "id": 45, "name": "Organic Milk" }
      ],
      "low_stock": false,
      "out_of_stock": false,
      "created_at": "2024-10-11T12:00:00.000Z",
      "updated_at": "2024-10-14T15:30:00.000Z"
    }
  }
}
```

#### Delete Item Image
**DELETE** `/api/v1/items/:id/image`

**Response:**
```json
{
  "status": {
    "code": 200,
    "message": "Item image deleted successfully."
  },
  "data": {
    "item": {
      "id": 45,
      "name": "Organic Milk",
      "quantity": 2.0,
      "unit": "liters",
      "min_quantity": 1.0,
      "out_of_stock_threshold": 0.5,
      "low_stock_alert_enabled": true,
      "out_of_stock_alert_enabled": true,
      "expiration_date": "2024-10-20",
      "notes": "Organic whole milk",
      "storage_id": 5,
      "storage_name": "Main Fridge",
      "image_url": null,
      "location_path": "Kitchen > Main Fridge > Organic Milk",
      "location_array": [
        { "type": "space", "id": 1, "name": "Kitchen" },
        { "type": "storage", "id": 5, "name": "Main Fridge" },
        { "type": "item", "id": 45, "name": "Organic Milk" }
      ],
      "low_stock": false,
      "out_of_stock": false,
      "created_at": "2024-10-11T12:00:00.000Z",
      "updated_at": "2024-10-14T15:35:00.000Z"
    }
  }
}
```

## Usage Examples

### cURL Examples

#### Upload Space Image
```bash
curl -X PATCH http://localhost:3000/api/v1/spaces/1 \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -F "space[name]=Kitchen" \
  -F "space[description]=Main kitchen area" \
  -F "space[image]=@/path/to/kitchen.jpg"
```

#### Upload Storage Image
```bash
curl -X PATCH http://localhost:3000/api/v1/storages/5 \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -F "storage[name]=Main Fridge" \
  -F "storage[image]=@/path/to/fridge.jpg"
```

#### Upload Item Image
```bash
curl -X PATCH http://localhost:3000/api/v1/items/45 \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -F "item[name]=Organic Milk" \
  -F "item[quantity]=2.0" \
  -F "item[unit]=liters" \
  -F "item[image]=@/path/to/milk.jpg"
```

#### Delete Images
```bash
# Delete space image
curl -X DELETE http://localhost:3000/api/v1/spaces/1/image \
  -H "Authorization: Bearer YOUR_TOKEN"

# Delete storage image
curl -X DELETE http://localhost:3000/api/v1/storages/5/image \
  -H "Authorization: Bearer YOUR_TOKEN"

# Delete item image
curl -X DELETE http://localhost:3000/api/v1/items/45/image \
  -H "Authorization: Bearer YOUR_TOKEN"
```

### JavaScript/Fetch Examples

#### Upload Space Image
```javascript
const formData = new FormData();
formData.append('space[name]', 'Kitchen');
formData.append('space[description]', 'Main kitchen area');
formData.append('space[image]', fileInput.files[0]);

const response = await fetch('http://localhost:3000/api/v1/spaces/1', {
  method: 'PATCH',
  headers: {
    'Authorization': `Bearer ${token}`
  },
  body: formData
});

const data = await response.json();
console.log(data.data.space.image_url);
```

#### Upload Storage Image
```javascript
const formData = new FormData();
formData.append('storage[name]', 'Main Fridge');
formData.append('storage[image]', fileInput.files[0]);

const response = await fetch('http://localhost:3000/api/v1/storages/5', {
  method: 'PATCH',
  headers: {
    'Authorization': `Bearer ${token}`
  },
  body: formData
});

const data = await response.json();
console.log(data.data.storage.image_url);
```

#### Upload Item Image
```javascript
const formData = new FormData();
formData.append('item[name]', 'Organic Milk');
formData.append('item[quantity]', '2.0');
formData.append('item[unit]', 'liters');
formData.append('item[image]', fileInput.files[0]);

const response = await fetch('http://localhost:3000/api/v1/items/45', {
  method: 'PATCH',
  headers: {
    'Authorization': `Bearer ${token}`
  },
  body: formData
});

const data = await response.json();
console.log(data.data.item.image_url);
```

#### Delete Images
```javascript
// Delete space image
const response = await fetch('http://localhost:3000/api/v1/spaces/1/image', {
  method: 'DELETE',
  headers: {
    'Authorization': `Bearer ${token}`
  }
});

const data = await response.json();
console.log(data.data.space.image_url); // null
```

### React Example Component

```jsx
import React, { useState } from 'react';

function ImageUploadComponent({ entityType, entityId, currentImageUrl, token }) {
  const [image, setImage] = useState(null);
  const [uploading, setUploading] = useState(false);

  const handleImageUpload = async (e) => {
    e.preventDefault();
    if (!image) return;

    setUploading(true);
    
    const formData = new FormData();
    formData.append(`${entityType}[image]`, image);

    try {
      const response = await fetch(`http://localhost:3000/api/v1/${entityType}s/${entityId}`, {
        method: 'PATCH',
        headers: {
          'Authorization': `Bearer ${token}`
        },
        body: formData
      });

      if (response.ok) {
        const data = await response.json();
        console.log('Image uploaded:', data.data[entityType].image_url);
        // Update UI with new image URL
      }
    } catch (error) {
      console.error('Upload failed:', error);
    } finally {
      setUploading(false);
    }
  };

  const handleImageDelete = async () => {
    try {
      const response = await fetch(`http://localhost:3000/api/v1/${entityType}s/${entityId}/image`, {
        method: 'DELETE',
        headers: {
          'Authorization': `Bearer ${token}`
        }
      });

      if (response.ok) {
        console.log('Image deleted');
        // Update UI to remove image
      }
    } catch (error) {
      console.error('Delete failed:', error);
    }
  };

  return (
    <div>
      {currentImageUrl && (
        <div>
          <img src={currentImageUrl} alt="Current" style={{ maxWidth: '200px' }} />
          <button onClick={handleImageDelete}>Delete Image</button>
        </div>
      )}
      
      <form onSubmit={handleImageUpload}>
        <input
          type="file"
          accept="image/*"
          onChange={(e) => setImage(e.target.files[0])}
        />
        <button type="submit" disabled={uploading || !image}>
          {uploading ? 'Uploading...' : 'Upload Image'}
        </button>
      </form>
    </div>
  );
}

// Usage
<ImageUploadComponent 
  entityType="space" 
  entityId={1} 
  currentImageUrl={space.image_url}
  token={userToken}
/>
```

## Error Handling

### Image Too Large
```json
{
  "status": {
    "code": 422,
    "message": "Space could not be updated."
  },
  "errors": [
    "Image is too large (maximum is 5MB)"
  ]
}
```

### Invalid File Type
```json
{
  "status": {
    "code": 422,
    "message": "Item could not be updated."
  },
  "errors": [
    "Image must be a JPEG, PNG, GIF, or WebP image"
  ]
}
```

### No Image to Delete
```json
{
  "status": {
    "code": 404,
    "message": "No storage image found."
  },
  "errors": [
    "No storage image to delete."
  ]
}
```

## Image URL Format

Image URLs are returned as relative paths that need to be prefixed with your domain:

```javascript
// Example image URL from API
const imageUrl = "/rails/active_storage/blobs/.../image.jpg";

// Full URL for display
const fullImageUrl = `http://localhost:3000${imageUrl}`;
```

## Best Practices

### Frontend Implementation
1. **File Validation**: Validate file size and type on the frontend before upload
2. **Progress Indicators**: Show upload progress for better UX
3. **Error Handling**: Display clear error messages for validation failures
4. **Image Preview**: Show image preview before upload
5. **Fallback Images**: Use placeholder images when no image is uploaded

### Backend Considerations
1. **Image Processing**: Consider adding image resizing/thumbnails for better performance
2. **CDN Integration**: Use a CDN for serving images in production
3. **Storage Cleanup**: Implement cleanup for orphaned images
4. **Security**: Validate file contents, not just extensions

### Performance Tips
1. **Lazy Loading**: Load images only when needed
2. **Compression**: Compress images before upload
3. **Caching**: Implement proper caching headers for images
4. **Responsive Images**: Serve different sizes for different screen sizes

## Related Documentation

- See [API_V1_REFERENCE.md](API_V1_REFERENCE.md) for complete API documentation
- See [PROFILE_GUIDE.md](PROFILE_GUIDE.md) for profile image uploads
- See [STOCK_ALERTS_GUIDE.md](STOCK_ALERTS_GUIDE.md) for item management
- See [LOCATION_PATH_GUIDE.md](LOCATION_PATH_GUIDE.md) for location tracking

## Notes

- Images are stored using Active Storage
- All image operations require authentication
- Images are automatically deleted when the parent entity is deleted
- Image URLs are relative paths (prefix with your domain for display)
- Only one image per entity (no multiple images support)
- Images are validated on both frontend and backend
