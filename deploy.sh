#!/bin/bash

echo "🚀 Starting Deployment..."

# 1. Pull the latest code
echo "📥 Pulling latest changes..."
git pull origin main

# 2. Stop existing containers (optional but safer)
echo "🛑 Stopping containers..."
docker-compose down

# 3. Build and start containers
echo "🏗️ Building and starting containers..."
docker-compose up -d --build

# 4. Clean up unused images
echo "🧹 Cleaning up unused images..."
docker image prune -f

echo "✅ Deployment Complete! App is running."
