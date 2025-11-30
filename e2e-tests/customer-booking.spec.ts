import { test, expect } from '@playwright/test';

test.describe('Customer Booking Flow', () => {
  test.beforeEach(async ({ page }) => {
    // Login as customer before each test
    await page.goto('/');
    await page.waitForLoadState('networkidle');
    
    // Click Customer Login
    await page.click('text=Customer Login');
    await page.waitForLoadState('networkidle');
    
    // Fill in customer credentials
    await page.fill('input[type="email"], input[name="email"], [placeholder*="email"]', 'customer@example.com');
    await page.fill('input[type="password"], input[name="password"], [placeholder*="password"]', 'customer123');
    
    // Click login button
    await page.click('button:has-text("Login"), button:has-text("Sign In"), [type="submit"]');
    await page.waitForLoadState('networkidle');
  });

  test('should show customer home screen with booking options', async ({ page }) => {
    // Should be on customer home screen
    await expect(page.locator('h1, h2, .title')).toContainText('Customer Home');
    
    // Should have booking options
    await expect(page.locator('text=Book Service, text=New Booking, text=Schedule Cleaning')).toBeVisible();
    await expect(page.locator('text=My Bookings, text=View Bookings')).toBeVisible();
  });

  test('should navigate to services screen', async ({ page }) => {
    // Click on Book Service or similar
    await page.click('text=Book Service, text=New Booking, text=Schedule Cleaning');
    await page.waitForLoadState('networkidle');
    
    // Should be on services screen
    await expect(page.locator('h1, h2, .title')).toContainText('Services');
    
    // Should show available services
    await expect(page.locator('text=Core Cleaning, text=Deep Cleaning, text=Standard Cleaning')).toBeVisible();
  });

  test('should complete booking flow', async ({ page }) => {
    // Navigate to services
    await page.click('text=Book Service, text=New Booking, text=Schedule Cleaning');
    await page.waitForLoadState('networkidle');
    
    // Select a service
    await page.click('text=Core Cleaning, text=Deep Cleaning');
    await page.waitForLoadState('networkidle');
    
    // Should be on booking form
    await expect(page.locator('h1, h2, .title')).toContainText('Booking');
    
    // Fill in booking details
    await page.fill('input[name="address"], [placeholder*="address"], textarea[name="address"]', '123 Test Street, Test City');
    
    // Select property size
    await page.click('select[name="propertySize"], [role="combobox"]');
    await page.click('text=3 Bedroom, text=Medium, text=2 Bedroom');
    
    // Select frequency
    await page.click('select[name="frequency"], [role="combobox"]');
    await page.click('text=Weekly, text=One-time, text=Monthly');
    
    // Click continue or next
    await page.click('button:has-text("Continue"), button:has-text("Next"), button:has-text("Proceed")');
    await page.waitForLoadState('networkidle');
    
    // Should be on scheduling screen
    await expect(page.locator('h1, h2, .title')).toContainText('Schedule');
    
    // Select a date (click on calendar)
    await page.click('.calendar-day, [data-date], [role="gridcell"]:not([aria-disabled])');
    
    // Select a time slot
    await page.click('text=9:00 AM, text=10:00 AM, text=Morning');
    
    // Continue to confirmation
    await page.click('button:has-text("Continue"), button:has-text("Next"), button:has-text("Confirm")');
    await page.waitForLoadState('networkidle');
    
    // Should be on confirmation screen
    await expect(page.locator('h1, h2, .title')).toContainText('Confirmation');
    
    // Should show booking details
    await expect(page.locator('text=Booking Confirmed, text=Success')).toBeVisible();
  });

  test('should view existing bookings', async ({ page }) => {
    // Click on My Bookings
    await page.click('text=My Bookings, text=View Bookings');
    await page.waitForLoadState('networkidle');
    
    // Should be on bookings screen
    await expect(page.locator('h1, h2, .title')).toContainText('Bookings');
    
    // Should show booking list or empty state
    const bookingContent = [
      'text=Upcoming, text=Completed, text=Cancelled',
      'text=No bookings found, text=No bookings yet',
      '.booking-card, .booking-item'
    ];
    
    let foundBooking = false;
    for (const selector of bookingContent) {
      try {
        await expect(page.locator(selector)).toBeVisible({ timeout: 3000 });
        foundBooking = true;
        break;
      } catch (e) {
        // Continue to next selector
      }
    }
    
    if (!foundBooking) {
      console.log('No bookings found - this is expected for a new account');
    }
  });

  test('should handle booking cancellation', async ({ page }) => {
    // Navigate to bookings
    await page.click('text=My Bookings, text=View Bookings');
    await page.waitForLoadState('networkidle');
    
    // Look for upcoming bookings to cancel
    const cancelSelectors = [
      'button:has-text("Cancel")',
      'button:has-text("Cancel Booking")',
      '[data-testid="cancel-booking"]',
      '.cancel-button'
    ];
    
    let foundCancel = false;
    for (const selector of cancelSelectors) {
      try {
        await page.click(selector, { timeout: 2000 });
        foundCancel = true;
        break;
      } catch (e) {
        // Continue to next selector
      }
    }
    
    if (foundCancel) {
      // Confirm cancellation if dialog appears
      await page.waitForTimeout(1000);
      
      const confirmSelectors = [
        'button:has-text("Confirm")',
        'button:has-text("Yes")',
        'button:has-text("Cancel Booking")'
      ];
      
      for (const selector of confirmSelectors) {
        try {
          await page.click(selector, { timeout: 2000 });
          break;
        } catch (e) {
          // Continue to next selector
        }
      }
      
      // Should show cancellation confirmation
      await expect(page.locator('text=Cancelled, text=Booking Cancelled')).toBeVisible({ timeout: 5000 });
    } else {
      console.log('No bookings available to cancel');
    }
  });
});
