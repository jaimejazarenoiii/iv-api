#!/bin/bash

echo "🚀 Starting IV API..."
echo ""

# Check if Docker is running
if ! docker info > /dev/null 2>&1; then
  echo "❌ Docker is not running. Please start Docker and try again."
  exit 1
fi

echo "✅ Docker is running"
echo ""

# Build containers if needed
echo "🔨 Building Docker containers..."
docker-compose build

echo ""
echo "✅ Build complete"
echo ""

# Start the application
echo "🌟 Starting the application..."
docker-compose up

# Note: The docker-entrypoint.sh script will automatically:
# - Wait for the database to be ready
# - Create the database if it doesn't exist
# - Run migrations

