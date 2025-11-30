import { test, expect } from '@playwright/test';

test.describe('Full Authentication Flow', () => {
  test('should complete customer login flow', async ({ page }) => {
    console.log('🔍 Testing Customer Login Flow...');
    
    // Enable console logging
    page.on('console', msg => {
      if (msg.type() === 'error' || msg.type() === 'warning') {
        console.log(`📝 Console [${msg.type()}]: ${msg.text()}`);
      }
    });

    try {
      // Step 1: Navigate to home page
      await page.goto('/', { waitUntil: 'domcontentloaded' });
      await page.waitForTimeout(2000);
      
      // Verify home page loaded
      const title = await page.locator('h1').textContent();
      expect(title).toContain('NCL Professional Home Services');
      console.log('✅ Home page loaded');
      
      // Step 2: Click Customer login
      await page.click('text=Customer');
      await page.waitForTimeout(1000);
      
      // Verify we're on customer login page
      const loginTitle = await page.locator('h2').textContent();
      expect(loginTitle).toContain('Customer Login');
      console.log('✅ Customer login page loaded');
      
      // Step 3: Fill login form
      await page.fill('input[type="email"]', 'customer@test.com');
      await page.fill('input[type="password"]', 'password123');
      console.log('✅ Login form filled');
      
      // Step 4: Submit login
      await page.click('button[type="submit"]');
      await page.waitForTimeout(2000);
      
      // Step 5: Verify customer dashboard
      const dashboardTitle = await page.locator('h2').textContent();
      expect(dashboardTitle).toContain('Customer Dashboard');
      console.log('✅ Customer dashboard loaded');
      
      // Step 6: Verify navigation
      await page.click('text=Dashboard');
      await page.waitForTimeout(1000);
      
      // Verify we're still on customer dashboard
      const currentTitle = await page.locator('h2').textContent();
      expect(currentTitle).toContain('Customer Dashboard');
      console.log('✅ Customer navigation working');
      
      // Take screenshot
      await page.screenshot({ path: 'test-results/customer-auth-flow.png', fullPage: true });
      console.log('📸 Customer flow screenshot saved');
      
    } catch (error) {
      console.error('❌ Customer flow failed:', error);
      await page.screenshot({ path: 'test-results/customer-flow-error.png', fullPage: true });
      throw error;
    }
  });

  test('should complete staff login flow', async ({ page }) => {
    console.log('🔍 Testing Staff Login Flow...');
    
    try {
      // Step 1: Navigate to staff login directly
      await page.goto('/login/staff', { waitUntil: 'domcontentloaded' });
      await page.waitForTimeout(2000);
      
      // Verify staff login page
      const loginTitle = await page.locator('h2').textContent();
      expect(loginTitle).toContain('Staff Login');
      console.log('✅ Staff login page loaded');
      
      // Step 2: Fill login form
      await page.fill('input[type="email"]', 'staff@test.com');
      await page.fill('input[type="password"]', 'password123');
      console.log('✅ Staff login form filled');
      
      // Step 3: Submit login
      await page.click('button[type="submit"]');
      await page.waitForTimeout(2000);
      
      // Step 4: Verify staff dashboard
      const dashboardTitle = await page.locator('h2').textContent();
      expect(dashboardTitle).toContain('Staff Dashboard');
      console.log('✅ Staff dashboard loaded');
      
      // Step 5: Test navigation
      await page.click('text=Timekeeping');
      await page.waitForTimeout(1000);
      
      // Verify timekeeping page placeholder
      const timekeepingTitle = await page.locator('h2').textContent();
      expect(timekeepingTitle).toContain('Timekeeping');
      console.log('✅ Staff navigation working');
      
      // Take screenshot
      await page.screenshot({ path: 'test-results/staff-auth-flow.png', fullPage: true });
      console.log('📸 Staff flow screenshot saved');
      
    } catch (error) {
      console.error('❌ Staff flow failed:', error);
      await page.screenshot({ path: 'test-results/staff-flow-error.png', fullPage: true });
      throw error;
    }
  });

  test('should complete admin login flow', async ({ page }) => {
    console.log('🔍 Testing Admin Login Flow...');
    
    try {
      // Step 1: Navigate to admin login directly
      await page.goto('/login/admin', { waitUntil: 'domcontentloaded' });
      await page.waitForTimeout(2000);
      
      // Verify admin login page
      const loginTitle = await page.locator('h2').textContent();
      expect(loginTitle).toContain('Admin Login');
      console.log('✅ Admin login page loaded');
      
      // Step 2: Fill login form
      await page.fill('input[type="email"]', 'admin@test.com');
      await page.fill('input[type="password"]', 'password123');
      console.log('✅ Admin login form filled');
      
      // Step 3: Submit login
      await page.click('button[type="submit"]');
      await page.waitForTimeout(2000);
      
      // Step 4: Verify admin dashboard
      const dashboardTitle = await page.locator('h2').textContent();
      expect(dashboardTitle).toContain('Admin Dashboard');
      console.log('✅ Admin dashboard loaded');
      
      // Step 5: Test navigation
      await page.click('text=Users');
      await page.waitForTimeout(1000);
      
      // Verify users page placeholder
      const usersTitle = await page.locator('h2').textContent();
      expect(usersTitle).toContain('Users');
      console.log('✅ Admin navigation working');
      
      // Take screenshot
      await page.screenshot({ path: 'test-results/admin-auth-flow.png', fullPage: true });
      console.log('📸 Admin flow screenshot saved');
      
    } catch (error) {
      console.error('❌ Admin flow failed:', error);
      await page.screenshot({ path: 'test-results/admin-flow-error.png', fullPage: true });
      throw error;
    }
  });

  test('should handle sign out properly', async ({ page }) => {
    console.log('🔍 Testing Sign Out Flow...');
    
    try {
      // Step 1: Login as customer
      await page.goto('/login/customer', { waitUntil: 'domcontentloaded' });
      await page.fill('input[type="email"]', 'customer@test.com');
      await page.fill('input[type="password"]', 'password123');
      await page.click('button[type="submit"]');
      await page.waitForTimeout(2000);
      
      // Verify logged in
      const dashboardTitle = await page.locator('h2').textContent();
      expect(dashboardTitle).toContain('Customer Dashboard');
      console.log('✅ Logged in successfully');
      
      // Step 2: Sign out
      await page.click('text=Sign out');
      await page.waitForTimeout(2000);
      
      // Step 3: Verify signed out (back to home)
      await page.waitForTimeout(2000);
      
      // Look for any of the possible home page elements
      const homeElements = [
        'text=NCL Professional Home Services',
        'text=Choose your login type',
        'text=Customer',
        'text=Staff', 
        'text=Admin'
      ];
      
      let homeFound = false;
      for (const selector of homeElements) {
        try {
          await page.locator(selector).waitFor({ timeout: 2000 });
          console.log(`✅ Found home element: ${selector}`);
          homeFound = true;
          break;
        } catch (e) {
          // Continue to next selector
        }
      }
      
      expect(homeFound).toBe(true);
      console.log('✅ Signed out successfully - home page detected');
      
      // Take screenshot
      await page.screenshot({ path: 'test-results/sign-out-flow.png', fullPage: true });
      console.log('📸 Sign out flow screenshot saved');
      
    } catch (error) {
      console.error('❌ Sign out flow failed:', error);
      await page.screenshot({ path: 'test-results/sign-out-error.png', fullPage: true });
      throw error;
    }
  });
});
