// playwright_test/flutter_app_test.spec.js
const { test, expect } = require('@playwright/test');

/// Test if Playwright can handle your Flutter app better than Appium
test.describe('Flutter App - Playwright Testing', () => {
  test.beforeEach(async ({ page }) => {
    // Start your Flutter app first with: flutter run -d chrome --web-port=8080
  });

  test('Basic Flutter App Interaction', async ({ page }) => {
    // Navigate to your Flutter app
    await page.goto('http://localhost:8080');
    
    // Wait for app to load
    await page.waitForLoadState('networkidle');
    
    // Take screenshot of initial state
    await page.screenshot({ path: 'playwright-report/flutter-initial.png' });
    
    console.log('✅ Flutter app loaded successfully');
  });

  test('Customer Login Flow', async ({ page }) => {
    await page.goto('http://localhost:8080');
    await page.waitForLoadState('networkidle');
    
    // Find Customer Login button
    const customerButton = page.locator('text=Customer Login');
    await expect(customerButton).toBeVisible({ timeout: 10000 });
    
    // Click Customer Login
    await customerButton.click();
    await page.waitForTimeout(2000);
    
    // Take screenshot after navigation
    await page.screenshot({ path: 'playwright-report/customer-login-screen.png' });
    
    // Find email field
    const emailField = page.locator('input[type="email"], input[placeholder*="email"], input[aria-label*="email"]');
    await expect(emailField).toBeVisible({ timeout: 10000 });
    
    // Fill email
    await emailField.fill('customer@example.com');
    await page.waitForTimeout(500);
    
    // Find password field
    const passwordField = page.locator('input[type="password"], input[placeholder*="password"], input[aria-label*="password"]');
    await expect(passwordField).toBeVisible({ timeout: 10000 });
    
    // Fill password
    await passwordField.fill('customer123');
    await page.waitForTimeout(500);
    
    // Take screenshot of filled form
    await page.screenshot({ path: 'playwright-report/filled-customer-form.png' });
    
    // Find and click login button
    const loginButton = page.locator('button:has-text("Sign In"), button:has-text("Login"), button:has-text("Submit")');
    if (await loginButton.isVisible()) {
      await loginButton.click();
      await page.waitForTimeout(3000);
      
      // Take screenshot after login attempt
      await page.screenshot({ path: 'playwright-report/after-customer-login.png' });
    }
    
    console.log('✅ Customer login flow completed');
  });

  test('Staff Login Flow', async ({ page }) => {
    await page.goto('http://localhost:8080');
    await page.waitForLoadState('networkidle');
    
    // Find Staff Access button
    const staffButton = page.locator('text=Staff Access');
    await expect(staffButton).toBeVisible({ timeout: 10000 });
    
    // Click Staff Access
    await staffButton.click();
    await page.waitForTimeout(2000);
    
    // Take screenshot
    await page.screenshot({ path: 'playwright-report/staff-login-screen.png' });
    
    // Fill form (similar to customer)
    const emailField = page.locator('input[type="email"], input[placeholder*="email"], input[aria-label*="email"]');
    await emailField.fill('staff@example.com');
    
    const passwordField = page.locator('input[type="password"], input[placeholder*="password"], input[aria-label*="password"]');
    await passwordField.fill('staff123');
    
    await page.screenshot({ path: 'playwright-report/filled-staff-form.png' });
    
    console.log('✅ Staff login flow completed');
  });

  test('Admin Login Flow', async ({ page }) => {
    await page.goto('http://localhost:8080');
    await page.waitForLoadState('networkidle');
    
    // Find Admin Portal button
    const adminButton = page.locator('text=Admin Portal');
    await expect(adminButton).toBeVisible({ timeout: 10000 });
    
    // Click Admin Portal
    await adminButton.click();
    await page.waitForTimeout(2000);
    
    // Take screenshot
    await page.screenshot({ path: 'playwright-report/admin-login-screen.png' });
    
    // Fill form
    const emailField = page.locator('input[type="email"], input[placeholder*="email"], input[aria-label*="email"]');
    await emailField.fill('admin@example.com');
    
    const passwordField = page.locator('input[type="password"], input[placeholder*="password"], input[aria-label*="password"]');
    await passwordField.fill('admin123');
    
    await page.screenshot({ path: 'playwright-report/filled-admin-form.png' });
    
    console.log('✅ Admin login flow completed');
  });

  test('Help Dialog Test', async ({ page }) => {
    await page.goto('http://localhost:8080');
    await page.waitForLoadState('networkidle');
    
    // Find help button
    const helpButton = page.locator('text=Need help signing in?');
    await expect(helpButton).toBeVisible({ timeout: 10000 });
    
    // Click help
    await helpButton.click();
    await page.waitForTimeout(1000);
    
    // Take screenshot of help dialog
    await page.screenshot({ path: 'playwright-report/help-dialog.png' });
    
    // Look for close button or click outside
    const closeButton = page.locator('text=Close, button[aria-label*="Close"]');
    if (await closeButton.isVisible()) {
      await closeButton.click();
    } else {
      // Click outside dialog
      await page.click('body', { position: { x: 100, y: 100 } });
    }
    
    await page.waitForTimeout(1000);
    
    console.log('✅ Help dialog test completed');
  });
});
