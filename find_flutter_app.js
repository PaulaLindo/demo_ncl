// find_flutter_app.js - Find your Flutter app in existing Chrome tabs
const { chromium } = require('playwright');

async function findFlutterApp() {
  console.log('🔍 Looking for Flutter app in existing Chrome tabs...');
  
  try {
    // Connect to existing Chrome instance
    const browser = await chromium.connectOverCDP('http://localhost:9222');
    console.log('✅ Connected to existing Chrome');
    
    // Get all pages/tabs
    const contexts = browser.contexts();
    const pages = [];
    
    for (const context of contexts) {
      const contextPages = await context.pages();
      pages.push(...contextPages);
    }
    
    console.log(`Found ${pages.length} Chrome tabs`);
    
    // Look for Flutter app in any tab
    let flutterPage = null;
    
    for (let i = 0; i < pages.length; i++) {
      const page = pages[i];
      try {
        const url = page.url();
        const title = await page.title();
        
        console.log(`Tab ${i + 1}: ${title} - ${url}`);
        
        // Check if it's a Flutter app
        if (url.includes('localhost') || title.includes('NCL') || title.includes('demo_ncl')) {
          console.log(`✅ Found potential Flutter app: ${title} - ${url}`);
          flutterPage = page;
          break;
        }
      } catch (error) {
        console.log(`Tab ${i + 1}: Could not read page info`);
      }
    }
    
    if (flutterPage) {
      console.log('🎯 Found Flutter app! Testing it...');
      await testFlutterApp(flutterPage);
    } else {
      console.log('❌ No Flutter app found in Chrome tabs');
      console.log('💡 Please make sure your Flutter app is running in Chrome');
    }
    
    await browser.close();
    
  } catch (error) {
    console.error('❌ Could not connect to Chrome:', error.message);
    console.log('💡 Try starting Chrome with remote debugging: chrome.exe --remote-debugging-port=9222');
  }
}

async function testFlutterApp(page) {
  try {
    // Take screenshot of current state
    await page.screenshot({ path: 'test-results/flutter-app-found.png' });
    console.log('📸 Flutter app screenshot taken');
    
    // Look for Customer Login button
    const customerButton = page.locator('button:has-text("Customer Login"), text=Customer Login');
    
    if (await customerButton.isVisible({ timeout: 5000 })) {
      console.log('✅ Customer Login button found');
      await customerButton.click();
      await page.waitForTimeout(2000);
      await page.screenshot({ path: 'test-results/customer-login-clicked.png' });
      console.log('✅ Customer Login button clicked');
    } else {
      console.log('⚠️ Customer Login button not found');
    }
    
    // Try other buttons
    const staffButton = page.locator('button:has-text("Staff Access"), text=Staff Access');
    if (await staffButton.isVisible({ timeout: 3000 })) {
      await staffButton.click();
      await page.waitForTimeout(2000);
      await page.screenshot({ path: 'test-results/staff-access-clicked.png' });
      console.log('✅ Staff Access button clicked');
    }
    
    console.log('🎉 Flutter app testing completed!');
    
  } catch (error) {
    console.error('❌ Flutter app testing failed:', error.message);
  }
}

findFlutterApp().catch(console.error);
