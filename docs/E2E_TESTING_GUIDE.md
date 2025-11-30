# 🔐 NCL Authentication E2E Testing Guide

## 📋 Overview

This guide covers the comprehensive E2E testing setup for the NCL Flutter Web application's authentication system. The testing framework uses Cypress and is designed to work with the current Flutter web rendering constraints.

## 🎯 Testing Scope

### ✅ What We Test

1. **Authentication Flows**
   - Customer login/logout
   - Staff login/logout  
   - Admin login/logout
   - Form validation
   - Error handling

2. **Route Protection**
   - Protected route access without authentication
   - Role-based access control
   - Redirect behavior

3. **Session Management**
   - Login persistence
   - Session expiration
   - Logout functionality

4. **UI Responsiveness**
   - Mobile viewports
   - Tablet viewports
   - Desktop viewports

5. **Security Testing**
   - Invalid credentials
   - Route protection
   - Role-based access violations

### ⚠️ Current Limitations

Due to the Flutter web rendering issue (`flt-scene-host` missing), some tests are designed to work with:

- **Fallback HTML forms** (if available)
- **Partial Flutter content** (when rendering works)
- **Mock scenarios** (when UI is not available)

## 🚀 Quick Start

### Prerequisites

1. **Flutter Server Running**
   ```bash
   cd build/web
   python -m http.server 8101 --bind 0.0.0.0
   ```

2. **Dependencies Installed**
   ```bash
   npm install
   ```

### Running Tests

#### 1. Quick Authentication Tests
```bash
npm run test:auth
```

#### 2. Full Test Suite with Report
```bash
npm run test:auth:full
```

#### 3. Headed Mode (Visible Browser)
```bash
npm run test:auth:headed
```

#### 4. Interactive Cypress Mode
```bash
npm run test:e2e:open
```

## 📊 Test Commands

| Command | Description | Use Case |
|---------|-------------|----------|
| `npm run test:auth` | Run auth tests headless | CI/CD pipelines |
| `npm run test:auth:headed` | Run auth tests with browser | Debugging |
| `npm run test:auth:full` | Run with comprehensive report | Full analysis |
| `npm run test:e2e` | Run all E2E tests | Complete testing |
| `npm run test:e2e:open` | Open Cypress UI | Manual testing |

## 🧪 Test Structure

### Test Files

- **`cypress/e2e/auth_e2e_test.cy.js`** - Main authentication test suite
- **`cypress/support/auth-commands.js`** - Custom authentication commands
- **`cypress/support/e2e.js`** - Global test configuration
- **`scripts/run-auth-tests.js`** - Test runner with reporting

### Test Categories

#### 1. Landing Page & Login Chooser
```javascript
// Tests login chooser functionality
- Should display role options (Customer, Staff, Admin)
- Should navigate to correct login pages
- Should handle routing correctly
```

#### 2. Customer Authentication Flow
```javascript
// Tests customer login process
- Form validation (empty fields)
- Invalid credentials handling
- Successful login and redirect
- Dashboard access
```

#### 3. Staff Authentication Flow
```javascript
// Tests staff login process
- Staff-specific login
- Dashboard access
- Role verification
```

#### 4. Admin Authentication Flow
```javascript
// Tests admin login process
- Admin-specific login
- Dashboard access
- Admin privileges
```

#### 5. Session Management
```javascript
// Tests session handling
- Login persistence across refreshes
- Logout functionality
- Session cleanup
```

#### 6. Security Testing
```javascript
// Tests security measures
- Protected route access
- Role-based access control
- Unauthorized access prevention
```

#### 7. Cross-Platform Testing
```javascript
// Tests responsive design
- Mobile viewport (375x667)
- Tablet viewport (768x1024)
- Desktop viewport (1280x720)
```

## 🔧 Custom Commands

### Authentication Commands

```javascript
// Login with specific role
cy.login('customer')  // Logs in as customer
cy.login('staff')     // Logs in as staff
cy.login('admin')     // Logs in as admin

// Check Flutter rendering status
cy.checkFlutterRendering()

// Wait for Flutter content
cy.waitForFlutter(15000)  // Wait 15 seconds

// Check UI elements
cy.checkUIElements(['Login', 'Email', 'Password'])

// Test route protection
cy.testRouteProtection('/customer/home')

// Test responsive design
cy.testResponsive('/login/customer', [
  { name: 'mobile', width: 375, height: 667 },
  { name: 'tablet', width: 768, height: 1024 }
])

// Logout
cy.logout()
```

## 📈 Test Reports

### Report Location
- **JSON Report**: `test-results/auth-test-report.json`
- **Screenshots**: `cypress/screenshots/`
- **Videos**: `cypress/videos/` (if enabled)

