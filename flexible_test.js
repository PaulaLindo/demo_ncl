// flexible_test.js - Test on any available port
const { chromium } = require('playwright');

async function runFlexibleTest() {
  console.log('🚀 Starting flexible test...');
  
  const browser = await chromium.launch({ headless: false });
  const page = await browser.newPage();
  
  try {
    // Try different ports where your app might be running
    const ports = [8080, 3000, 8000, 5000];
    let appLoaded = false;
    
    for (const port of ports) {
      try {
        console.log(`🔍 Trying port ${port}...`);
        await page.goto(`http://localhost:${port}`, { timeout: 5000 });
        
        // Wait a bit to see if it loads
        await page.waitForTimeout(2000);
        
        // Check if page loaded successfully
        const title = await page.title();
        console.log(`✅ Port ${port} loaded! Title: ${title}`);
        
        // Take screenshot
        await page.screenshot({ path: `test-results/port-${port}-loaded.png` });
        
        appLoaded = true;
        
        // Now test the UI
        await testUI(page, port);
        break;
        
      } catch (error) {
        console.log(`❌ Port ${port} failed: ${error.message}`);
        continue;
      }
    }
    
    if (!appLoaded) {
      console.log('❌ No port worked. Please start your Flutter app first.');
    }
    
  } catch (error) {
    console.error('❌ Test failed:', error.message);
  } finally {
    await browser.close();
    console.log('🔚 Browser closed');
  }
}

async function testUI(page, port) {
  console.log(`🧪 Testing UI on port ${port}...`);
  
  try {
    // Look for Customer Login button
    const customerButton = page.locator('button:has-text("Customer Login"), text=Customer Login');
    if (await customerButton.isVisible({ timeout: 5000 })) {
      await customerButton.click();
      await page.waitForTimeout(2000);
      await page.screenshot({ path: `test-results/port-${port}-customer-clicked.png` });
      console.log('✅ Customer Login button clicked');
      
      // Go back
      await page.goBack();
      await page.waitForTimeout(1000);
    } else {
      console.log('⚠️ Customer Login button not found');
    }
    
    // Look for Staff Access button
    const staffButton = page.locator('button:has-text("Staff Access"), text=Staff Access');
    if (await staffButton.isVisible({ timeout: 5000 })) {
      await staffButton.click();
      await page.waitForTimeout(2000);
      await page.screenshot({ path: `test-results/port-${port}-staff-clicked.png` });
      console.log('✅ Staff Access button clicked');
    } else {
      console.log('⚠️ Staff Access button not found');
    }
    
    console.log('🎉 UI testing completed!');
    
  } catch (error) {
    console.error('❌ UI testing failed:', error.message);
  }
}

runFlexibleTest().catch(console.error);
