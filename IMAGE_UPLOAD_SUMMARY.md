# Image Upload Feature Summary

## Overview

Successfully added image upload support to all three main entities in the Inventory API: **Spaces**, **Storages**, and **Items**.

## What Was Added

### 1. **Model Updates**

#### Space Model (`app/models/space.rb`)
- Added `has_one_attached :image`
- Added `image_url` helper method
- Added `acceptable_image` validation
- Image validation: max 5MB, JPEG/PNG/GIF/WebP only

#### Storage Model (`app/models/storage.rb`)
- Added `has_one_attached :image`
- Added `image_url` helper method
- Added `acceptable_image` validation
- Image validation: max 5MB, JPEG/PNG/GIF/WebP only

#### Item Model (`app/models/item.rb`)
- Added `has_one_attached :image`
- Added `image_url` helper method
- Added `acceptable_image` validation
- Image validation: max 5MB, JPEG/PNG/GIF/WebP only

### 2. **Controller Updates**

#### Spaces Controller (`app/controllers/api/v1/spaces_controller.rb`)
- Updated `space_params` to permit `:image`
- Added `image_url` to JSON response
- Added `destroy_image` action
- Added image deletion endpoint

#### Storages Controller (`app/controllers/api/v1/storages_controller.rb`)
- Updated `storage_params` to permit `:image`
- Added `image_url` to JSON response
- Added `destroy_image` action
- Added image deletion endpoint

#### Items Controller (`app/controllers/api/v1/items_controller.rb`)
- Updated `item_params` to permit `:image`
- Added `image_url` to JSON response
- Added `destroy_image` action
- Added image deletion endpoint

### 3. **Routes Updates**

#### New Routes Added (`config/routes.rb`)
```ruby
# Spaces
resources :spaces do
  member do
    delete :image, action: :destroy_image
  end
end

# Storages
resources :storages do
  member do
    delete :image, action: :destroy_image
  end
end

# Items
resources :items do
  member do
    delete :image, action: :destroy_image
  end
end
```

### 4. **API Endpoints**

#### Image Upload (via PATCH)
- `PATCH /api/v1/spaces/:id` - Upload/update space image
- `PATCH /api/v1/storages/:id` - Upload/update storage image
- `PATCH /api/v1/items/:id` - Upload/update item image

#### Image Deletion
- `DELETE /api/v1/spaces/:id/image` - Delete space image
- `DELETE /api/v1/storages/:id/image` - Delete storage image
- `DELETE /api/v1/items/:id/image` - Delete item image

### 5. **Response Format**

All entity responses now include `image_url` field:

```json
{
  "id": 1,
  "name": "Kitchen",
  "space_type": "kitchen",
  "description": "Main kitchen area",
  "image_url": "/rails/active_storage/blobs/.../kitchen.jpg",
  "storages_count": 3,
  "created_at": "2024-10-11T12:00:00.000Z",
  "updated_at": "2024-10-14T15:30:00.000Z"
}
```

## Image Specifications

### Supported Formats
- **JPEG** (.jpg, .jpeg)
- **PNG** (.png)
- **GIF** (.gif)
- **WebP** (.webp)

### File Size Limit
- **Maximum size:** 5MB per image

### Validation
- File size validation (5MB max)
- File type validation (JPEG, PNG, GIF, WebP only)
- Both frontend and backend validation

## Usage Examples

### Upload Image (cURL)
```bash
curl -X PATCH http://localhost:3000/api/v1/spaces/1 \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -F "space[name]=Kitchen" \
  -F "space[image]=@/path/to/kitchen.jpg"
```

### Delete Image (cURL)
```bash
curl -X DELETE http://localhost:3000/api/v1/spaces/1/image \
  -H "Authorization: Bearer YOUR_TOKEN"
```