### Report Content
```json
{
  "timestamp": "2025-11-29T06:13:56.938Z",
  "flutterServer": true,
  "flutterRendering": false,
  "testResults": [...],
  "summary": {
    "total": 15,
    "passed": 12,
    "failed": 3
  }
}
```

## 🐛 Debugging

### Common Issues

#### 1. Flutter Rendering Not Working
```bash
# Check Flutter server
curl http://localhost:8101

# Check rendering status
node scripts/run-auth-tests.js
```

**Solution**: This is a known Flutter web engine issue. Tests will adapt accordingly.

#### 2. Cypress Installation Issues
```bash
# Clear Cypress cache
npx cypress cache clear

# Reinstall Cypress
npm uninstall cypress
npm install cypress@12.17.4 --save-dev
```

#### 3. Test Timeouts
```bash
# Increase timeout in cypress.config.auth.js
defaultCommandTimeout: 30000  // Increase to 30 seconds
```

### Debug Mode

Run tests in headed mode to see what's happening:
```bash
npm run test:auth:headed
```

### Interactive Testing

Open Cypress UI for manual testing:
```bash
npm run test:e2e:open
```

## 🔄 CI/CD Integration

### GitHub Actions Example
```yaml
name: E2E Tests
on: [push, pull_request]

jobs:
  e2e:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - uses: actions/setup-node@v2
        with:
          node-version: '18'
      - run: npm install
      - run: npm run build
      - run: npm run serve &
      - run: sleep 10
      - run: npm run test:auth:full
```

## 📱 Mobile Testing

### Viewports Tested
- **iPhone 6/7/8**: 375x667
- **iPad**: 768x1024
- **Desktop**: 1280x720

### Responsive Tests
```javascript
// Automatically tests all viewports
cy.testResponsive('/login/customer', [
  { name: 'mobile', width: 375, height: 667 },
  { name: 'tablet', width: 768, height: 1024 },
  { name: 'desktop', width: 1280, height: 720 }
])
```

## 🔒 Security Testing

### Tests Included
- **Route Protection**: Verifies protected routes redirect to login
- **Role-based Access**: Tests role-specific page access
- **Invalid Credentials**: Tests error handling for bad login attempts
- **Session Security**: Tests logout and session cleanup

### Security Best Practices
```javascript
// Test route protection
cy.testRouteProtection('/customer/home', '/login/customer')

// Test role-based access
cy.login('customer')
cy.visit('/admin/home')
// Should redirect or show access denied
```

## 📊 Performance Testing

### Test Metrics
- **Load Time**: Time to load authentication pages
- **Response Time**: Time for login requests
- **Render Time**: Time for Flutter content to appear

### Performance Commands
```javascript
// Wait for Flutter with timeout
cy.waitForFlutter(15000)

// Check rendering status
cy.checkFlutterRendering().then(result => {
  expect(result.isRendering).to.be.true
})
```

## 🎯 Best Practices

### Test Organization
1. **Group related tests** using `describe` and `context`
2. **Use descriptive test names** that explain what's being tested
3. **Add custom commands** for reusable actions
4. **Take screenshots** on failures for debugging

### Test Data
1. **Use consistent test credentials** across all tests
2. **Clean up test data** after each test
3. **Mock external dependencies** when necessary

### Error Handling
1. **Handle Flutter rendering issues** gracefully
2. **Provide meaningful error messages**
3. **Take screenshots** on failures
4. **Log useful debugging information**

## 🚀 Next Steps

### When Flutter Rendering is Fixed
1. **Enable full UI testing** with actual Flutter widgets
2. **Add visual regression testing**
3. **Test complex user interactions**
4. **Add accessibility testing**

### Future Enhancements
1. **API testing** for backend endpoints
2. **Performance testing** with load testing
3. **Cross-browser testing** (Chrome, Firefox, Safari)
4. **Mobile app testing** (if applicable)

## 📞 Support

### Troubleshooting Checklist
1. ✅ Flutter server running on port 8101
2. ✅ Dependencies installed (`npm install`)
3. ✅ Cypress cache cleared (`npx cypress cache clear`)
4. ✅ Test server accessible (curl http://localhost:8101)
5. ✅ No conflicting processes on ports

### Getting Help
- Check the test report: `test-results/auth-test-report.json`
- Review screenshots: `cypress/screenshots/`
- Run tests in headed mode for debugging
- Check Cypress documentation for advanced features

---

**Note**: These tests are designed to work with the current Flutter web rendering limitations. Once the rendering issue is resolved, the full power of Flutter UI testing will be available.
