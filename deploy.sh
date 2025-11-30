#!/bin/bash

# Flutter Web Deployment Script
# This script builds and prepares the web app for deployment

echo "🚀 Starting Flutter Web Deployment..."

# Clean previous build
echo "🧹 Cleaning previous build..."
flutter clean

# Get dependencies
echo "📦 Getting dependencies..."
flutter pub get

# Build for web
echo "🔨 Building web app..."
flutter build web --base-href "/"

# Verify build
echo "✅ Verifying build..."
if [ -f "build/web/index.html" ] && [ -f "build/web/flutter_bootstrap.js" ]; then
    echo "✅ Build successful! All required files present."
    echo "📁 Deployment ready in: build/web/"
    echo ""
    echo "🌐 To deploy:"
    echo "1. Copy contents of build/web/ to your hosting service"
    echo "2. Ensure your hosting service supports SPA routing"
    echo "3. Test the deployment"
    echo ""
    echo "📋 Required files for deployment:"
    ls -la build/web/
else
    echo "❌ Build failed! Missing required files."
    exit 1
fi

echo "🎉 Deployment preparation complete!"
