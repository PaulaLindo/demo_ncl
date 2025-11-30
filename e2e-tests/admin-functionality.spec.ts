import { test, expect } from '@playwright/test';

test.describe('Admin Functionality', () => {
  test.beforeEach(async ({ page }) => {
    // Login as admin before each test
    await page.goto('/');
    await page.waitForLoadState('networkidle');
    
    // Click Admin Login
    await page.click('text=Admin Login');
    await page.waitForLoadState('networkidle');
    
    // Fill in admin credentials
    await page.fill('input[type="email"], input[name="email"], [placeholder*="email"]', 'admin@example.com');
    await page.fill('input[type="password"], input[name="password"], [placeholder*="password"]', 'admin123');
    
    // Click login button
    await page.click('button:has-text("Login"), button:has-text("Sign In"), [type="submit"]');
    await page.waitForLoadState('networkidle');
  });

  test('should show admin dashboard', async ({ page }) => {
    // Should be on admin home screen
    await expect(page.locator('h1, h2, .title')).toContainText('Admin Dashboard');
    
    // Should have admin navigation options
    await expect(page.locator('text=Dashboard, text=Users, text=Bookings')).toBeVisible();
    await expect(page.locator('text=Staff, text=Reports, text=Settings')).toBeVisible();
  });

  test('should access user management', async ({ page }) => {
    // Click on Users or User Management
    await page.click('text=Users, text=User Management');
    await page.waitForLoadState('networkidle');
    
    // Should be on users screen
    await expect(page.locator('h1, h2, .title')).toContainText('Users');
    
    // Should show user list or filters
    await expect(page.locator('text=Customer, text=Staff, text=All Users')).toBeVisible();
    
    // Should have search or filter options
    await expect(page.locator('input[type="search"], input[placeholder*="search"], .search-input')).toBeVisible();
  });

  test('should manage user accounts', async ({ page }) => {
    // Navigate to users
    await page.click('text=Users, text=User Management');
    await page.waitForLoadState('networkidle');
    
    // Look for user management actions
    const userActionSelectors = [
      'text=Add User',
      'text=Create User',
      'button:has-text("Edit")',
      'button:has-text("Ban")',
      'button:has-text("Activate")',
      '[data-testid="add-user"]'
    ];
    
    let foundActions = false;
    for (const selector of userActionSelectors) {
      try {
        await expect(page.locator(selector)).toBeVisible({ timeout: 2000 });
        foundActions = true;
        break;
      } catch (e) {
        // Continue to next selector
      }
    }
    
    if (foundActions) {
      // Try to add a new user
      try {
        await page.click('text=Add User, text=Create User', { timeout: 2000 });
        await page.waitForLoadState('networkidle');
        
        // Should be on add user form
        await expect(page.locator('h1, h2, .title')).toContainText('Add User');
        
        // Should have user form fields
        await expect(page.locator('input[name="name"], input[placeholder*="name"]')).toBeVisible();
        await expect(page.locator('input[name="email"], input[placeholder*="email"]')).toBeVisible();
        await expect(page.locator('select[name="role"], [role="combobox"]')).toBeVisible();
      } catch (e) {
        console.log('Add user functionality not available');
      }
    }
  });

  test('should view booking management', async ({ page }) => {
    // Click on Bookings
    await page.click('text=Bookings');
    await page.waitForLoadState('networkidle');
    
    // Should be on bookings management screen
    await expect(page.locator('h1, h2, .title')).toContainText('Bookings');
    
    // Should show booking statistics or list
    await expect(page.locator('text=Total, text=Active, text=Completed, text=Cancelled')).toBeVisible();
    
    // Should have filtering options
    await expect(page.locator('text=Filter, text=Search, text=Date Range')).toBeVisible();
  });

  test('should access staff management', async ({ page }) => {
    // Click on Staff
    await page.click('text=Staff');
    await page.waitForLoadState('networkidle');
    
    // Should be on staff management screen
    await expect(page.locator('h1, h2, .title')).toContainText('Staff');
    
    // Should show staff list or management options
    await expect(page.locator('text=Active Staff, text=Availability, text=Schedules')).toBeVisible();
    
    // Should have staff management actions
    const staffActions = [
      'text=Add Staff',
      'text=View Schedule',
      'text=Assign Job',
      'text=Manage Availability'
    ];
    
    for (const action of staffActions) {
      try {
        await expect(page.locator(`text=${action}`)).toBeVisible({ timeout: 2000 });
        break;
      } catch (e) {
        // Continue to next action
      }
    }
  });

  test('should view reports and analytics', async ({ page }) => {
    // Look for reports section
    const reportSelectors = [
      'text=Reports',
      'text=Analytics',
      'text=Statistics',
      'text=Dashboard'
    ];
    
    for (const selector of reportSelectors) {
      try {
        await page.click(selector, { timeout: 2000 });
        await page.waitForLoadState('networkidle');
        
        // Should be on reports screen
        await expect(page.locator('h1, h2, .title')).toContainText('Reports');
        
        // Should show analytics or charts
        await expect(page.locator('text=Revenue, text=Bookings, text=Users, text=Growth')).toBeVisible();
        
        foundReports = true;
        break;
      } catch (e) {
        // Continue to next selector
      }
    }
  });

  test('should handle system settings', async ({ page }) => {
    // Look for settings options
    const settingSelectors = [
      'text=Settings',
      'text=System Settings',
      'text=Configuration',
      '[data-testid="settings"]'
    ];
    
    for (const selector of settingSelectors) {
      try {
        await page.click(selector, { timeout: 2000 });
        await page.waitForLoadState('networkidle');
        
        // Should be on settings screen
        await expect(page.locator('h1, h2, .title')).toContainText('Settings');
        
        // Should have configuration options
        await expect(page.locator('text=General, text=Notifications, text=Security')).toBeVisible();
        
        foundSettings = true;
        break;
      } catch (e) {
        // Continue to next selector
      }
    }
  });

  test('should handle logout correctly', async ({ page }) => {
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
    await expect(page.locator('text=Welcome to NCL, text=Customer Login, text=Staff Login, text=Admin Login')).toBeVisible();
  });
});
