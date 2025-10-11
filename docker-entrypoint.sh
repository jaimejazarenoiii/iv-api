#!/bin/bash
set -e

# Remove a potentially pre-existing server.pid for Rails.
rm -f /app/tmp/pids/server.pid

# Wait for database to be ready
echo "Waiting for database to be ready..."
until PGPASSWORD=$DATABASE_PASSWORD psql -h "$DATABASE_HOST" -U "$DATABASE_USER" -c '\q' 2>/dev/null; do
  >&2 echo "Postgres is unavailable - sleeping"
  sleep 1
done

echo "Database is ready!"

# Create database if it doesn't exist
echo "Creating database if it doesn't exist..."
bundle exec rails db:create 2>/dev/null || true

# Run migrations
echo "Running migrations..."
bundle exec rails db:migrate 2>/dev/null || true

# Then exec the container's main process (what's set as CMD in the Dockerfile).
exec "$@"

