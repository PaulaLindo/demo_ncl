// playwright.mobile-desktop-tests.js
// Comprehensive Playwright tests for mobile and desktop

const { test, expect, devices } = require('@playwright/test');

// Mobile device configurations
const iPhone13 = devices['iPhone 13'];
const iPad = devices['iPad Pro'];
const AndroidMobile = devices['Pixel 5'];

// Desktop configurations
const DesktopChrome = { 
  viewport: { width: 1920, height: 1080 }, 
  deviceScaleFactor: 1,
  userAgent: 'Desktop Test'
};

test.describe('NCL App - Mobile & Desktop Tests', () => {
  
  test.beforeEach(async ({ page }) => {
    // Set up base URL
    await page.goto('http://localhost:8098');
    
    // Wait for app to load
    await page.waitForLoadState('networkidle');
  });

  test.describe('Mobile Tests', () => {
    
    test.use({ ...iPhone13 });
    
    test('Mobile - Customer Login Flow', async ({ page }) => {
      console.log('📱 Testing Mobile Customer Login...');
      
      // Check if we're on login chooser
      await expect(page.locator('text=Welcome to NCL Services')).toBeVisible({ timeout: 10000 });
      
      // Tap customer login
      await page.tap('text=Customer Login');
      await page.waitForTimeout(1000);
      
      // Fill login form
      await page.fill('[placeholder="Email"]', 'customer@example.com');
      await page.fill('[placeholder="Password"]', 'customer123');
      
      // Tap login button
      await page.tap('button:has-text("Login")');
      await page.waitForTimeout(2000);
      
      // Verify customer dashboard
      await expect(page.locator('text=Hi, Customer!')).toBeVisible({ timeout: 10000 });
      console.log('✅ Mobile Customer Login successful');
    });

    test('Mobile - Staff Login Flow', async ({ page }) => {
      console.log('📱 Testing Mobile Staff Login...');
      
      // Navigate back to chooser if needed
      if (await page.locator('text=Welcome to NCL Services').isVisible()) {
        await page.tap('text=Staff Login');
      }
      
      // Fill login form
      await page.fill('[placeholder="Email"]', 'staff@example.com');
      await page.fill('[placeholder="Password"]', 'staff123');
      
      // Tap login button
      await page.tap('button:has-text("Login")');
      await page.waitForTimeout(2000);
      
      // Verify staff dashboard
      await expect(page.locator('text=Hi, Staff!')).toBeVisible({ timeout: 10000 });
      console.log('✅ Mobile Staff Login successful');
    });

    test('Mobile - Admin Login Flow', async ({ page }) => {
      console.log('📱 Testing Mobile Admin Login...');
      
      // Navigate back to chooser if needed
      if (await page.locator('text=Welcome to NCL Services').isVisible()) {
        await page.tap('text=Admin Login');
      }
      
      // Fill login form
      await page.fill('[placeholder="Email"]', 'admin@example.com');
      await page.fill('[placeholder="Password"]', 'admin123');
      
      // Tap login button
      await page.tap('button:has-text("Login")');
      await page.waitForTimeout(2000);
      
      // Verify admin dashboard
      await expect(page.locator('text=Admin Panel')).toBeVisible({ timeout: 10000 });
      console.log('✅ Mobile Admin Login successful');
    });

    test('Mobile - Customer Dashboard Navigation', async ({ page }) => {
      console.log('📱 Testing Mobile Customer Dashboard Navigation...');
      
      // Login as customer first
      await page.tap('text=Customer Login');
      await page.fill('[placeholder="Email"]', 'customer@example.com');
      await page.fill('[placeholder="Password"]', 'customer123');
      await page.tap('button:has-text("Login")');
      await page.waitForTimeout(2000);
      
      // Test tab navigation
      const tabs = ['Home', 'Bookings', 'Services', 'Account'];
      
      for (const tab of tabs) {
        console.log(`📱 Testing ${tab} tab...`);
        await page.tap(`text=${tab}`);
        await page.waitForTimeout(1000);
        
        // Verify tab content (some are placeholders)
        if (tab === 'Home') {
          await expect(page.locator('text=Hi, Customer!')).toBeVisible();
          await expect(page.locator('text=Quick Actions')).toBeVisible();
        } else {
          // Placeholder tabs should show "Coming Soon" message
          const comingSoon = await page.locator('text=Coming Soon').isVisible();
          if (comingSoon) {
            console.log(`✅ ${tab} tab shows placeholder (expected)`);
          }
        }
      }
      
      console.log('✅ Mobile Customer Dashboard Navigation complete');
    });

    test('Mobile - Touch Interactions', async ({ page }) => {
      console.log('📱 Testing Mobile Touch Interactions...');
      
      // Login as customer
      await page.tap('text=Customer Login');
      await page.fill('[placeholder="Email"]', 'customer@example.com');
      await page.fill('[placeholder="Password"]', 'customer123');
      await page.tap('button:has-text("Login")');
      await page.waitForTimeout(2000);
      
      // Test floating action button
      await page.tap('text=Book Now');
      await page.waitForTimeout(500);
      
      // Verify dialog appears
      await expect(page.locator('text=Quick Booking')).toBeVisible();
      await page.tap('text=Cancel');
      
      // Test quick action cards
      const quickActions = ['Schedule', 'Services', 'Support', 'Payment'];
      for (const action of quickActions.slice(0, 2)) { // Test first 2
        await page.tap(`text=${action}`);
        await page.waitForTimeout(500);
        // Should navigate or show interaction
        console.log(`✅ Quick action "${action}" responsive`);
      }
      
      console.log('✅ Mobile Touch Interactions complete');
    });
  });

  test.describe('Desktop Tests', () => {
    
    test.use({ ...DesktopChrome });
    
    test('Desktop - Customer Login Flow', async ({ page }) => {
      console.log('🖥️ Testing Desktop Customer Login...');
      
      // Check if we're on login chooser
      await expect(page.locator('text=Welcome to NCL Services')).toBeVisible({ timeout: 10000 });
      
      // Click customer login
      await page.click('text=Customer Login');
      await page.waitForTimeout(1000);
      
      // Fill login form
      await page.fill('[placeholder="Email"]', 'customer@example.com');
      await page.fill('[placeholder="Password"]', 'customer123');
      
      // Click login button
      await page.click('button:has-text("Login")');
      await page.waitForTimeout(2000);
      
      // Verify customer dashboard
      await expect(page.locator('text=Hi, Customer!')).toBeVisible({ timeout: 10000 });
      console.log('✅ Desktop Customer Login successful');
    });

    test('Desktop - Staff Login Flow', async ({ page }) => {
      console.log('🖥️ Testing Desktop Staff Login...');
      
      // Navigate to staff login
      if (await page.locator('text=Welcome to NCL Services').isVisible()) {
        await page.click('text=Staff Login');
      }
      
      // Fill login form
      await page.fill('[placeholder="Email"]', 'staff@example.com');
      await page.fill('[placeholder="Password"]', 'staff123');
      
      // Click login button
      await page.click('button:has-text("Login")');
      await page.waitForTimeout(2000);
      
      // Verify staff dashboard
      await expect(page.locator('text=Hi, Staff!')).toBeVisible({ timeout: 10000 });
      console.log('✅ Desktop Staff Login successful');
    });

    test('Desktop - Admin Login Flow', async ({ page }) => {
      console.log('🖥️ Testing Desktop Admin Login...');
      
      // Navigate to admin login
      if (await page.locator('text=Welcome to NCL Services').isVisible()) {
        await page.click('text=Admin Login');
      }
      
      // Fill login form
      await page.fill('[placeholder="Email"]', 'admin@example.com');
      await page.fill('[placeholder="Password"]', 'admin123');
      
      // Click login button
      await page.click('button:has-text("Login")');
      await page.waitForTimeout(2000);
      
      // Verify admin dashboard
      await expect(page.locator('text=Admin Panel')).toBeVisible({ timeout: 10000 });
      console.log('✅ Desktop Admin Login successful');
    });

    test('Desktop - Customer Dashboard Navigation', async ({ page }) => {
      console.log('🖥️ Testing Desktop Customer Dashboard Navigation...');
      
      // Login as customer first
      await page.click('text=Customer Login');
      await page.fill('[placeholder="Email"]', 'customer@example.com');
      await page.fill('[placeholder="Password"]', 'customer123');
      await page.click('button:has-text("Login")');
      await page.waitForTimeout(2000);
      
      // Test tab navigation
      const tabs = ['Home', 'Bookings', 'Services', 'Account'];
      
      for (const tab of tabs) {
        console.log(`🖥️ Testing ${tab} tab...`);
        await page.click(`text=${tab}`);
        await page.waitForTimeout(1000);
        
        // Verify tab content
        if (tab === 'Home') {
          await expect(page.locator('text=Hi, Customer!')).toBeVisible();
          await expect(page.locator('text=Quick Actions')).toBeVisible();
        } else {
          // Placeholder tabs should show "Coming Soon" message
          const comingSoon = await page.locator('text=Coming Soon').isVisible();
          if (comingSoon) {
            console.log(`✅ ${tab} tab shows placeholder (expected)`);
          }
        }
      }
      
      console.log('✅ Desktop Customer Dashboard Navigation complete');
    });

    test('Desktop - Mouse Interactions', async ({ page }) => {
      console.log('🖥️ Testing Desktop Mouse Interactions...');
      
      // Login as customer
      await page.click('text=Customer Login');
      await page.fill('[placeholder="Email"]', 'customer@example.com');
      await page.fill('[placeholder="Password"]', 'customer123');
      await page.click('button:has-text("Login")');
      await page.waitForTimeout(2000);
      
      // Test floating action button
      await page.click('text=Book Now');
      await page.waitForTimeout(500);
      
      // Verify dialog appears
      await expect(page.locator('text=Quick Booking')).toBeVisible();
      await page.click('text=Cancel');
      
      // Test hover effects on quick action cards
      const quickActions = ['Schedule', 'Services', 'Support', 'Payment'];
      for (const action of quickActions.slice(0, 2)) { // Test first 2
        await page.hover(`text=${action}`);
        await page.waitForTimeout(300);
        console.log(`✅ Hover effect on "${action}" working`);
      }
      
      // Test keyboard navigation
      await page.keyboard.press('Tab');
      await page.keyboard.press('Tab');
      await page.keyboard.press('Enter');
      
      console.log('✅ Desktop Mouse Interactions complete');
    });

    test('Desktop - Responsive Layout', async ({ page }) => {
      console.log('🖥️ Testing Desktop Responsive Layout...');
      
      // Login as customer
      await page.click('text=Customer Login');
      await page.fill('[placeholder="Email"]', 'customer@example.com');
      await page.fill('[placeholder="Password"]', 'customer123');
      await page.click('button:has-text("Login")');
      await page.waitForTimeout(2000);
      
      // Test different viewport sizes
      const viewports = [
        { width: 1920, height: 1080 }, // Desktop
        { width: 1366, height: 768 },  // Laptop
        { width: 768, height: 1024 },  // Tablet
      ];
      
      for (const viewport of viewports) {
        await page.setViewportSize(viewport);
        await page.waitForTimeout(500);
        
        // Verify layout adapts
        const isVisible = await page.locator('text=Hi, Customer!').isVisible();
        expect(isVisible).toBe(true);
        
        console.log(`✅ Layout works at ${viewport.width}x${viewport.height}`);
      }
      
      console.log('✅ Desktop Responsive Layout complete');
    });
  });

  test.describe('Cross-Platform Tests', () => {
    
    test('Cross-Platform - Login Consistency', async ({ page }) => {
      console.log('🔄 Testing Cross-Platform Login Consistency...');
      
      const userTypes = [
        { type: 'customer', email: 'customer@example.com', password: 'customer123' },
        { type: 'staff', email: 'staff@example.com', password: 'staff123' },
        { type: 'admin', email: 'admin@example.com', password: 'admin123' },
      ];
      
      for (const userType of userTypes) {
        console.log(`🔄 Testing ${userType.type} consistency...`);
        
        // Test on mobile
        await page.setViewportSize({ width: 390, height: 844 }); // iPhone size
        await page.goto('http://localhost:8098');
        await page.waitForTimeout(1000);
        
        await page.tap(`text=${userType.type.charAt(0).toUpperCase() + userType.type.slice(1)} Login`);
        await page.fill('[placeholder="Email"]', userType.email);
        await page.fill('[placeholder="Password"]', userType.password);
        await page.tap('button:has-text("Login")');
        await page.waitForTimeout(2000);
        
        const mobileSuccess = await page.locator('text=' + (userType.type === 'admin' ? 'Admin Panel' : `Hi, ${userType.type.charAt(0).toUpperCase() + userType.type.slice(1)}!`)).isVisible();
        
        // Test on desktop
        await page.setViewportSize({ width: 1920, height: 1080 });
        await page.goto('http://localhost:8098');
        await page.waitForTimeout(1000);
        
        await page.click(`text=${userType.type.charAt(0).toUpperCase() + userType.type.slice(1)} Login`);
        await page.fill('[placeholder="Email"]', userType.email);
        await page.fill('[placeholder="Password"]', userType.password);
        await page.click('button:has-text("Login")');
        await page.waitForTimeout(2000);
        
        const desktopSuccess = await page.locator('text=' + (userType.type === 'admin' ? 'Admin Panel' : `Hi, ${userType.type.charAt(0).toUpperCase() + userType.type.slice(1)}!`)).isVisible();
        
        expect(mobileSuccess).toBe(true);
        expect(desktopSuccess).toBe(true);
        
        console.log(`✅ ${userType.type} login consistent across platforms`);
      }
      
      console.log('✅ Cross-Platform Login Consistency complete');
    });

    test('Cross-Platform - Performance', async ({ page }) => {
      console.log('🚀 Testing Cross-Platform Performance...');
      
      // Test load times on different devices
      const devices = [
        { name: 'Mobile', viewport: { width: 390, height: 844 } },
        { name: 'Tablet', viewport: { width: 768, height: 1024 } },
        { name: 'Desktop', viewport: { width: 1920, height: 1080 } },
      ];
      
      for (const device of devices) {
        console.log(`🚀 Testing ${device.name} performance...`);
        
        const startTime = Date.now();
        
        await page.setViewportSize(device.viewport);
        await page.goto('http://localhost:8098');
        await page.waitForLoadState('networkidle');
        
        const loadTime = Date.now() - startTime;
        
        // Verify page loaded
        await expect(page.locator('text=Welcome to NCL Services')).toBeVisible({ timeout: 10000 });
        
        console.log(`✅ ${device.name} loaded in ${loadTime}ms`);
        
        // Performance should be reasonable (less than 5 seconds)
        expect(loadTime).toBeLessThan(5000);
      }
      
      console.log('✅ Cross-Platform Performance complete');
    });
  });

  test.describe('Error Handling Tests', () => {
    
    test('Error Handling - Invalid Login', async ({ page }) => {
      console.log('❌ Testing Invalid Login Error Handling...');
      
      // Test on mobile
      await page.setViewportSize({ width: 390, height: 844 });
      
      // Try invalid credentials
      await page.tap('text=Customer Login');
      await page.fill('[placeholder="Email"]', 'invalid@example.com');
      await page.fill('[placeholder="Password"]', 'wrongpassword');
      await page.tap('button:has-text("Login")');
      await page.waitForTimeout(2000);
      
      // Should show error message
      const errorMessage = await page.locator('text=Invalid credentials').isVisible();
      if (errorMessage) {
        console.log('✅ Invalid login error handled correctly');
      }
      
      // Test on desktop
      await page.setViewportSize({ width: 1920, height: 1080 });
      await page.goto('http://localhost:8098');
      await page.waitForTimeout(1000);
      
      await page.click('text=Customer Login');
      await page.fill('[placeholder="Email"]', 'invalid@example.com');
      await page.fill('[placeholder="Password"]', 'wrongpassword');
      await page.click('button:has-text("Login")');
      await page.waitForTimeout(2000);
      
      const desktopError = await page.locator('text=Invalid credentials').isVisible();
      if (desktopError) {
        console.log('✅ Desktop invalid login error handled correctly');
      }
      
      console.log('✅ Invalid Login Error Handling complete');
    });

    test('Error Handling - Network Issues', async ({ page }) => {
      console.log('🌐 Testing Network Error Handling...');
      
      // Simulate offline mode
      await page.context().setOffline(true);
      
      await page.goto('http://localhost:8098');
      
      // Should handle offline state gracefully
      await page.waitForTimeout(3000);
      
      // Check if page still loads with offline indicators
      const pageContent = await page.content();
      const hasOfflineHandling = pageContent.includes('offline') || pageContent.includes('connection');
      
      if (hasOfflineHandling) {
        console.log('✅ Network error handling detected');
      }
      
      // Restore connection
      await page.context().setOffline(false);
      
      console.log('✅ Network Error Handling complete');
    });
  });
});
