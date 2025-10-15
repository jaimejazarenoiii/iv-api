# Profile Feature Summary

## What Was Added

This document summarizes the user profile feature that was added to the Inventory API.

## Database Changes

### New Migrations
1. **`20241011000012_add_profile_fields_to_users.rb`** - Added profile fields to users table
   - `first_name` (string, 50 chars)
   - `last_name` (string, 50 chars)
   - `middle_name` (string, 50 chars)
   - `gender` (string, 20 chars)

2. **Active Storage Migration** - Installed Active Storage for profile image uploads
   - `active_storage_blobs` table
   - `active_storage_attachments` table
   - `active_storage_variant_records` table

## Code Changes

### User Model (`app/models/user.rb`)
**Added:**
- Active Storage attachment: `has_one_attached :profile_image`
- Validations for all new fields
- Gender validation (must be: `male`, `female`, `other`, `prefer_not_to_say`)
- Image validation (max 5MB, only JPEG/PNG/GIF/WebP)
- Helper method `full_name` - combines first, middle, last names
- Helper method `profile_image_url` - returns image URL or nil

### Profile Controller (`app/controllers/api/v1/profile_controller.rb`)
**New controller with endpoints:**
- `GET /api/v1/profile` - Get current user's profile
- `PATCH /api/v1/profile` - Update profile (all fields optional)
- `DELETE /api/v1/profile/image` - Delete profile image

**Features:**
- Requires authentication
- Accepts JSON or multipart form data
- Returns profile data with image URL
- Proper error handling

### Routes (`config/routes.rb`)
**Added:**
```ruby
resource :profile, only: [:show, :update] do
  delete :image, action: :destroy_image
end
```

### Tests (`test/controllers/api/v1/profile_controller_test.rb`)
**Test coverage for:**
- Getting profile (authenticated/unauthenticated)
- Updating profile fields
- Partial updates
- Invalid gender validation
- Image upload
- Image deletion
- Error cases

### Test Fixtures
- Created `test/fixtures/files/test_image.jpg` for testing image uploads

## API Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/v1/profile` | Get current user's profile |
| PATCH | `/api/v1/profile` | Update profile fields |
| DELETE | `/api/v1/profile/image` | Delete profile image |

## Profile Data Structure

```json
{
  "id": 1,
  "email": "user@example.com",
  "first_name": "John",
  "last_name": "Doe",
  "middle_name": "Michael",
  "full_name": "John Michael Doe",
  "gender": "male",
  "profile_image_url": "/rails/active_storage/blobs/.../profile.jpg",
  "created_at": "2024-10-11T12:00:00.000Z",
  "updated_at": "2024-10-14T15:30:00.000Z"
}
```

## Validation Rules

| Field | Rules |
|-------|-------|
| `first_name` | Optional, max 50 chars |
| `last_name` | Optional, max 50 chars |
| `middle_name` | Optional, max 50 chars |
| `gender` | Optional, must be: `male`, `female`, `other`, `prefer_not_to_say` |
| `profile_image` | Optional, max 5MB, JPEG/PNG/GIF/WebP only |

## Documentation

### New Documentation Files
1. **`PROFILE_GUIDE.md`** - Comprehensive guide with:
   - API endpoint details
   - Request/response examples
   - cURL examples
   - JavaScript/Fetch examples
   - React component example
   - Validation rules
   - Error handling

### Updated Documentation
1. **`API_V1_REFERENCE.md`** - Added Profile section to resource endpoints

## Key Features

✅ **Separate from Registration** - Profile fields are not required during signup  
✅ **Optional Fields** - All profile fields are optional and can be updated independently  
✅ **Image Upload** - Supports profile image with validation  
✅ **Image Management** - Can upload and delete images separately  
✅ **Full Name Helper** - Automatically combines name fields or falls back to email  
✅ **Flexible Updates** - Can update one field or multiple fields at once  
✅ **Form Data Support** - Accepts both JSON and multipart form data  
✅ **Proper Validation** - File size, type, and field validations  
✅ **Test Coverage** - Comprehensive tests for all endpoints  
✅ **Error Handling** - Clear error messages for validation failures  

## Usage Example

### Update Profile with Image

```bash
curl -X PATCH http://localhost:3000/api/v1/profile \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -F "profile[first_name]=John" \
  -F "profile[last_name]=Doe" \
  -F "profile[gender]=male" \
  -F "profile[profile_image]=@/path/to/photo.jpg"
```

### Update Profile (JSON)

```bash
curl -X PATCH http://localhost:3000/api/v1/profile \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "profile": {
      "first_name": "Jane",
      "last_name": "Smith"
    }
  }'
```

## Notes

- Profile updates are separate from user registration
- All fields remain optional
- Email cannot be changed via profile endpoint (managed by Devise)
- Profile images are stored using Active Storage
- Images are validated for size (5MB max) and type
- Full name falls back to email if no name fields are set
- Profile endpoint requires authentication

## Related Files

- Model: `app/models/user.rb`
- Controller: `app/controllers/api/v1/profile_controller.rb`
- Routes: `config/routes.rb`
- Tests: `test/controllers/api/v1/profile_controller_test.rb`
- Migrations:
  - `db/migrate/20241011000012_add_profile_fields_to_users.rb`
  - `db/migrate/20251014135614_create_active_storage_tables.rb`
- Documentation:
  - `PROFILE_GUIDE.md`
  - `API_V1_REFERENCE.md`

