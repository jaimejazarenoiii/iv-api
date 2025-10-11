#!/bin/bash

echo "🗄️  Setting up database and running migrations..."
echo ""

# Check if Docker is running
if ! docker info > /dev/null 2>&1; then
  echo "❌ Docker is not running. Please start Docker and try again."
  exit 1
fi

echo "✅ Docker is running"
echo ""

# Build containers first
echo "🔨 Building Docker containers..."
docker-compose build

echo ""
echo "📦 Installing gems..."
docker-compose run --rm web bundle install

echo ""
echo "🗄️  Creating database..."
docker-compose run --rm web rails db:create

echo ""
echo "🚀 Running migrations..."
docker-compose run --rm web rails db:migrate

echo ""
echo "✅ Database setup complete!"
echo ""
echo "You can now start the application with:"
echo "  ./start.sh"
echo "or"
echo "  docker-compose up"

