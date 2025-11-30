// simple_test.js - Quick test that won't hang
const { chromium } = require('playwright');

async function runQuickTest() {
  console.log('🚀 Starting simple Chrome test...');
  
  const browser = await chromium.launch({ headless: false });
  const page = await browser.newPage();
  
  try {
    // Go to your Flutter app
    await page.goto('http://localhost:8080');
    await page.waitForTimeout(3000);
    
    // Take screenshot
    await page.screenshot({ path: 'simple-test-results/app-loaded.png' });
    console.log('✅ App loaded - screenshot taken');
    
    // Look for Customer Login button
    const customerButton = page.locator('button:has-text("Customer Login")');
    if (await customerButton.isVisible()) {
      await customerButton.click();
      await page.waitForTimeout(2000);
      await page.screenshot({ path: 'simple-test-results/customer-clicked.png' });
      console.log('✅ Customer Login button clicked');
    } else {
      console.log('⚠️ Customer Login button not found');
    }
    
    // Look for Staff Access button
    await page.goto('http://localhost:8080');
    await page.waitForTimeout(2000);
    
    const staffButton = page.locator('button:has-text("Staff Access")');
    if (await staffButton.isVisible()) {
      await staffButton.click();
      await page.waitForTimeout(2000);
      await page.screenshot({ path: 'simple-test-results/staff-clicked.png' });
      console.log('✅ Staff Access button clicked');
    } else {
      console.log('⚠️ Staff Access button not found');
    }
    
    console.log('🎉 Simple test completed successfully!');
    
  } catch (error) {
    console.error('❌ Test failed:', error.message);
  } finally {
    await browser.close();
    console.log('🔚 Browser closed');
  }
}

runQuickTest().catch(console.error);
