@echo off
REM Flutter Web Deployment Script for Windows
REM This script builds and prepares the web app for deployment

echo 🚀 Starting Flutter Web Deployment...

REM Clean previous build
echo 🧹 Cleaning previous build...
flutter clean

REM Get dependencies
echo 📦 Getting dependencies...
flutter pub get

REM Build for web
echo 🔨 Building web app...
flutter build web --base-href "/"

REM Verify build
echo ✅ Verifying build...
if exist "build\web\index.html" (
    if exist "build\web\flutter_bootstrap.js" (
        echo ✅ Build successful! All required files present.
        echo 📁 Deployment ready in: build\web/
        echo.
        echo 🌐 To deploy:
        echo 1. Copy contents of build\web\ to your hosting service
        echo 2. Ensure your hosting service supports SPA routing
        echo 3. Test the deployment
        echo.
        echo 📋 Required files for deployment:
        dir build\web\
        echo.
        echo 🎉 Deployment preparation complete!
    ) else (
        echo ❌ Build failed! Missing flutter_bootstrap.js
        exit /b 1
    )
) else (
    echo ❌ Build failed! Missing index.html
    exit /b 1
)

pause
