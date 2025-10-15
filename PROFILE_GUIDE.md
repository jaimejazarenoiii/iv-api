# User Profile Guide

This guide explains how to use the user profile features including profile information and image upload.

## Overview

Users can manage their profile information separately from registration. All profile fields are optional and can be updated on a dedicated profile page.

## Profile Fields

### Text Fields
- **`first_name`** (string, max 50 chars, optional)
- **`last_name`** (string, max 50 chars, optional)
- **`middle_name`** (string, max 50 chars, optional)
- **`gender`** (string, optional) - Must be one of: `male`, `female`, `other`, `prefer_not_to_say`

### Image Upload
- **`profile_image`** (file upload, optional)
  - Supported formats: JPEG, PNG, GIF, WebP
  - Maximum size: 5MB
  - Stored using Active Storage

## API Endpoints

### Get Profile
**GET** `/api/v1/profile`

Retrieves the authenticated user's profile information.

**Headers:**
```
Authorization: Bearer <jwt_token>
```

**Response:**
```json
{
  "status": {
    "code": 200,
    "message": "Profile retrieved successfully."
  },
  "data": {
    "profile": {
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
  }
}
```

### Update Profile
**PATCH/PUT** `/api/v1/profile`

Updates the authenticated user's profile information.

**Headers:**
```
Authorization: Bearer <jwt_token>
Content-Type: application/json
```

**Request Body (JSON):**
```json
{
  "profile": {
    "first_name": "Jane",
    "last_name": "Smith",
    "middle_name": "Marie",
    "gender": "female"
  }
}
```

**Request Body (Form Data with Image):**
```
Content-Type: multipart/form-data

profile[first_name]: Jane
profile[last_name]: Smith
profile[middle_name]: Marie
profile[gender]: female
profile[profile_image]: <file>
```

**Response:**
```json
{
  "status": {
    "code": 200,
    "message": "Profile updated successfully."
  },
  "data": {
    "profile": {
      "id": 1,
      "email": "user@example.com",
      "first_name": "Jane",
      "last_name": "Smith",
      "middle_name": "Marie",
      "full_name": "Jane Marie Smith",
      "gender": "female",
      "profile_image_url": "/rails/active_storage/blobs/.../profile.jpg",
      "created_at": "2024-10-11T12:00:00.000Z",
      "updated_at": "2024-10-14T15:35:00.000Z"
    }
  }
}
```

**Error Response (Invalid Gender):**
```json
{
  "status": {
    "code": 422,
    "message": "Profile could not be updated."
  },
  "errors": [
    "Gender is not included in the list"
  ]
}
```

**Error Response (Image Too Large):**
```json
{
  "status": {
    "code": 422,
    "message": "Profile could not be updated."
  },
  "errors": [
    "Profile image is too large (maximum is 5MB)"
  ]
}
```

### Delete Profile Image
**DELETE** `/api/v1/profile/image`

Deletes the authenticated user's profile image.

**Headers:**
```
Authorization: Bearer <jwt_token>
```

**Response:**
```json
{
  "status": {
    "code": 200,
    "message": "Profile image deleted successfully."
  },
  "data": {
    "profile": {
      "id": 1,
      "email": "user@example.com",
      "first_name": "Jane",
      "last_name": "Smith",
      "middle_name": "Marie",
      "full_name": "Jane Marie Smith",
      "gender": "female",
      "profile_image_url": null,
      "created_at": "2024-10-11T12:00:00.000Z",
      "updated_at": "2024-10-14T15:40:00.000Z"
    }
  }
}
```

**Error Response (No Image):**
```json
{
  "status": {
    "code": 404,
    "message": "No profile image found."
  },
  "errors": [
    "No profile image to delete."
  ]
}
```

## Usage Examples

### Update Profile with cURL

**Update text fields only:**
```bash
curl -X PATCH http://localhost:3000/api/v1/profile \
  -H "Authorization: Bearer YOUR_JWT_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "profile": {
      "first_name": "John",
      "last_name": "Doe",
      "gender": "male"
    }
  }'
```

**Update with image upload:**
```bash
curl -X PATCH http://localhost:3000/api/v1/profile \
  -H "Authorization: Bearer YOUR_JWT_TOKEN" \
  -F "profile[first_name]=John" \
  -F "profile[last_name]=Doe" \
  -F "profile[gender]=male" \
  -F "profile[profile_image]=@/path/to/image.jpg"
```

**Delete profile image:**
```bash
curl -X DELETE http://localhost:3000/api/v1/profile/image \
  -H "Authorization: Bearer YOUR_JWT_TOKEN"
```

### Frontend Integration (JavaScript/Fetch)

**Get Profile:**
```javascript
const response = await fetch('http://localhost:3000/api/v1/profile', {
  headers: {
    'Authorization': `Bearer ${token}`,
    'Content-Type': 'application/json'
  }
});

const data = await response.json();
console.log(data.data.profile);
```

**Update Profile (JSON):**
```javascript
const response = await fetch('http://localhost:3000/api/v1/profile', {
  method: 'PATCH',
  headers: {
    'Authorization': `Bearer ${token}`,
    'Content-Type': 'application/json'
  },
  body: JSON.stringify({
    profile: {
      first_name: 'Jane',
      last_name: 'Smith',
      gender: 'female'
    }
  })
});

const data = await response.json();
```

