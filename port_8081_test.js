// port_8081_test.js - Test on port 8081
const { chromium } = require('playwright');

async function runPort8081Test() {
  console.log('🚀 Starting test on port 8081...');
  
  const browser = await chromium.launch({ headless: false });
  const page = await browser.newPage();
  
  try {
    // Go to your Flutter app on port 8081
    await page.goto('http://localhost:8081');
    await page.waitForTimeout(3000);
    
    // Take screenshot of initial state
    await page.screenshot({ path: 'test-results/port-8081-app-loaded.png' });
    console.log('✅ App loaded on port 8081 - screenshot taken');
    
    // Look for Customer Login button
    const customerButton = page.locator('button:has-text("Customer Login"), text=Customer Login, [role="button"] >> text="Customer Login"');
    
    if (await customerButton.isVisible({ timeout: 5000 })) {
      console.log('✅ Customer Login button found');
      
      // Take screenshot before clicking
      await page.screenshot({ path: 'test-results/port-8081-before-customer-click.png' });
      
      // Click Customer Login button
      await customerButton.click();
      await page.waitForTimeout(2000);
      
      // Take screenshot after clicking
      await page.screenshot({ path: 'test-results/port-8081-after-customer-click.png' });
      console.log('✅ Customer Login button clicked');
      
      // Look for form elements
      const emailField = page.locator('input[type="email"], input[type="text"], input[placeholder*="email"], input[aria-label*="email"]');
      const passwordField = page.locator('input[type="password"], input[placeholder*="password"], input[aria-label*="password"]');
      
      if (await emailField.isVisible({ timeout: 3000 })) {
        console.log('✅ Email field found');
        await emailField.fill('customer@example.com');
        await page.waitForTimeout(500);
      }
      
      if (await passwordField.isVisible({ timeout: 3000 })) {
        console.log('✅ Password field found');
        await passwordField.fill('customer123');
        await page.waitForTimeout(500);
      }
      
      // Take screenshot of filled form
      await page.screenshot({ path: 'test-results/port-8081-filled-form.png' });
      console.log('✅ Form filled - screenshot taken');
      
    } else {
      console.log('⚠️ Customer Login button not found');
      
      // Try to find any buttons to see what's available
      const allButtons = page.locator('button');
      const buttonCount = await allButtons.count();
      console.log(`Found ${buttonCount} buttons on the page`);
      
      for (let i = 0; i < Math.min(buttonCount, 5); i++) {
        const buttonText = await allButtons.nth(i).textContent();
        console.log(`Button ${i + 1}: "${buttonText}"`);
      }
    }
    
    // Go back to test other buttons
    await page.goto('http://localhost:8081');
    await page.waitForTimeout(2000);
    
    // Look for Staff Access button
    const staffButton = page.locator('button:has-text("Staff Access"), text=Staff Access, [role="button"] >> text="Staff Access"');
    
    if (await staffButton.isVisible({ timeout: 5000 })) {
      console.log('✅ Staff Access button found');
      await staffButton.click();
      await page.waitForTimeout(2000);
      await page.screenshot({ path: 'test-results/port-8081-staff-clicked.png' });
      console.log('✅ Staff Access button clicked');
    } else {
      console.log('⚠️ Staff Access button not found');
    }
    
    // Test Admin Portal button
    await page.goto('http://localhost:8081');
    await page.waitForTimeout(2000);
    
    const adminButton = page.locator('button:has-text("Admin Portal"), text=Admin Portal, [role="button"] >> text="Admin Portal"');
    
    if (await adminButton.isVisible({ timeout: 5000 })) {
      console.log('✅ Admin Portal button found');
      await adminButton.click();
      await page.waitForTimeout(2000);
      await page.screenshot({ path: 'test-results/port-8081-admin-clicked.png' });
      console.log('✅ Admin Portal button clicked');
    } else {
      console.log('⚠️ Admin Portal button not found');
    }
    
    console.log('🎉 Test completed successfully!');
    
  } catch (error) {
    console.error('❌ Test failed:', error.message);
    
    // Take screenshot of error state
    try {
      await page.screenshot({ path: 'test-results/port-8081-error.png' });
      console.log('📸 Error screenshot taken');
    } catch (screenshotError) {
      console.log('Could not take error screenshot');
    }
  } finally {
    await browser.close();
    console.log('🔚 Browser closed');
  }
}

runPort8081Test().catch(console.error);
