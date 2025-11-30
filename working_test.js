// working_test.js - Fixed selectors for Playwright
const { chromium } = require('playwright');

async function runWorkingTest() {
  console.log('🚀 Starting working test on port 8080...');
  
  const browser = await chromium.launch({ headless: false });
  const page = await browser.newPage();
  
  try {
    // Go to your Flutter app on port 8080
    await page.goto('http://localhost:8080');
    await page.waitForTimeout(5000);
    
    // Take screenshot of initial state
    await page.screenshot({ path: 'test-results/working-app-loaded.png' });
    console.log('✅ App loaded - screenshot taken');
    
    // Look for Customer Login button (fixed selector)
    const customerButton = page.locator('button', { hasText: 'Customer Login' });
    
    if (await customerButton.isVisible({ timeout: 10000 })) {
      console.log('✅ Customer Login button found');
      
      await page.screenshot({ path: 'test-results/working-before-customer-click.png' });
      
      await customerButton.click();
      await page.waitForTimeout(3000);
      
      await page.screenshot({ path: 'test-results/working-after-customer-click.png' });
      console.log('✅ Customer Login button clicked');
      
      // Look for email field
      const emailField = page.locator('input[type="email"], input[type="text"]');
      if (await emailField.isVisible({ timeout: 5000 })) {
        console.log('✅ Email field found');
        await emailField.fill('customer@example.com');
        await page.waitForTimeout(500);
      }
      
      // Look for password field
      const passwordField = page.locator('input[type="password"]');
      if (await passwordField.isVisible({ timeout: 5000 })) {
        console.log('✅ Password field found');
        await passwordField.fill('customer123');
        await page.waitForTimeout(500);
      }
      
      await page.screenshot({ path: 'test-results/working-filled-form.png' });
      console.log('✅ Form filled - screenshot taken');
      
      // Look for login button
      const loginButton = page.locator('button', { hasText: 'Sign In' }).or(page.locator('button', { hasText: 'Login' }));
      if (await loginButton.isVisible({ timeout: 3000 })) {
        await loginButton.click();
        await page.waitForTimeout(3000);
        await page.screenshot({ path: 'test-results/working-after-login.png' });
        console.log('✅ Login button clicked');
      }
      
    } else {
      console.log('⚠️ Customer Login button not found - debugging...');
      
      await page.screenshot({ path: 'test-results/working-debug.png' });
      
      // Look for any buttons
      const allButtons = page.locator('button');
      const buttonCount = await allButtons.count();
      console.log(`Found ${buttonCount} buttons`);
      
      for (let i = 0; i < Math.min(buttonCount, 5); i++) {
        try {
          const buttonText = await allButtons.nth(i).textContent();
          console.log(`Button ${i + 1}: "${buttonText}"`);
        } catch (e) {
          console.log(`Button ${i + 1}: Could not get text`);
        }
      }
    }
    
    // Test Staff Access button
    await page.goto('http://localhost:8080');
    await page.waitForTimeout(3000);
    
    const staffButton = page.locator('button', { hasText: 'Staff Access' });
    
    if (await staffButton.isVisible({ timeout: 5000 })) {
      console.log('✅ Staff Access button found');
      await staffButton.click();
      await page.waitForTimeout(2000);
      await page.screenshot({ path: 'test-results/working-staff-clicked.png' });
      console.log('✅ Staff Access button clicked');
    } else {
      console.log('⚠️ Staff Access button not found');
    }
    
    // Test Admin Portal button
    await page.goto('http://localhost:8080');
    await page.waitForTimeout(3000);
    
    const adminButton = page.locator('button', { hasText: 'Admin Portal' });
    
    if (await adminButton.isVisible({ timeout: 5000 })) {
      console.log('✅ Admin Portal button found');
      await adminButton.click();
      await page.waitForTimeout(2000);
      await page.screenshot({ path: 'test-results/working-admin-clicked.png' });
      console.log('✅ Admin Portal button clicked');
    } else {
      console.log('⚠️ Admin Portal button not found');
    }
    
    console.log('🎉 Working test completed successfully!');
    
  } catch (error) {
    console.error('❌ Test failed:', error.message);
    
    try {
      await page.screenshot({ path: 'test-results/working-error.png' });
      console.log('📸 Error screenshot taken');
    } catch (screenshotError) {
      console.log('Could not take error screenshot');
    }
  } finally {
    await browser.close();
    console.log('🔚 Browser closed');
  }
}

runWorkingTest().catch(console.error);
