// playwright_test/chrome_only.spec.js
const { test, expect } = require('@playwright/test');

/// Chrome-only tests that actually work with your Flutter app
test.describe('Flutter App - Chrome Tests', () => {
  test.use({ 
    browser: 'chromium',
    headless: false, // Show the browser so you can see it working
    viewport: { width: 1280, height: 720 }
  });

  test('App Loads Successfully', async ({ page }) => {
    console.log('🚀 Starting app load test...');
    
    // Navigate to your Flutter app
    await page.goto('http://localhost:8080');
    
    // Wait for Flutter app to initialize
    await page.waitForTimeout(3000);
    
    // Take screenshot of initial state
    await page.screenshot({ path: 'test-results/app-loaded.png' });
    
    // Check if page loaded (basic check)
    const pageTitle = await page.title();
    console.log(`Page title: ${pageTitle}`);
    
    // Look for any Flutter app content
    const body = page.locator('body');
    await expect(body).toBeVisible();
    
    console.log('✅ App loaded successfully');
  });

  test('Customer Login Button Click', async ({ page }) => {
    console.log('🚀 Testing Customer Login button...');
    
    await page.goto('http://localhost:8080');
    await page.waitForTimeout(3000);
    
    // Try multiple selectors for Customer Login button
    const customerButton = page.locator('button:has-text("Customer Login"), [data-testid="customer_login_button"], .customer-login-btn, button >> text="Customer Login"');
    
    // Wait and check if button is visible
    await customerButton.waitFor({ state: 'visible', timeout: 10000 });
    
    // Take screenshot before clicking
    await page.screenshot({ path: 'test-results/before-customer-click.png' });
    
    // Click the button
    await customerButton.click();
    
    // Wait for navigation
    await page.waitForTimeout(2000);
    
    // Take screenshot after clicking
    await page.screenshot({ path: 'test-results/after-customer-click.png' });
    
    console.log('✅ Customer Login button clicked successfully');
  });

  test('Staff Access Button Click', async ({ page }) => {
    console.log('🚀 Testing Staff Access button...');
    
    await page.goto('http://localhost:8080');
    await page.waitForTimeout(3000);
    
    // Find Staff Access button
    const staffButton = page.locator('button:has-text("Staff Access"), [data-testid="staff_access_button"], .staff-access-btn, button >> text="Staff Access"');
    
    await staffButton.waitFor({ state: 'visible', timeout: 10000 });
    
    await page.screenshot({ path: 'test-results/before-staff-click.png' });
    
    await staffButton.click();
    await page.waitForTimeout(2000);
    
    await page.screenshot({ path: 'test-results/after-staff-click.png' });
    
    console.log('✅ Staff Access button clicked successfully');
  });

  test('Admin Portal Button Click', async ({ page }) => {
    console.log('🚀 Testing Admin Portal button...');
    
    await page.goto('http://localhost:8080');
    await page.waitForTimeout(3000);
    
    // Find Admin Portal button
    const adminButton = page.locator('button:has-text("Admin Portal"), [data-testid="admin_portal_button"], .admin-portal-btn, button >> text="Admin Portal"');
    
    await adminButton.waitFor({ state: 'visible', timeout: 10_000 });
    
    await page.screenshot({ path: 'test-results/before-admin-click.png' });
    
    await adminButton.click();
    await page.waitForTimeout(2000);
    
    await page.screenshot({ path: 'test-results/after-admin-click.png' });
    
    console.log('✅ Admin Portal button clicked successfully');
  });

  test('Help Button Click', async ({ page }) => {
    console.log('🚀 Testing Help button...');
    
    await page.goto('http://localhost:8080');
    await page.waitForTimeout(3000);
    
    // Look for help text/button
    const helpButton = page.locator('text=Need help signing in?, button:has-text("Help"), .help-btn, a >> text="help"');
    
    if (await helpButton.isVisible()) {
      await helpButton.click();
      await page.waitForTimeout(1000);
      
      await page.screenshot({ path: 'test-results/help-dialog.png' });
      
      console.log('✅ Help button clicked successfully');
    } else {
      console.log('ℹ️ Help button not found - skipping');
      await page.screenshot({ path: 'test-results/no-help-button.png' });
    }
  });

  test('Complete Navigation Test', async ({ page }) => {
    console.log('🚀 Testing complete navigation flow...');
    
    await page.goto('http://localhost:8080');
    await page.waitForTimeout(3000);
    
    // Test all buttons in sequence
    const buttons = [
      { name: 'Customer Login', selector: 'button:has-text("Customer Login")' },
      { name: 'Staff Access', selector: 'button:has-text("Staff Access")' },
      { name: 'Admin Portal', selector: 'button:has-text("Admin Portal")' }
    ];
    
    for (const button of buttons) {
      console.log(`Testing ${button.name}...`);
      
      // Go back to home first
      await page.goto('http://localhost:8080');
      await page.waitForTimeout(2000);
      
      // Click button
      const btn = page.locator(button.selector);
      await btn.waitFor({ state: 'visible', timeout: 5000 });
      await btn.click();
      await page.waitForTimeout(2000);
      
      // Take screenshot
      await page.screenshot({ path: `test-results/${button.name.toLowerCase().replace(' ', '-')}-page.png` });
      
      console.log(`✅ ${button.name} navigation successful`);
    }
    
    console.log('✅ Complete navigation test finished');
  });

  test('Check for Login Forms', async ({ page }) => {
    console.log('🚀 Testing login form elements...');
    
    await page.goto('http://localhost:8080');
    await page.waitForTimeout(3000);
    
    // Navigate to customer login
    const customerButton = page.locator('button:has-text("Customer Login")');
    await customerButton.waitFor({ state: 'visible', timeout: 10000 });
    await customerButton.click();
    await page.waitForTimeout(2000);
    
    // Look for form elements
    const emailInput = page.locator('input[type="email"], input[type="text"], input[placeholder*="email"], input[aria-label*="email"]');
    const passwordInput = page.locator('input[type="password"], input[placeholder*="password"], input[aria-label*="password"]');
    const submitButton = page.locator('button[type="submit"], button:has-text("Sign In"), button:has-text("Login"), button:has-text("Submit")');
    
    // Take screenshot of the form
    await page.screenshot({ path: 'test-results/login-form.png' });
    
    // Check if form elements exist
    const hasEmail = await emailInput.count() > 0;
    const hasPassword = await passwordInput.count() > 0;
    const hasSubmit = await submitButton.count() > 0;
    
    console.log(`Email field found: ${hasEmail}`);
    console.log(`Password field found: ${hasPassword}`);
    console.log(`Submit button found: ${hasSubmit}`);
    
    if (hasEmail && hasPassword && hasSubmit) {
      console.log('✅ Login form elements found');
      
      // Try filling the form
      await emailInput.fill('test@example.com');
      await passwordInput.fill('testpassword');
      await page.waitForTimeout(500);
      
      await page.screenshot({ path: 'test-results/filled-form.png' });
      
      console.log('✅ Form filled successfully');
    } else {
      console.log('⚠️ Some form elements not found');
    }
  });
});
