#!/bin/bash

echo "🔐 Setting up environment variables..."
echo ""

# Check if .env already exists
if [ -f .env ]; then
  echo "⚠️  .env file already exists!"
  read -p "Do you want to overwrite it? (y/N): " -n 1 -r
  echo
  if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "❌ Aborted. Keeping existing .env file."
    exit 0
  fi
fi

# Copy from example
cp .env.example .env

echo "✅ Created .env file from .env.example"
echo ""

# Generate new JWT secret
echo "🔑 Generating new JWT secret key..."
if docker info > /dev/null 2>&1; then
  NEW_SECRET=$(docker-compose run --rm web rails secret 2>/dev/null | tail -1)
  
  if [ ! -z "$NEW_SECRET" ]; then
    # Update the .env file with new secret
    if [[ "$OSTYPE" == "darwin"* ]]; then
      # macOS
      sed -i '' "s/DEVISE_JWT_SECRET_KEY=.*/DEVISE_JWT_SECRET_KEY=$NEW_SECRET/" .env
    else
      # Linux
      sed -i "s/DEVISE_JWT_SECRET_KEY=.*/DEVISE_JWT_SECRET_KEY=$NEW_SECRET/" .env
    fi
    echo "✅ Generated and set new DEVISE_JWT_SECRET_KEY"
  else
    echo "⚠️  Could not generate secret. Using default from .env.example"
  fi
else
  echo "⚠️  Docker not running. Using default secret from .env.example"
  echo "   Run 'docker-compose run --rm web rails secret' to generate a new one"
fi

echo ""
echo "✅ Environment setup complete!"
echo ""
echo "📝 Your .env file contains:"
echo "   - DATABASE_HOST=db"
echo "   - DATABASE_USER=postgres"
echo "   - DATABASE_PASSWORD=secure_postgres_password_change_in_production"
echo "   - DEVISE_JWT_SECRET_KEY=<generated>"
echo "   - RAILS_ENV=development"
echo ""
echo "⚠️  IMPORTANT: Before deploying to production:"
echo "   1. Copy .env.production to .env.production.local"
echo "   2. Generate new secrets with: docker-compose run --rm web rails secret"
echo "   3. Update all CHANGE_THIS values"
echo "   4. NEVER commit .env.production.local to git!"
echo ""
echo "You can now start the application with:"
echo "  docker-compose up"

