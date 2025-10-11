# Environment Variables Setup Guide

## Overview

This project uses environment variables for configuration. These are stored in `.env` files.

## Files

- **`.env`** - Development environment (committed to git with default values)
- **`.env.production`** - Production template (NOT committed to git)
- **`.env.example`** - Example template (already exists)

## Environment Variables

### Database Configuration

| Variable | Description | Default | Required |
|----------|-------------|---------|----------|
| `DATABASE_HOST` | PostgreSQL host | `db` | Yes |
| `DATABASE_USER` | PostgreSQL username | `postgres` | Yes |
| `DATABASE_PASSWORD` | PostgreSQL password | `password` | Yes |

### Rails Configuration

| Variable | Description | Default | Required |
|----------|-------------|---------|----------|
| `RAILS_ENV` | Rails environment | `development` | Yes |
| `RAILS_MAX_THREADS` | Maximum threads for Puma | `5` | No |
| `PORT` | Application port | `3000` | No |

### Authentication

| Variable | Description | Required |
|----------|-------------|----------|
| `DEVISE_JWT_SECRET_KEY` | Secret key for JWT token signing | Yes |

⚠️ **CRITICAL**: The `DEVISE_JWT_SECRET_KEY` must be a long, random string. Never use the same value in production as development!

## Setup for Development

The `.env` file is already created with secure defaults. Just run:

```bash
docker-compose up
```

## Setup for Production

### 1. Generate Secrets

Generate a new JWT secret:

```bash
docker-compose run --rm web rails secret
```

Or use openssl:

```bash
openssl rand -hex 64
```

### 2. Create Production .env

Copy the template:

```bash
cp .env.production .env.production.local
```

### 3. Edit Values

Edit `.env.production.local` and replace all `CHANGE_THIS` values:

```bash
# Example production values
DATABASE_HOST=my-production-db.example.com
DATABASE_USER=ivapi_prod
DATABASE_PASSWORD=super_secure_random_password_here
DEVISE_JWT_SECRET_KEY=generated_secret_from_rails_secret_command
RAILS_ENV=production
```

### 4. Load in Docker

```bash
docker-compose --env-file .env.production.local up
```

## Security Best Practices

### ✅ DO:
- Generate unique secrets for each environment
- Use strong passwords (20+ characters, mixed case, numbers, symbols)
- Keep production `.env` files out of version control
- Rotate secrets regularly
- Use environment-specific values

### ❌ DON'T:
- Commit production `.env` files to git
- Share secrets in chat/email
- Use default/example values in production
- Reuse secrets across environments
- Store secrets in code

## Generating Secure Values

### JWT Secret Key

```bash
# Method 1: Rails secret generator (recommended)
docker-compose run --rm web rails secret

# Method 2: OpenSSL
openssl rand -hex 64

# Method 3: Ruby one-liner
ruby -e "require 'securerandom'; puts SecureRandom.hex(64)"
```

### Database Password

```bash
# Generate secure password
openssl rand -base64 32
```

## Environment-Specific Configurations

### Development
```env
DATABASE_HOST=db
DATABASE_PASSWORD=password  # Simple for local development
RAILS_ENV=development
```

### Test
```env
DATABASE_HOST=db
DATABASE_PASSWORD=password
RAILS_ENV=test
```

### Production
```env
DATABASE_HOST=prod-db.example.com
DATABASE_PASSWORD=complex_secure_password_here
RAILS_ENV=production
RAILS_LOG_LEVEL=info
```

## Docker Compose Integration

The `docker-compose.yml` file automatically loads `.env`:

```yaml
env_file:
  - .env
environment:
  DATABASE_HOST: ${DATABASE_HOST:-db}
  # ... other variables
```

The `:-` syntax provides fallback defaults if variables aren't set.

## Checking Current Values

### View environment variables (development)

```bash
docker-compose run --rm web printenv | grep -E '(DATABASE|DEVISE|RAILS)'
```

### Test configuration

```bash
# Check if Rails can load config
docker-compose run --rm web rails runner "puts ENV['DEVISE_JWT_SECRET_KEY'].present? ? 'JWT Secret: OK' : 'JWT Secret: MISSING'"
```

## Troubleshooting

### Error: "DEVISE_JWT_SECRET_KEY not set"

**Solution**: Ensure `.env` file exists and contains `DEVISE_JWT_SECRET_KEY`

### Error: "Could not connect to database"

**Solution**: Check `DATABASE_HOST`, `DATABASE_USER`, and `DATABASE_PASSWORD` values

### Changes not taking effect

**Solution**: Restart containers:

```bash
docker-compose down
docker-compose up
```

## CI/CD Setup

For GitHub Actions, GitLab CI, etc., set secrets in your CI/CD platform:

### GitHub Actions Example

```yaml
env:
  DEVISE_JWT_SECRET_KEY: ${{ secrets.DEVISE_JWT_SECRET_KEY }}
  DATABASE_PASSWORD: ${{ secrets.DATABASE_PASSWORD }}
```

### GitLab CI Example

```yaml
variables:
  DEVISE_JWT_SECRET_KEY: $CI_DEVISE_JWT_SECRET_KEY
  DATABASE_PASSWORD: $CI_DATABASE_PASSWORD
```

## Additional Resources

- [Rails Credentials Guide](https://guides.rubyonrails.org/security.html#custom-credentials)
- [12-Factor App Config](https://12factor.net/config)
- [Docker Compose Environment Variables](https://docs.docker.com/compose/environment-variables/)

