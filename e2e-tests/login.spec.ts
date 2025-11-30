import { test, expect } from '@playwright/test';

test.describe('Login Flows', () => {
  test.beforeEach(async ({ page }) => {
    // Navigate to the app
    await page.goto('/');
  });

  test('should show login chooser screen', async ({ page }) => {
    // Wait for the app to load
    await page.waitForLoadState('networkidle');
    
    // Check if we can see the login chooser
    await expect(page.locator('h1, h2, .title')).toContainText('Welcome to NCL');
    
    // Should have login options for different user types (updated to match actual UI)
    await expect(page.locator('text=Customer Login')).toBeVisible();
    await expect(page.locator('text=Staff Access')).toBeVisible();
    await expect(page.locator('text=Admin Portal')).toBeVisible();
  });

  test('should allow customer login', async ({ page }) => {
    // Wait for the app to load
    await page.waitForLoadState('networkidle');
    
    // Click Customer Login
    await page.click('text=Customer Login');
    
    // Wait for login screen
    await page.waitForLoadState('networkidle');
    
    // Fill in customer credentials
    await page.fill('input[type="email"], input[name="email"], [placeholder*="email"]', 'customer@example.com');
    await page.fill('input[type="password"], input[name="password"], [placeholder*="password"]', 'customer123');
    
    // Click Sign In button (updated to match actual UI)
    await page.click('button:has-text("Sign In"), button:has-text("Login"), [type="submit"]');
    
    // Wait for navigation to customer home
    await page.waitForLoadState('networkidle');
    
    // Should be on customer home screen
    await expect(page.locator('h1, h2, .title')).toContainText('Customer Home');
    await expect(page.locator('text=Welcome')).toBeVisible();
  });

  test('should allow staff login', async ({ page }) => {
    // Wait for the app to load
    await page.waitForLoadState('networkidle');
    
    // Click Staff Access (updated to match actual UI)
    await page.click('text=Staff Access');
    
    // Wait for login screen
    await page.waitForLoadState('networkidle');
    
    // Fill in staff credentials
    await page.fill('input[type="email"], input[name="email"], [placeholder*="email"]', 'staff@example.com');
    await page.fill('input[type="password"], input[name="password"], [placeholder*="password"]', 'staff123');
    
    // Click Sign In button (updated to match actual UI)
    await page.click('button:has-text("Sign In"), button:has-text("Login"), [type="submit"]');
    
    // Wait for navigation to staff home
    await page.waitForLoadState('networkidle');
    
    // Should be on staff home screen
    await expect(page.locator('h1, h2, .title')).toContainText('Staff Home');
    await expect(page.locator('text=Dashboard')).toBeVisible();
  });

  test('should allow admin login', async ({ page }) => {
    // Wait for the app to load
    await page.waitForLoadState('networkidle');
    
    // Click Admin Portal (updated to match actual UI)
    await page.click('text=Admin Portal');
    
    // Wait for login screen
    await page.waitForLoadState('networkidle');
    
    // Fill in admin credentials
    await page.fill('input[type="email"], input[name="email"], [placeholder*="email"]', 'admin@example.com');
    await page.fill('input[type="password"], input[name="password"], [placeholder*="password"]', 'admin123');
    
    // Click Sign In button (updated to match actual UI)
    await page.click('button:has-text("Sign In"), button:has-text("Login"), [type="submit"]');
    
    // Wait for navigation to admin home
    await page.waitForLoadState('networkidle');
    
    // Should be on admin home screen
    await expect(page.locator('h1, h2, .title')).toContainText('Admin Dashboard');
    await expect(page.locator('text=Dashboard')).toBeVisible();
  });

  test('should show error for invalid credentials', async ({ page }) => {
    // Wait for the app to load
    await page.waitForLoadState('networkidle');
    
    // Click Customer Login
    await page.click('text=Customer Login');
    
    // Wait for login screen
    await page.waitForLoadState('networkidle');
    
    // Fill in invalid credentials
    await page.fill('input[type="email"], input[name="email"], [placeholder*="email"]', 'invalid@example.com');
    await page.fill('input[type="password"], input[name="password"], [placeholder*="password"]', 'wrongpassword');
    
    // Click Sign In button (updated to match actual UI)
    await page.click('button:has-text("Sign In"), button:has-text("Login"), [type="submit"]');
    
    // Should show error message
    await expect(page.locator('text=Invalid credentials, text=Login failed, text=Error')).toBeVisible({ timeout: 5000 });
  });

  test('should handle logout correctly', async ({ page }) => {
    // Wait for the app to load
    await page.waitForLoadState('networkidle');
    
    // Login as customer
    await page.click('text=Customer Login');
    await page.waitForLoadState('networkidle');
    await page.fill('input[type="email"], input[name="email"], [placeholder*="email"]', 'customer@example.com');
    await page.fill('input[type="password"], input[name="password"], [placeholder*="password"]', 'customer123');
    await page.click('button:has-text("Sign In"), button:has-text("Login"), [type="submit"]');
    await page.waitForLoadState('networkidle');
    
    // Look for logout button/menu
    const logoutSelectors = [
      'button:has-text("Logout")',
      'button:has-text("Sign Out")',
      '[aria-label*="logout"]',
      '[data-testid="logout"]',
      '.logout-button',
      'text=Logout',
      'text=Sign Out'
    ];
    
    // Try to find and click logout
    for (const selector of logoutSelectors) {
      try {
        await page.click(selector, { timeout: 2000 });
        break;
      } catch (e) {
        // Continue to next selector
      }
    }
    
    // Should return to login chooser
    await page.waitForLoadState('networkidle');
    await expect(page.locator('text=Welcome to NCL, text=Customer Login, text=Staff Access, text=Admin Portal')).toBeVisible();
  });
});
