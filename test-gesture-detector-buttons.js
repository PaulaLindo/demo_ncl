// test-gesture-detector-buttons.js
const { chromium } = require('playwright');
const fs = require('fs');
const path = require('path');

async function testGestureDetectorButtons() {
  console.log('🧪 TESTING GESTURE DETECTOR BUTTONS');
  console.log('===================================');
  console.log('Testing if GestureDetector works better than InkWell with CanvasKit');
  console.log('');

  const browser = await chromium.launch({ 
    headless: false, // Show browser for visibility
    slowMo: 1000 // Slow down to see what's happening
  });

  try {
    const page = await browser.newPage();
    
    // Enable console logging
    page.on('console', msg => {
      console.log(`🖥️  ${msg.type()}: ${msg.text()}`);
    });

    page.on('pageerror', error => {
      console.error('❌ Page Error:', error.message);
    });
    
    console.log('\n📍 Step 1: Load main page');
    await page.goto('http://localhost:8080/');
    await page.waitForTimeout(8000); // Wait for full initialization
    
    await page.screenshot({ path: 'screenshots/gesture-test/01-initial-page.png', fullPage: true });
    console.log('📸 Initial page loaded');
    
    const initialUrl = page.url();
    console.log(`📍 Initial URL: ${initialUrl}`);
    
    console.log('\n📍 Step 2: Test Customer Login button');
    
    const canvas = page.locator('canvas').first();
    const boundingBox = await canvas.boundingBox();
    
    if (!boundingBox) {
      console.log('❌ No canvas found');
      return;
    }
    
    console.log(`📏 Canvas bounds: ${boundingBox.width}x${boundingBox.height}`);
    
    // Test Customer Login button (left side)
    const customerX = boundingBox.x + (boundingBox.width * 0.25);
    const customerY = boundingBox.y + (boundingBox.height * 0.6);
    
    console.log(`🎯 Clicking Customer Login at (${customerX}, ${customerY})`);
    
    const beforeUrl = page.url();
    console.log(`📍 Before click: ${beforeUrl}`);
    
    // Click the button
    await page.mouse.click(customerX, customerY);
    await page.waitForTimeout(3000);
    
    const afterUrl = page.url();
    console.log(`📍 After click: ${afterUrl}`);
    console.log(`🔍 Navigation occurred: ${beforeUrl !== afterUrl ? 'YES' : 'NO'}`);
    
    if (beforeUrl !== afterUrl && afterUrl.includes('/login/customer')) {
      console.log('✅ SUCCESS! GestureDetector buttons work!');
      await page.screenshot({ path: 'screenshots/gesture-test/02-customer-success.png', fullPage: true });
      
      // Test Staff button
      console.log('\n📍 Step 3: Test Staff Access button');
      await page.goto('http://localhost:8080/');
      await page.waitForTimeout(3000);
      
      const staffX = boundingBox.x + (boundingBox.width * 0.5);
      const staffY = boundingBox.y + (boundingBox.height * 0.6);
      
      console.log(`🎯 Clicking Staff Access at (${staffX}, ${staffY})`);
      
      const beforeStaffUrl = page.url();
      await page.mouse.click(staffX, staffY);
      await page.waitForTimeout(3000);
      
      const afterStaffUrl = page.url();
      console.log(`📍 Before staff click: ${beforeStaffUrl}`);
      console.log(`📍 After staff click: ${afterStaffUrl}`);
      console.log(`🔍 Staff navigation occurred: ${beforeStaffUrl !== afterStaffUrl ? 'YES' : 'NO'}`);
      
      if (beforeStaffUrl !== afterStaffUrl && afterStaffUrl.includes('/login/staff')) {
        console.log('✅ Staff button also works!');
        await page.screenshot({ path: 'screenshots/gesture-test/03-staff-success.png', fullPage: true });
        
        // Test Admin button
        console.log('\n📍 Step 4: Test Admin Portal button');
        await page.goto('http://localhost:8080/');
        await page.waitForTimeout(3000);
        
        const adminX = boundingBox.x + (boundingBox.width * 0.75);
        const adminY = boundingBox.y + (boundingBox.height * 0.6);
        
        console.log(`🎯 Clicking Admin Portal at (${adminX}, ${adminY})`);
        
        const beforeAdminUrl = page.url();
        await page.mouse.click(adminX, adminY);
        await page.waitForTimeout(3000);
        
        const afterAdminUrl = page.url();
        console.log(`📍 Before admin click: ${beforeAdminUrl}`);
        console.log(`📍 After admin click: ${afterAdminUrl}`);
        console.log(`🔍 Admin navigation occurred: ${beforeAdminUrl !== afterAdminUrl ? 'YES' : 'NO'}`);
        
        if (beforeAdminUrl !== afterAdminUrl && afterAdminUrl.includes('/login/admin')) {
          console.log('✅ Admin button also works!');
          await page.screenshot({ path: 'screenshots/gesture-test/04-admin-success.png', fullPage: true });
          
          console.log('\n🎊 ALL BUTTONS WORKING! 🎊');
          console.log('✅ GestureDetector fixed the CanvasKit issue!');
          console.log('✅ All navigation is working correctly!');
          console.log('✅ The app is fully functional!');
          
        } else {
          console.log('❌ Admin button still not working');
          await page.screenshot({ path: 'screenshots/gesture-test/04-admin-failed.png', fullPage: true });
        }
        
      } else {
        console.log('❌ Staff button not working');
        await page.screenshot({ path: 'screenshots/gesture-test/03-staff-failed.png', fullPage: true });
      }
      
    } else {
      console.log('❌ GestureDetector buttons still not working');
      await page.screenshot({ path: 'screenshots/gesture-test/02-customer-failed.png', fullPage: true });
      
      console.log('\n📍 Step 5: Test programmatic navigation as fallback');
      await page.goto('http://localhost:8080/');
      await page.waitForTimeout(3000);
      
      await page.evaluate(() => {
        window.history.pushState({}, '', '/login/customer');
      });
      
      await page.waitForTimeout(2000);
      const progUrl = page.url();
      console.log(`📍 Programmatic navigation: ${progUrl}`);
      
      if (progUrl.includes('/login/customer')) {
        console.log('✅ Programmatic navigation still works');
        await page.screenshot({ path: 'screenshots/gesture-test/05-programmatic-works.png', fullPage: true });
      }
    }
    
    console.log('\n🎯 FINAL VERDICT');
    console.log('================');
    console.log('📁 Screenshots saved to: screenshots/gesture-test/');
    console.log('');
    console.log('🔍 Results:');
    console.log('- GestureDetector vs InkWell with CanvasKit');
    console.log('- Button click functionality');
    console.log('- Navigation verification');

  } catch (error) {
    console.error('❌ Error testing GestureDetector buttons:', error);
  } finally {
    await browser.close();
    console.log('\n✅ Browser closed');
  }
}

// Ensure screenshot directory exists
if (!fs.existsSync('screenshots/gesture-test')) {
  fs.mkdirSync('screenshots/gesture-test', { recursive: true });
}

// Run the test
testGestureDetectorButtons().catch(console.error);
