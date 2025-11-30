import { test, expect } from '@playwright/test';

test.describe('React App Debug Tests', () => {
  test('debug home page loading', async ({ page }) => {
    console.log('🔍 Starting React app debug test...');
    
    // Enable console logging
    const consoleMessages = [];
    page.on('console', msg => {
      consoleMessages.push({
        type: msg.type(),
        text: msg.text(),
        location: msg.location()
      });
      console.log(`📝 Console [${msg.type()}]: ${msg.text()}`);
    });

    // Enable error logging
    page.on('pageerror', error => {
      console.error('🚨 Page Error:', error.message);
      console.error('🚨 Stack:', error.stack);
    });

    // Enable request logging
    page.on('request', request => {
      console.log(`🌐 Request: ${request.method()} ${request.url()}`);
    });

    page.on('response', response => {
      console.log(`📦 Response: ${response.status()} ${response.url()}`);
    });

    try {
      // Navigate to the home page
      console.log('🚀 Navigating to home page...');
      await page.goto('/', { waitUntil: 'networkidle' });
      
      // Wait a bit for any dynamic content
      await page.waitForTimeout(3000);
      
      // Check page title
      const title = await page.title();
      console.log(`📄 Page title: ${title}`);
      expect(title).toContain('NCL');
      
      // Check if the root element exists
      const rootElement = await page.locator('#root').count();
      console.log(`🌱 Root element count: ${rootElement}`);
      expect(rootElement).toBe(1);
      
      // Check what's inside the root element
      const rootContent = await page.locator('#root').innerHTML();
      console.log(`📦 Root element content length: ${rootContent.length}`);
      console.log(`📦 Root element content preview: ${rootContent.substring(0, 500)}`);
      
      // Check for loading spinner
      const loadingSpinner = await page.locator('.loading, [class*="loading"], [class*="spinner"]').count();
      console.log(`⏳ Loading spinner count: ${loadingSpinner}`);
      
      // Check for any text content
      const bodyText = await page.locator('body').textContent();
      console.log(`📝 Body text length: ${bodyText.length}`);
      console.log(`📝 Body text preview: ${bodyText.substring(0, 200)}`);
      
      // Check for specific React elements
      const reactElements = await page.locator('[data-reactroot], [data-testid]').count();
      console.log(`⚛️ React elements count: ${reactElements}`);
      
      // Check for any error messages
      const errorElements = await page.locator('[class*="error"], [class*="Error"]').count();
      console.log(`❌ Error elements count: ${errorElements}`);
      
      // Check if there are any console errors
      const errors = consoleMessages.filter(msg => msg.type === 'error');
      console.log(`🚨 Console errors: ${errors.length}`);
      errors.forEach(error => {
        console.log(`🚨 Error: ${error.text}`);
      });
      
      // Check if there are any warnings
      const warnings = consoleMessages.filter(msg => msg.type === 'warning');
      console.log(`⚠️ Console warnings: ${warnings.length}`);
      warnings.forEach(warning => {
        console.log(`⚠️ Warning: ${warning.text}`);
      });
      
      // Take a screenshot for visual inspection
      await page.screenshot({ path: 'test-results/react-home-debug.png', fullPage: true });
      console.log('📸 Screenshot saved to test-results/react-home-debug.png');
      
      // Check if the page is actually blank or just loading
      if (rootContent.length === 0) {
        console.log('⚠️ Root element is empty - possible rendering issue');
      } else if (rootContent.includes('loading') || rootContent.includes('Loading')) {
        console.log('⏳ Page is still loading...');
      } else {
        console.log('✅ Page has content');
      }
      
    } catch (error) {
      console.error('❌ Test failed:', error);
      await page.screenshot({ path: 'test-results/react-error-debug.png', fullPage: true });
      throw error;
    }
  });

  test('debug login page', async ({ page }) => {
    console.log('🔍 Testing login page...');
    
    // Enable console logging
    page.on('console', msg => {
      console.log(`📝 Console [${msg.type()}]: ${msg.text()}`);
    });

    page.on('pageerror', error => {
      console.error('🚨 Page Error:', error.message);
    });

    try {
      await page.goto('/login/customer', { waitUntil: 'networkidle' });
      await page.waitForTimeout(2000);
      
      // Check if login form exists
      const loginForm = await page.locator('form').count();
      console.log(`📝 Login form count: ${loginForm}`);
      
      // Check for email input
      const emailInput = await page.locator('input[type="email"]').count();
      console.log(`📧 Email input count: ${emailInput}`);
      
      // Check for password input
      const passwordInput = await page.locator('input[type="password"]').count();
      console.log(`🔒 Password input count: ${passwordInput}`);
      
      // Check for submit button
      const submitButton = await page.locator('button[type="submit"]').count();
      console.log(`🔘 Submit button count: ${submitButton}`);
      
      // Take screenshot
      await page.screenshot({ path: 'test-results/react-login-debug.png', fullPage: true });
      console.log('📸 Login screenshot saved');
      
    } catch (error) {
      console.error('❌ Login test failed:', error);
      await page.screenshot({ path: 'test-results/react-login-error.png', fullPage: true });
    }
  });

  test('debug device detection', async ({ page }) => {
    console.log('🔍 Testing device detection...');
    
    // Enable console logging
    page.on('console', msg => {
      console.log(`📝 Console [${msg.type()}]: ${msg.text()}`);
    });

    try {
      await page.goto('/', { waitUntil: 'networkidle' });
      await page.waitForTimeout(2000);
      
      // Check device classes on body
      const bodyClasses = await page.locator('body').getAttribute('class');
      console.log(`📱 Body classes: ${bodyClasses}`);
      
      // Check if device detection script ran
      const deviceClasses = bodyClasses ? bodyClasses.split(' ').filter(cls => cls.startsWith('device-')) : [];
      console.log(`📱 Device classes found: ${deviceClasses.join(', ')}`);
      
      // Take screenshot
      await page.screenshot({ path: 'test-results/react-device-debug.png', fullPage: true });
      
    } catch (error) {
      console.error('❌ Device detection test failed:', error);
      await page.screenshot({ path: 'test-results/react-device-error.png', fullPage: true });
    }
  });
});
