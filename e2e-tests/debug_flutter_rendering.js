// e2e-tests/debug_flutter_rendering.js - Debug Flutter web rendering issues
const { chromium } = require('playwright');
const fs = require('fs');
const path = require('path');

const BASE_URL = 'http://localhost:8081';
const SCREENSHOT_DIR = path.join(__dirname, '..', 'test-results');

function sleep(ms) {
  return new Promise(resolve => setTimeout(resolve, ms));
}

function timestamp() {
  return new Date().toISOString().replace(/[:.]/g, '-');
}

async function takeScreenshot(page, name) {
  const filename = `debug_flutter_${name}_${timestamp()}.png`;
  const filepath = path.join(SCREENSHOT_DIR, filename);
  await page.screenshot({ path: filepath, fullPage: true });
  console.log(`📸 Screenshot saved: ${filename}`);
  return filename;
}

async function debugFlutterRendering() {
  console.log('🔍 Debugging Flutter Web Rendering...');
  console.log('=====================================');
  
  const browser = await chromium.launch({ 
    headless: false,
    devtools: true // Open devtools to see console errors
  });
  const context = await browser.newContext({
    viewport: { width: 1280, height: 720 }
  });
  const page = await context.newPage();
  
  // Capture console logs and errors
  const consoleMessages = [];
  const errors = [];
  
  page.on('console', msg => {
    consoleMessages.push({
      type: msg.type(),
      text: msg.text(),
      location: msg.location()
    });
    if (msg.type() === 'error') {
      errors.push(msg.text());
      console.log(`❌ Console Error: ${msg.text()}`);
    } else if (msg.type() === 'warning') {
      console.log(`⚠️ Console Warning: ${msg.text()}`);
    } else if (msg.type() === 'log') {
      console.log(`📝 Console Log: ${msg.text()}`);
    }
  });
  
  page.on('pageerror', error => {
    console.log(`🚨 Page Error: ${error.message}`);
    errors.push(error.message);
  });
  
  try {
    // Step 1: Load the page and wait for Flutter to initialize
    console.log('\n📍 Step 1: Loading Flutter app...');
    await page.goto(BASE_URL, { waitUntil: 'networkidle' });
    await sleep(5000); // Give Flutter time to initialize
    
    await takeScreenshot(page, 'initial_load');
    
    // Step 2: Check for Flutter elements
    console.log('\n📍 Step 2: Checking Flutter elements...');
    
    // Check for Flutter app container
    const flutterApp = await page.$('flt-glass-pane, flt-scene, canvas');
    const hasFlutterApp = !!flutterApp;
    console.log(`🦋 Flutter App Container: ${hasFlutterApp ? '✅' : '❌'}`);
    
    // Check for canvas element
    const canvas = await page.$('canvas');
    const hasCanvas = !!canvas;
    console.log(`🎨 Canvas Element: ${hasCanvas ? '✅' : '❌'}`);
    
    // Check for any Flutter-specific elements
    const flutterElements = await page.$$('flt-glass-pane, flt-scene, flt-semantics, canvas');
    console.log(`🔍 Flutter Elements Found: ${flutterElements.length}`);
    
    // Step 3: Check page content
    console.log('\n📍 Step 3: Analyzing page content...');
    
    const bodyText = await page.textContent('body');
    const bodyTextLength = bodyText.length;
    console.log(`📄 Body Text Length: ${bodyTextLength}`);
    
    if (bodyTextLength < 1000) {
      console.log('📄 Body Text Preview:');
      console.log(bodyText.substring(0, 500));
    }
    
    // Check for our Flutter UI content
    const hasWelcomeText = bodyText.includes('Welcome to NCL');
    const hasLoginButtons = bodyText.includes('Customer Login') || bodyText.includes('Staff Access');
    const hasFormElements = bodyText.includes('Email') || bodyText.includes('Password');
    
    console.log(`👋 Welcome Text: ${hasWelcomeText ? '✅' : '❌'}`);
    console.log(`🔘 Login Buttons: ${hasLoginButtons ? '✅' : '❌'}`);
    console.log(`📝 Form Elements: ${hasFormElements ? '✅' : '❌'}`);
    
    // Step 4: Check Flutter engine state
    console.log('\n📍 Step 4: Checking Flutter engine state...');
    
    const flutterEngineState = await page.evaluate(() => {
      return {
        hasFlutter: !!window.flutter,
        hasApp: !!(window.flutter && window.flutter.app),
        hasEngine: !!(window.flutter && window.flutter.app && window.flutter.app.engine),
        hasRenderer: !!(window.flutter && window.flutter.app && window.flutter.app.renderer),
        flutterObject: window.flutter ? Object.keys(window.flutter) : [],
        appObject: (window.flutter && window.flutter.app) ? Object.keys(window.flutter.app) : []
      };
    });
    
    console.log(`🦋 Flutter Object: ${flutterEngineState.hasFlutter ? '✅' : '❌'}`);
    console.log(`📱 Flutter App: ${flutterEngineState.hasApp ? '✅' : '❌'}`);
    console.log(`⚙️ Flutter Engine: ${flutterEngineState.hasEngine ? '✅' : '❌'}`);
    console.log(`🎨 Flutter Renderer: ${flutterEngineState.hasRenderer ? '✅' : '❌'}`);
    
    if (flutterEngineState.hasFlutter) {
      console.log(`🔑 Flutter Object Keys: ${flutterEngineState.flutterObject.join(', ')}`);
    }
    if (flutterEngineState.hasApp) {
      console.log(`📱 App Object Keys: ${flutterEngineState.appObject.join(', ')}`);
    }
    
    // Step 5: Test navigation
    console.log('\n📍 Step 5: Testing navigation...');
    
    // Try to navigate to customer login
    await page.goto(`${BASE_URL}/login/customer`, { waitUntil: 'networkidle' });
    await sleep(3000);
    
    const customerBodyText = await page.textContent('body');
    const hasCustomerContent = customerBodyText.includes('Welcome Back') || customerBodyText.includes('Customer Login');
    console.log(`👤 Customer Login Content: ${hasCustomerContent ? '✅' : '❌'}`);
    
    await takeScreenshot(page, 'customer_login');
    
    // Step 6: Try different renderer
    console.log('\n📍 Step 6: Testing CanvasKit renderer...');
    
    await page.goto(BASE_URL);
    await sleep(2000);
    
    // Switch to CanvasKit renderer
    await page.evaluate(() => {
      window.flutterWebRenderer = "canvaskit";
      location.reload();
    });
    
    await sleep(5000);
    
    const canvasKitBodyText = await page.textContent('body');
    const hasCanvasKitContent = canvasKitBodyText.includes('Welcome to NCL');
    console.log(`🎨 CanvasKit Content: ${hasCanvasKitContent ? '✅' : '❌'}`);
    
    await takeScreenshot(page, 'canvaskit_renderer');
    
    // Generate debug report
    console.log('\n📊 DEBUG REPORT');
    console.log('================');
    console.log(`📄 Console Messages: ${consoleMessages.length}`);
    console.log(`🚨 Errors: ${errors.length}`);
    console.log(`🦋 Flutter Elements: ${flutterElements.length}`);
    console.log(`📝 Body Text Length: ${bodyTextLength}`);
    
    if (errors.length > 0) {
      console.log('\n🚨 ERRORS FOUND:');
      errors.forEach((error, index) => {
        console.log(`${index + 1}. ${error}`);
      });
    }
    
    // Save debug report
    const debugReport = {
      timestamp: new Date().toISOString(),
      flutterElements: flutterElements.length,
      bodyTextLength,
      hasWelcomeText,
      hasLoginButtons,
      hasFormElements,
      flutterEngineState,
      consoleMessages,
      errors,
      screenshots: []
    };
    
    const reportPath = path.join(SCREENSHOT_DIR, `flutter_debug_report_${timestamp()}.json`);
    fs.writeFileSync(reportPath, JSON.stringify(debugReport, null, 2));
    console.log(`\n📄 Debug report saved: ${reportPath}`);
    
  } catch (error) {
    console.error('❌ Debug session failed:', error);
  } finally {
    await browser.close();
  }
}

// Run debug if this file is executed directly
if (require.main === module) {
  debugFlutterRendering().catch(console.error);
}

module.exports = { debugFlutterRendering };
