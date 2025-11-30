// diagnose-flutter-app.js - Diagnose what's wrong with the Flutter app
const { chromium } = require('playwright');
const fs = require('fs');

async function diagnoseFlutterApp() {
  console.log('🔍 DIAGNOSING FLUTTER APP ISSUES');
  console.log('===================================');
  console.log('Checking for runtime errors, network issues, and button problems');
  console.log('');

  const browser = await chromium.launch({ 
    headless: false, // Show browser to see what's happening
    slowMo: 1000
  });

  try {
    const page = await browser.newPage();
    
    // Capture all console messages
    const consoleMessages = [];
    page.on('console', msg => {
      const message = `[${msg.type()}] ${msg.text()}`;
      console.log('🖥️ ', message);
      consoleMessages.push(message);
    });

    // Capture all page errors
    const pageErrors = [];
    page.on('pageerror', error => {
      const errorMessage = `Page Error: ${error.message}`;
      console.error('❌', errorMessage);
      pageErrors.push(errorMessage);
    });

    // Capture network requests
    const networkRequests = [];
    page.on('request', request => {
      const url = request.url();
      console.log('🌐 Request:', url);
      networkRequests.push(url);
    });

    page.on('response', response => {
      const status = response.status();
      const url = response.url();
      if (status >= 400) {
        console.error('❌ Response Error:', status, url);
      }
    });

    console.log('\n📍 Step 1: Load main page and monitor for errors');
    await page.goto('http://localhost:8080/', { waitUntil: 'networkidle' });
    
    // Wait longer for Flutter to initialize
    await page.waitForTimeout(15000);
    
    console.log('\n📍 Step 2: Check if Flutter app loaded correctly');
    
    // Check for Flutter canvas
    const canvas = await page.locator('canvas').first();
    const canvasExists = await canvas.count() > 0;
    console.log(`🎨 Canvas element found: ${canvasExists}`);
    
    if (canvasExists) {
      const canvasBox = await canvas.boundingBox();
      console.log(`📏 Canvas dimensions: ${canvasBox?.width}x${canvasBox?.height}`);
    }
    
    // Check for Flutter app content
    const flutterApp = await page.locator('flutter-view').first();
    const flutterAppExists = await flutterApp.count() > 0;
    console.log(`🦋 Flutter app element found: ${flutterAppExists}`);
    
    // Check for any error messages on the page
    const errorElements = await page.locator('text=Error, text=Failed, text=Exception').all();
    console.log(`🚨 Error elements found: ${errorElements.length}`);
    
    for (const errorElement of errorElements) {
      const errorText = await errorElement.textContent();
      console.log('🚨 Error text:', errorText);
    }
    
    console.log('\n📍 Step 3: Test button visibility and accessibility');
    
    // Look for button text
    const customerText = await page.locator('text=Customer Login').first();
    const customerVisible = await customerText.isVisible();
    console.log(`👤 Customer Login text visible: ${customerVisible}`);
    
    const staffText = await page.locator('text=Staff Access').first();
    const staffVisible = await staffText.isVisible();
    console.log(`👷‍♀️ Staff Access text visible: ${staffVisible}`);
    
    const adminText = await page.locator('text=Admin Portal').first();
    const adminVisible = await adminText.isVisible();
    console.log(`👨‍💼 Admin Portal text visible: ${adminVisible}`);
    
    console.log('\n📍 Step 4: Test actual button clicks');
    
    if (customerVisible) {
      console.log('🎯 Attempting Customer Login click...');
      const beforeUrl = page.url();
      
      try {
        await customerText.click({ timeout: 5000 });
        await page.waitForTimeout(3000);
        
        const afterUrl = page.url();
        console.log(`📍 Before: ${beforeUrl}`);
        console.log(`📍 After: ${afterUrl}`);
        console.log(`🔍 Navigation occurred: ${beforeUrl !== afterUrl ? 'YES' : 'NO'}`);
      } catch (error) {
        console.error('❌ Click failed:', error.message);
      }
    }
    
    console.log('\n📍 Step 5: Test direct URL navigation');
    await page.goto('http://localhost:8080/login/customer', { waitUntil: 'networkidle' });
    await page.waitForTimeout(5000);
    
    const customerLoginUrl = page.url();
    console.log(`📍 Direct customer login URL: ${customerLoginUrl}`);
    console.log(`🔍 Direct navigation works: ${customerLoginUrl.includes('/login/customer') ? 'YES' : 'NO'}`);
    
    // Check if login page loaded
    const loginInputs = await page.locator('input').all();
    console.log(`📝 Login form inputs found: ${loginInputs.length}`);
    
    console.log('\n🎯 DIAGNOSIS RESULTS');
    console.log('===================');
    
    console.log('\n📊 Summary:');
    console.log(`- Canvas element: ${canvasExists ? '✅' : '❌'}`);
    console.log(`- Flutter app element: ${flutterAppExists ? '✅' : '❌'}`);
    console.log(`- Customer Login visible: ${customerVisible ? '✅' : '❌'}`);
    console.log(`- Staff Access visible: ${staffVisible ? '✅' : '❌'}`);
    console.log(`- Admin Portal visible: ${adminVisible ? '✅' : '❌'}`);
    console.log(`- Page errors: ${pageErrors.length}`);
    console.log(`- Console messages: ${consoleMessages.length}`);
    
    if (pageErrors.length > 0) {
      console.log('\n❌ PAGE ERRORS FOUND:');
      pageErrors.forEach((error, index) => {
        console.log(`${index + 1}. ${error}`);
      });
    }
    
    if (consoleMessages.some(msg => msg.includes('Error') || msg.includes('Exception'))) {
      console.log('\n❌ CONSOLE ERRORS FOUND:');
      consoleMessages.filter(msg => msg.includes('Error') || msg.includes('Exception'))
        .forEach((msg, index) => {
          console.log(`${index + 1}. ${msg}`);
        });
    }
    
    console.log('\n🔍 LIKELY ISSUES:');
    
    if (!canvasExists) {
      console.log('❌ Flutter canvas not rendering - app failed to start');
    }
    
    if (!flutterAppExists) {
      console.log('❌ Flutter app element not found - initialization failed');
    }
    
    if (!customerVisible && !staffVisible && !adminVisible) {
      console.log('❌ No button text visible - UI not rendering');
    }
    
    if (pageErrors.length > 0) {
      console.log('❌ Runtime errors detected - check console');
    }
    
    if (canvasExists && customerVisible && pageErrors.length === 0) {
      console.log('✅ App renders correctly but buttons don\'t work');
      console.log('🔍 This is likely a Flutter web event handling issue');
    }
    
  } catch (error) {
    console.error('❌ Diagnosis failed:', error);
  } finally {
    await browser.close();
    console.log('\n✅ Browser closed');
  }
}

// Run the diagnosis
diagnoseFlutterApp().catch(console.error);
