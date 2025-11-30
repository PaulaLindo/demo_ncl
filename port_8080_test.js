// port_8080_test.js - Test on port 8080 (which is now working!)
const { chromium } = require('playwright');

async function runPort8080Test() {
  console.log('🚀 Starting test on port 8080...');
  
  const browser = await chromium.launch({ headless: false });
  const page = await browser.newPage();
  
  try {
    // Go to your Flutter app on port 8080
    await page.goto('http://localhost:8080');
    await page.waitForTimeout(5000); // Wait longer for Flutter app to load
    
    // Take screenshot of initial state
    await page.screenshot({ path: 'test-results/port-8080-app-loaded.png' });
    console.log('✅ App loaded on port 8080 - screenshot taken');
    
    // Look for Customer Login button (try multiple selectors)
    const customerButton = page.locator('button:has-text("Customer Login"), text=Customer Login, [role="button"] >> text="Customer Login", button >> text="Customer Login"');
    
    if (await customerButton.isVisible({ timeout: 10000 })) {
      console.log('✅ Customer Login button found');
      
      // Take screenshot before clicking
      await page.screenshot({ path: 'test-results/port-8080-before-customer-click.png' });
      
      // Click Customer Login button
      await customerButton.click();
      await page.waitForTimeout(3000);
      
      // Take screenshot after clicking
      await page.screenshot({ path: 'test-results/port-8080-after-customer-click.png' });
      console.log('✅ Customer Login button clicked');
      
      // Look for form elements
      const emailField = page.locator('input[type="email"], input[type="text"], input[placeholder*="email"], input[aria-label*="email"]');
      const passwordField = page.locator('input[type="password"], input[placeholder*="password"], input[aria-label*="password"]');
      
      if (await emailField.isVisible({ timeout: 5000 })) {
        console.log('✅ Email field found');
        await emailField.fill('customer@example.com');
        await page.waitForTimeout(500);
      }
      
      if (await passwordField.isVisible({ timeout: 5000 })) {
        console.log('✅ Password field found');
        await passwordField.fill('customer123');
        await page.waitForTimeout(500);
      }
      
      // Take screenshot of filled form
      await page.screenshot({ path: 'test-results/port-8080-filled-form.png' });
      console.log('✅ Form filled - screenshot taken');
      
      // Look for login button
      const loginButton = page.locator('button:has-text("Sign In"), button:has-text("Login"), button:has-text("Submit"), button[type="submit"]');
      if (await loginButton.isVisible({ timeout: 3000 })) {
        await loginButton.click();
        await page.waitForTimeout(3000);
        await page.screenshot({ path: 'test-results/port-8080-after-login.png' });
        console.log('✅ Login button clicked');
      }
      
    } else {
      console.log('⚠️ Customer Login button not found');
      
      // Debug: Take screenshot and look for any buttons
      await page.screenshot({ path: 'test-results/port-8080-debug.png' });
      
      const allButtons = page.locator('button');
      const buttonCount = await allButtons.count();
      console.log(`Found ${buttonCount} buttons on the page`);
      
      for (let i = 0; i < Math.min(buttonCount, 5); i++) {
        try {
          const buttonText = await allButtons.nth(i).textContent();
          console.log(`Button ${i + 1}: "${buttonText}"`);
        } catch (e) {
          console.log(`Button ${i + 1}: Could not get text`);
        }
      }
      
      // Also check for any text elements
      const allText = page.locator('text=/Customer|Staff|Admin|Login|Access|Portal/');
      const textCount = await allText.count();
      console.log(`Found ${textCount} relevant text elements`);
      
      for (let i = 0; i < Math.min(textCount, 5); i++) {
        try {
          const textContent = await allText.nth(i).textContent();
          console.log(`Text ${i + 1}: "${textContent}"`);
        } catch (e) {
          console.log(`Text ${i + 1}: Could not get text`);
        }
      }
    }
    
    // Test other buttons (go back first)
    await page.goto('http://localhost:8080');
    await page.waitForTimeout(3000);
    
    const staffButton = page.locator('button:has-text("Staff Access"), text=Staff Access, [role="button"] >> text="Staff Access"');
    
    if (await staffButton.isVisible({ timeout: 5000 })) {
      console.log('✅ Staff Access button found');
      await staffButton.click();
      await page.waitForTimeout(2000);
      await page.screenshot({ path: 'test-results/port-8080-staff-clicked.png' });
      console.log('✅ Staff Access button clicked');
    } else {
      console.log('⚠️ Staff Access button not found');
    }
    
    console.log('🎉 Test completed successfully!');
    
  } catch (error) {
    console.error('❌ Test failed:', error.message);
    
    // Take screenshot of error state
    try {
      await page.screenshot({ path: 'test-results/port-8080-error.png' });
      console.log('📸 Error screenshot taken');
    } catch (screenshotError) {
      console.log('Could not take error screenshot');
    }
  } finally {
    await browser.close();
    console.log('🔚 Browser closed');
  }
}

runPort8080Test().catch(console.error);
