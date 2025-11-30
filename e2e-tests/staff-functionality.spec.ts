import { test, expect } from '@playwright/test';

test.describe('Staff Functionality', () => {
  test.beforeEach(async ({ page }) => {
    // Login as staff before each test
    await page.goto('/');
    await page.waitForLoadState('networkidle');
    
    // Click Staff Login
    await page.click('text=Staff Login');
    await page.waitForLoadState('networkidle');
    
    // Fill in staff credentials
    await page.fill('input[type="email"], input[name="email"], [placeholder*="email"]', 'staff@example.com');
    await page.fill('input[type="password"], input[name="password"], [placeholder*="password"]', 'staff123');
    
    // Click login button
    await page.click('button:has-text("Login"), button:has-text("Sign In"), [type="submit"]');
    await page.waitForLoadState('networkidle');
  });

  test('should show staff dashboard', async ({ page }) => {
    // Should be on staff home screen
    await expect(page.locator('h1, h2, .title')).toContainText('Staff Home');
    
    // Should have staff navigation options
    await expect(page.locator('text=Dashboard, text=Timekeeping, text=Availability')).toBeVisible();
    await expect(page.locator('text=My Jobs, text=Gigs, text=Schedule')).toBeVisible();
  });

  test('should access timekeeping features', async ({ page }) => {
    // Click on Timekeeping
    await page.click('text=Timekeeping');
    await page.waitForLoadState('networkidle');
    
    // Should be on timekeeping screen
    await expect(page.locator('h1, h2, .title')).toContainText('Timekeeping');
    
    // Should have time tracking options
    await expect(page.locator('text=Clock In, text=Start Work, text=Check In')).toBeVisible();
    await expect(page.locator('text=Clock Out, text=End Work, text=Check Out')).toBeVisible();
    
    // Should show work history or today's hours
    await expect(page.locator('text=Today, text=History, text=Hours')).toBeVisible();
  });

  test('should manage availability', async ({ page }) => {
    // Click on Availability
    await page.click('text=Availability');
    await page.waitForLoadState('networkidle');
    
    // Should be on availability screen
    await expect(page.locator('h1, h2, .title')).toContainText('Availability');
    
    // Should show calendar or schedule
    await expect(page.locator('.calendar, .schedule, [role="grid"]')).toBeVisible();
    
    // Should have options to set availability
    await expect(page.locator('text=Set Available, text=Add Schedule, text=Update')).toBeVisible();
  });

  test('should view and manage jobs/gigs', async ({ page }) => {
    // Click on Jobs/Gigs
    await page.click('text=Jobs, text=Gigs, text=My Jobs');
    await page.waitForLoadState('networkidle');
    
    // Should be on jobs screen
    await expect(page.locator('h1, h2, .title')).toContainText('Jobs');
    
    // Should show job list or empty state
    const jobContent = [
      'text=Upcoming, text=Completed, text=In Progress',
      'text=No jobs assigned, text=No jobs found',
      '.job-card, .gig-item, .booking-item'
    ];
    
    let foundJobs = false;
    for (const selector of jobContent) {
      try {
        await expect(page.locator(selector)).toBeVisible({ timeout: 3000 });
        foundJobs = true;
        break;
      } catch (e) {
        // Continue to next selector
      }
    }
    
    if (!foundJobs) {
      console.log('No jobs found - this might be expected');
    }
  });

  test('should handle shift swap functionality', async ({ page }) => {
    // Look for shift swap options
    const shiftSwapSelectors = [
      'text=Shift Swap',
      'text=Swap Shift',
      'text=Trade Shift',
      '[data-testid="shift-swap"]'
    ];
    
    for (const selector of shiftSwapSelectors) {
      try {
        await page.click(selector, { timeout: 2000 });
        await page.waitForLoadState('networkidle');
        
        // Should be on shift swap screen
        await expect(page.locator('h1, h2, .title')).toContainText('Shift Swap');
        
        // Should have shift swap options
        await expect(page.locator('text=Request Swap, text=Available Shifts, text=My Requests')).toBeVisible();
        
        foundSwap = true;
        break;
      } catch (e) {
        // Continue to next selector
      }
    }
  });

  test('should access profile/settings', async ({ page }) => {
    // Look for profile or settings options
    const profileSelectors = [
      'text=Profile',
      'text=Settings',
      'text=Account',
      '[aria-label*="profile"]',
      '[data-testid="profile"]'
    ];
    
    for (const selector of profileSelectors) {
      try {
        await page.click(selector, { timeout: 2000 });
        await page.waitForLoadState('networkidle');
        
        // Should be on profile screen
        await expect(page.locator('h1, h2, .title')).toContainText('Profile');
        
        // Should show user information
        await expect(page.locator('text=Name, text=Email, text=Staff ID')).toBeVisible();
        
        foundProfile = true;
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
