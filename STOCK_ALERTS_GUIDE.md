# Stock Alerts Guide

This guide explains the stock alert features for items in the Inventory API.

## Overview

Items now support flexible stock tracking with both low stock and out-of-stock alerts that can be manually configured by users.

## New Fields

### `out_of_stock_threshold` (decimal, optional)
- Defines the quantity threshold at which an item is considered out of stock
- Similar to `min_quantity` but specifically for out-of-stock tracking
- Example: Set to `0` to alert when completely depleted, or `5` to alert when only 5 units remain

### `low_stock_alert_enabled` (boolean, default: true)
- Controls whether low stock alerts are active for this item
- When `false`, the `low_stock?` method will always return `false` regardless of quantity
- Allows users to disable alerts for items they don't want to track

### `out_of_stock_alert_enabled` (boolean, default: true)
- Controls whether out-of-stock alerts are active for this item
- When `false`, the `out_of_stock?` method will always return `false` regardless of quantity
- Allows users to disable alerts for items they don't want to track

## Existing Fields (Enhanced)

### `min_quantity` (decimal, optional)
- Already exists - defines the threshold for low stock alerts
- Now respects the `low_stock_alert_enabled` flag

## Helper Methods

### `low_stock?`
Returns `true` if:
- `low_stock_alert_enabled` is `true`, AND
- `min_quantity` is set, AND
- Current `quantity` is less than or equal to `min_quantity`

### `out_of_stock?` (NEW)
Returns `true` if:
- `out_of_stock_alert_enabled` is `true`, AND
- `out_of_stock_threshold` is set, AND
- Current `quantity` is less than or equal to `out_of_stock_threshold`

## API Endpoints

### GET /api/v1/items/low_stock
Returns all items where `low_stock?` is `true`

**Response:**
```json
{
  "status": {
    "code": 200,
    "message": "Low stock items retrieved successfully."
  },
  "data": {
    "items": [...]
  }
}
```

### GET /api/v1/items/out_of_stock (NEW)
Returns all items where `out_of_stock?` is `true`

**Response:**
```json
{
  "status": {
    "code": 200,
    "message": "Out of stock items retrieved successfully."
  },
  "data": {
    "items": [...]
  }
}
```

## Item JSON Response

All item endpoints now include these additional fields:

```json
{
  "id": 1,
  "name": "Apples",
  "quantity": 3.0,
  "unit": "kg",
  "min_quantity": 5.0,
  "out_of_stock_threshold": 1.0,
  "low_stock_alert_enabled": true,
  "out_of_stock_alert_enabled": true,
  "expiration_date": "2024-10-20",
  "notes": "Organic apples",
  "storage_id": 1,
  "storage_name": "Refrigerator",
  "low_stock": true,
  "out_of_stock": false,
  "created_at": "2024-10-11T12:00:00.000Z",
  "updated_at": "2024-10-11T12:00:00.000Z"
}
```

## Usage Examples

### Create an item with stock alerts
```json
POST /api/v1/items
{
  "item": {
    "name": "Milk",
    "quantity": 2.0,
    "unit": "liters",
    "min_quantity": 3.0,
    "out_of_stock_threshold": 0.5,
    "low_stock_alert_enabled": true,
    "out_of_stock_alert_enabled": true,
    "storage_id": 1
  }
}
```

### Update stock thresholds
```json
PATCH /api/v1/items/1
{
  "item": {
    "min_quantity": 10.0,
    "out_of_stock_threshold": 2.0
  }
}
```

### Disable alerts for an item
```json
PATCH /api/v1/items/1
{
  "item": {
    "low_stock_alert_enabled": false,
    "out_of_stock_alert_enabled": false
  }
}
```

## Alert Logic Examples

### Example 1: Item with both alerts enabled
- **Item:** Eggs
- **Quantity:** 6
- **Min Quantity:** 12
- **Out of Stock Threshold:** 3
- **Low Stock Alert Enabled:** true
- **Out of Stock Alert Enabled:** true

**Result:**
- `low_stock?` → `true` (6 ≤ 12)
- `out_of_stock?` → `false` (6 > 3)

### Example 2: Item with alerts disabled
- **Item:** Salt
- **Quantity:** 1
- **Min Quantity:** 5
- **Out of Stock Threshold:** 2
- **Low Stock Alert Enabled:** false
- **Out of Stock Alert Enabled:** false

**Result:**
- `low_stock?` → `false` (alerts disabled)
- `out_of_stock?` → `false` (alerts disabled)

### Example 3: Item below out-of-stock threshold
- **Item:** Butter
- **Quantity:** 0.5
- **Min Quantity:** 2.0
- **Out of Stock Threshold:** 1.0
- **Low Stock Alert Enabled:** true
- **Out of Stock Alert Enabled:** true

**Result:**
- `low_stock?` → `true` (0.5 ≤ 2.0)
- `out_of_stock?` → `true` (0.5 ≤ 1.0)

## Migration

To apply these changes to your database, run:

```bash
docker-compose run --rm web rails db:migrate
```

Or if running locally:

```bash
rails db:migrate
```

## Best Practices

1. **Set meaningful thresholds**: Consider your usage patterns when setting thresholds
2. **Out of stock < Low stock**: Typically, `out_of_stock_threshold` should be less than `min_quantity`
3. **Use alerts selectively**: Disable alerts for items you don't need to track closely
4. **Regular updates**: Update quantities regularly to ensure alerts work properly
5. **Combine with notifications**: Use these endpoints to build notification systems in your frontend

## Notes

- All threshold fields are optional and can be `null`
- Alert flags default to `true` to enable alerts by default
- Both thresholds are validated to be ≥ 0 if provided
- The `low_stock` and `out_of_stock` boolean fields in the response are computed on-the-fly and not stored in the database