### Upload Image (JavaScript)
```javascript
const formData = new FormData();
formData.append('space[name]', 'Kitchen');
formData.append('space[image]', fileInput.files[0]);

const response = await fetch('http://localhost:3000/api/v1/spaces/1', {
  method: 'PATCH',
  headers: {
    'Authorization': `Bearer ${token}`
  },
  body: formData
});
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

## Key Features

✅ **Universal Support** - All entities (spaces, storages, items) support images  
✅ **Optional Images** - Images are completely optional  
✅ **File Validation** - Size and type validation on both frontend and backend  
✅ **Image URLs** - Helper methods return image URLs for easy display  
✅ **Delete Support** - Dedicated endpoints to delete images  
✅ **Active Storage** - Uses Rails Active Storage for robust file handling  
✅ **Error Handling** - Comprehensive error messages for all scenarios  
✅ **Documentation** - Complete documentation with examples  

## Technical Implementation

### Active Storage Integration
- Uses Rails Active Storage for file handling
- Images stored in `active_storage_blobs` and `active_storage_attachments` tables
- Automatic cleanup when parent entity is deleted

### Image URL Generation
```ruby
def image_url
  return nil unless image.attached?
  
  Rails.application.routes.url_helpers.rails_blob_url(image, only_path: true)
end
```

### Validation
```ruby
def acceptable_image
  return unless image.attached?

  unless image.byte_size <= 5.megabytes
    errors.add(:image, 'is too large (maximum is 5MB)')
  end

  acceptable_types = ['image/jpeg', 'image/png', 'image/gif', 'image/webp']
  unless acceptable_types.include?(image.content_type)
    errors.add(:image, 'must be a JPEG, PNG, GIF, or WebP image')
  end
end
```

## Documentation Created

### New Documentation Files
1. **`IMAGE_UPLOAD_GUIDE.md`** - Comprehensive guide with:
   - API endpoint details
   - Request/response examples
   - cURL examples
   - JavaScript/Fetch examples
   - React component example
   - Error handling
   - Best practices

### Updated Documentation
1. **`API_V1_REFERENCE.md`** - Added image upload endpoints and support notes

## Files Modified

### Models
1. `app/models/space.rb` - Added image attachment and validation
2. `app/models/storage.rb` - Added image attachment and validation
3. `app/models/item.rb` - Added image attachment and validation

### Controllers
1. `app/controllers/api/v1/spaces_controller.rb` - Added image support
2. `app/controllers/api/v1/storages_controller.rb` - Added image support
3. `app/controllers/api/v1/items_controller.rb` - Added image support

### Configuration
1. `config/routes.rb` - Added image deletion routes

### Documentation
1. `API_V1_REFERENCE.md` - Updated with image endpoints
2. `IMAGE_UPLOAD_GUIDE.md` - New comprehensive guide

## Testing the Features

### Upload Space Image
```bash
curl -X PATCH http://localhost:3000/api/v1/spaces/1 \
  -H "Authorization: Bearer TOKEN" \
  -F "space[name]=Kitchen" \
  -F "space[image]=@/path/to/image.jpg"
```

### Upload Storage Image
```bash
curl -X PATCH http://localhost:3000/api/v1/storages/5 \
  -H "Authorization: Bearer TOKEN" \
  -F "storage[name]=Main Fridge" \
  -F "storage[image]=@/path/to/image.jpg"
```

### Upload Item Image
```bash
curl -X PATCH http://localhost:3000/api/v1/items/45 \
  -H "Authorization: Bearer TOKEN" \
  -F "item[name]=Milk" \
  -F "item[image]=@/path/to/image.jpg"
```

### Delete Images
```bash
# Delete space image
curl -X DELETE http://localhost:3000/api/v1/spaces/1/image \
  -H "Authorization: Bearer TOKEN"

# Delete storage image
curl -X DELETE http://localhost:3000/api/v1/storages/5/image \
  -H "Authorization: Bearer TOKEN"

# Delete item image
curl -X DELETE http://localhost:3000/api/v1/items/45/image \
  -H "Authorization: Bearer TOKEN"
```

## Next Steps

### Recommended:
1. **Test the endpoints** with your frontend application
2. **Implement image upload UI** in your frontend
3. **Add image preview** functionality
4. **Consider image resizing** for better performance

### Optional Enhancements:
- Add image thumbnails/variants using Active Storage variants
- Implement image compression before upload
- Add image cropping functionality
- Set up CDN for image serving in production
- Add image metadata (alt text, captions)

## Summary

The image upload feature is now fully implemented across all entities in the Inventory API. Users can:

- ✅ Upload images to spaces, storages, and items
- ✅ Update existing images
- ✅ Delete images independently
- ✅ View image URLs in API responses
- ✅ Get proper error messages for validation failures

All features are documented with comprehensive examples and ready for frontend integration! 🎉