**Update Profile with Image:**
```javascript
const formData = new FormData();
formData.append('profile[first_name]', 'Jane');
formData.append('profile[last_name]', 'Smith');
formData.append('profile[gender]', 'female');
formData.append('profile[profile_image]', fileInput.files[0]);

const response = await fetch('http://localhost:3000/api/v1/profile', {
  method: 'PATCH',
  headers: {
    'Authorization': `Bearer ${token}`
  },
  body: formData
});

const data = await response.json();
```

**Delete Profile Image:**
```javascript
const response = await fetch('http://localhost:3000/api/v1/profile/image', {
  method: 'DELETE',
  headers: {
    'Authorization': `Bearer ${token}`
  }
});

const data = await response.json();
```

### React Example Component

```jsx
import React, { useState, useEffect } from 'react';

function ProfilePage({ token }) {
  const [profile, setProfile] = useState(null);
  const [formData, setFormData] = useState({
    first_name: '',
    last_name: '',
    middle_name: '',
    gender: ''
  });
  const [imageFile, setImageFile] = useState(null);

  useEffect(() => {
    fetchProfile();
  }, []);

  const fetchProfile = async () => {
    const response = await fetch('http://localhost:3000/api/v1/profile', {
      headers: {
        'Authorization': `Bearer ${token}`
      }
    });
    const data = await response.json();
    setProfile(data.data.profile);
    setFormData({
      first_name: data.data.profile.first_name || '',
      last_name: data.data.profile.last_name || '',
      middle_name: data.data.profile.middle_name || '',
      gender: data.data.profile.gender || ''
    });
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    
    const formDataToSend = new FormData();
    Object.keys(formData).forEach(key => {
      if (formData[key]) {
        formDataToSend.append(`profile[${key}]`, formData[key]);
      }
    });
    
    if (imageFile) {
      formDataToSend.append('profile[profile_image]', imageFile);
    }

    const response = await fetch('http://localhost:3000/api/v1/profile', {
      method: 'PATCH',
      headers: {
        'Authorization': `Bearer ${token}`
      },
      body: formDataToSend
    });

    if (response.ok) {
      const data = await response.json();
      setProfile(data.data.profile);
      alert('Profile updated successfully!');
    }
  };

  const handleDeleteImage = async () => {
    const response = await fetch('http://localhost:3000/api/v1/profile/image', {
      method: 'DELETE',
      headers: {
        'Authorization': `Bearer ${token}`
      }
    });

    if (response.ok) {
      fetchProfile();
    }
  };

  return (
    <div>
      <h1>Profile</h1>
      {profile && (
        <>
          {profile.profile_image_url && (
            <div>
              <img src={profile.profile_image_url} alt="Profile" />
              <button onClick={handleDeleteImage}>Delete Image</button>
            </div>
          )}
          
          <form onSubmit={handleSubmit}>
            <input
              type="text"
              placeholder="First Name"
              value={formData.first_name}
              onChange={(e) => setFormData({...formData, first_name: e.target.value})}
            />
            
            <input
              type="text"
              placeholder="Middle Name"
              value={formData.middle_name}
              onChange={(e) => setFormData({...formData, middle_name: e.target.value})}
            />
            
            <input
              type="text"
              placeholder="Last Name"
              value={formData.last_name}
              onChange={(e) => setFormData({...formData, last_name: e.target.value})}
            />
            
            <select
              value={formData.gender}
              onChange={(e) => setFormData({...formData, gender: e.target.value})}
            >
              <option value="">Select Gender</option>
              <option value="male">Male</option>
              <option value="female">Female</option>
              <option value="other">Other</option>
              <option value="prefer_not_to_say">Prefer not to say</option>
            </select>
            
            <input
              type="file"
              accept="image/*"
              onChange={(e) => setImageFile(e.target.files[0])}
            />
            
            <button type="submit">Update Profile</button>
          </form>
        </>
      )}
    </div>
  );
}

export default ProfilePage;
```

## Model Helper Methods

### `full_name`
Returns the user's full name combining first, middle, and last names. Falls back to email if no name is set.

```ruby
user.full_name
# => "John Michael Doe"

user_without_name.full_name
# => "user@example.com"
```

### `profile_image_url`
Returns the URL path to the profile image, or `nil` if no image is attached.

```ruby
user.profile_image_url
# => "/rails/active_storage/blobs/.../profile.jpg"

user_without_image.profile_image_url
# => nil
```

## Validation Rules

1. **first_name, last_name, middle_name**: Maximum 50 characters each
2. **gender**: Must be one of: `male`, `female`, `other`, `prefer_not_to_say`
3. **profile_image**:
   - Maximum file size: 5MB
   - Allowed formats: JPEG, PNG, GIF, WebP
   - Validated on upload

## Notes

- All profile fields are optional
- Profile can be updated partially (only send fields you want to change)
- Email cannot be changed through the profile endpoint (it's managed by Devise)
- Password changes should use Devise's password update endpoint
- Profile image is stored using Active Storage
- Image URLs are relative paths (prefix with your domain when displaying)

## Related Documentation

- See [API_V1_REFERENCE.md](API_V1_REFERENCE.md) for complete API documentation
- See [DEVISE_SETUP.md](DEVISE_SETUP.md) for authentication setup

