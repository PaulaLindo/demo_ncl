# Flutter Web Deployment Guide

## 🔧 Fixing 404 Errors During Deployment

### **Common Causes & Solutions:**

#### 1. **Wrong Directory Deployment**
❌ **Problem**: Deploying source `web/` directory instead of built `build/web/`
✅ **Solution**: Always deploy the `build/web/` directory contents

```bash
# Build the web app first
flutter build web --web-renderer html --base-href "/"

# Deploy the contents of build/web/ directory
# NOT the web/ directory
```

#### 2. **Base HREF Configuration**
❌ **Problem**: Incorrect base href for subdirectory deployment
✅ **Solution**: Configure base href properly

```bash
# For root domain deployment (https://yourdomain.com/)
flutter build web --web-renderer html --base-href "/"

# For subdirectory deployment (https://yourdomain.com/app/)
flutter build web --web-renderer html --base-href "/app/"
```

#### 3. **Server Configuration**
❌ **Problem**: Server doesn't handle client-side routing
✅ **Solution**: Configure server for SPA routing

**For GitHub Pages:**
```yaml
# .github/workflows/deploy.yml
- name: Build Flutter Web
  run: |
    flutter build web --web-renderer html --base-href "/${{ github.event.repository.name }}/"
    
- name: Deploy to GitHub Pages
  uses: peaceiris/actions-gh-pages@v3
  with:
    github_token: ${{ secrets.GITHUB_TOKEN }}
    publish_dir: build/web
```

**For Netlify:**
```toml
# netlify.toml
[[redirects]]
  from = "/*"
  to = "/index.html"
  status = 200
```

**For Vercel:**
```json
// vercel.json
{
  "rewrites": [
    { "source": "/(.*)", "destination": "/index.html" }
  ]
}
```

#### 4. **Missing Build Files**
❌ **Problem**: Required files missing from deployment
✅ **Solution**: Ensure all build assets are included

**Required files in build/web/:**
- `index.html`
- `flutter_bootstrap.js`
- `flutter.js`
- `assets/` directory
- `canvaskit/` directory (if using CanvasKit renderer)

### **🚀 Step-by-Step Deployment:**

#### **1. Build the App:**
```bash
# Clean previous build
flutter clean

# Get dependencies
flutter pub get

# Build for web with HTML renderer (better compatibility)
flutter build web --web-renderer html --base-href "/"
```

#### **2. Verify Build:**
```bash
# Check that build/web contains all necessary files
ls build/web/
```

#### **3. Deploy:**
```bash
# Copy build/web contents to your deployment target
# OR use your deployment platform's CLI
```

### **🔍 Troubleshooting 404 Errors:**

#### **Check Browser Console:**
1. Open browser developer tools
2. Look for 404 errors in Network tab
3. Check Console tab for JavaScript errors

#### **Common Issues:**
- Missing `flutter_bootstrap.js` file
- Incorrect base href
- Server not handling client-side routes
- CORS issues

#### **Debug Steps:**
1. Verify `flutter_bootstrap.js` loads correctly
2. Check that assets are accessible
3. Test direct navigation to routes
4. Verify server configuration

### **🌐 Platform-Specific Solutions:**

#### **GitHub Pages:**
```yaml
name: Deploy Flutter Web
on:
  push:
    branches: [ main ]
jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v3
    - uses: subosito/flutter-action@v2
      with:
        flutter-version: '3.16.0'
    - run: flutter pub get
    - run: flutter build web --web-renderer html --base-href "/${{ github.event.repository.name }}/"
    - uses: peaceiris/actions-gh-pages@v3
      with:
        github_token: ${{ secrets.GITHUB_TOKEN }}
        publish_dir: build/web
```

#### **Firebase Hosting:**
```bash
# Install Firebase CLI
npm install -g firebase-tools

# Initialize Firebase
firebase init hosting

# Deploy
firebase deploy --only hosting
```

#### **Netlify:**
```bash
# Install Netlify CLI
npm install -g netlify-cli

# Deploy
netlify deploy --prod --dir=build/web
```

### **⚡ Quick Fix Checklist:**

- [ ] Built with `flutter build web`
- [ ] Using `build/web/` directory for deployment
- [ ] Correct `--base-href` for your deployment path
- [ ] Server configured for SPA routing
- [ ] All assets accessible (404-free)
- [ ] Browser console shows no errors

### **🎯 For Your Current Issue:**

Based on your error, the most likely fix is:

1. **Build the app:**
   ```bash
   flutter build web --web-renderer html --base-href "/"
   ```

2. **Deploy the `build/web/` contents** (not the `web/` directory)

3. **Configure your hosting service** for SPA routing

This should resolve the 404 errors you're experiencing during free git deployment.
