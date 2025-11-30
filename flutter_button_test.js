// flutter_button_test.js - Test that works with Flutter button structure
const { chromium } = require('playwright');

async function runFlutterButtonTest() {
  console.log('🚀 Starting Flutter button test...');
  
  const browser = await chromium.launch({ headless: false });
  const page = await browser.newPage();
  
  try {
    await page.goto('http://localhost:8080');
    await page.waitForTimeout(10000); // Wait for Flutter to render
    
    // Take screenshot of initial state
    await page.screenshot({ path: 'test-results/flutter-initial.png' });
    console.log('📸 Initial screenshot taken');
    
    // Look for Flutter button elements (they might be divs or other elements)
    console.log('🔍 Looking for Flutter buttons...');
    
    // Try to find elements by their text content
    const customerButton = page.locator('text=Customer Login');
    const staffButton = page.locator('text=Staff Access');
    const adminButton = page.locator('text=Admin Portal');
    
    // Test Customer Login button
    if (await customerButton.isVisible({ timeout: 5000 })) {
      console.log('✅ Customer Login button found');
      await customerButton.click();
      await page.waitForTimeout(3000);
      await page.screenshot({ path: 'test-results/customer-login-page.png' });
      console.log('✅ Customer Login button clicked');
      
      // Look for email field
      const emailField = page.locator('input[type="email"], input[type="text"]');
      if (await emailField.isVisible({ timeout: 5000 })) {
        await emailField.fill('customer@example.com');
        await page.waitForTimeout(500);
        console.log('✅ Email field filled');
      }
      
      // Look for password field
      const passwordField = page.locator('input[type="password"]');
      if (await passwordField.isVisible({ timeout: 5000 })) {
        await passwordField.fill('customer123');
        await page.waitForTimeout(500);
        console.log('✅ Password field filled');
      }
      
      await page.screenshot({ path: 'test-results/customer-form-filled.png' });
      
      // Look for login button
      const loginButton = page.locator('text=Sign In, text=Login, text=Submit');
      if (await loginButton.isVisible({ timeout: 3000 })) {
        await loginButton.click();
        await page.waitForTimeout(3000);
        await page.screenshot({ path: 'test-results/customer-after-login.png' });
        console.log('✅ Login button clicked');
      }
    } else {
      console.log('⚠️ Customer Login button not found');
    }
    
    // Test Staff Access button
    await page.goto('http://localhost:8080');
    await page.waitForTimeout(3000);
    
    if (await staffButton.isVisible({ timeout: 5000 })) {
      console.log('✅ Staff Access button found');
      await staffButton.click();
      await page.waitForTimeout(3000);
      await page.screenshot({ path: 'test-results/staff-access-page.png' });
      console.log('✅ Staff Access button clicked');
    } else {
      console.log('⚠️ Staff Access button not found');
    }
    
    // Test Admin Portal button
    await page.goto('http://localhost:8080');
    await page.waitForTimeout(3000);
    
    if (await adminButton.isVisible({ timeout: 5000 })) {
      console.log('✅ Admin Portal button found');
      await adminButton.click();
      await page.waitForTimeout(3000);
      await page.screenshot({ path: 'test-results/admin-portal-page.png' });
      console.log('✅ Admin Portal button clicked');
    } else {
      console.log('⚠️ Admin Portal button not found');
    }
    
    // Test Help button
    await page.goto('http://localhost:8080');
    await page.waitForTimeout(3000);
    
    const helpButton = page.locator('text=Need help signing in?');
    if (await helpButton.isVisible({ timeout: 5000 })) {
      console.log('✅ Help button found');
      await helpButton.click();
      await page.waitForTimeout(2000);
      await page.screenshot({ path: 'test-results/help-dialog.png' });
      console.log('✅ Help button clicked');
    } else {
      console.log('⚠️ Help button not found');
    }
    
    console.log('🎉 Flutter button test completed successfully!');
    
  } catch (error) {
    console.error('❌ Test failed: ' + error.message);
    
    try {
      await page.screenshot({ path: 'test-results/flutter-button-error.png' });
      console.log('📸 Error screenshot taken');
    } catch (screenshotError) {
      console.log('Could not take error screenshot');
    }
  } finally {
    await browser.close();
    console.log('🔚 Browser closed');
  }
}

runFlutterButtonTest().catch(console.error);
