// e2e-tests/auth_debug_test.js - Debug authentication process step by step
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
  const filename = `auth_debug_${name}_${timestamp()}.png`;
  const filepath = path.join(SCREENSHOT_DIR, filename);
  await page.screenshot({ path: filepath, fullPage: true });
  console.log(`📸 Screenshot: ${filename}`);
  return filename;
}

async function debugAuthentication(page, role) {
  console.log(`\n🔍 DEBUGGING ${role.toUpperCase()} AUTHENTICATION`);
  console.log(`${'='.repeat(60)}`);
  
  // Capture console logs
  const consoleMessages = [];
  page.on('console', msg => {
    const text = msg.text();
    consoleMessages.push({ type: msg.type(), text, timestamp: new Date().toISOString() });
    if (text.includes('Auth') || text.includes('Login') || text.includes('Error') || text.includes('GoRouter')) {
      console.log(`📝 ${msg.type()}: ${text}`);
    }
  });
  
  page.on('pageerror', error => {
    console.log(`🚨 Page Error: ${error.message}`);
    consoleMessages.push({ type: 'error', text: error.message, timestamp: new Date().toISOString() });
  });
  
  try {
    // Step 1: Navigate to login page
    console.log('🚀 Step 1: Navigating to login page...');
    await page.goto(`${BASE_URL}/login/${role}`, { waitUntil: 'networkidle' });
    await sleep(3000);
    await takeScreenshot(page, `${role}_step1_login_page`);
    
    // Step 2: Fill in credentials
    console.log('📝 Step 2: Filling credentials...');
    const credentials = {
      customer: { email: 'customer@example.com', password: 'customer123' },
      staff: { email: 'staff@example.com', password: 'staff123' },
      admin: { email: 'admin@example.com', password: 'admin123' }
    };
    
    const cred = credentials[role];
    
    // Fill email
    await page.fill('input[type="email"]', cred.email);
    console.log(`✅ Email filled: ${cred.email}`);
    await sleep(500);
    
    // Fill password
    await page.fill('input[type="password"]', cred.password);
    console.log(`✅ Password filled: ${cred.password}`);
    await sleep(500);
    
    await takeScreenshot(page, `${role}_step2_form_filled`);
    
    // Step 3: Click submit button
    console.log('🔘 Step 3: Clicking submit button...');
    await page.click('button[type="submit"]');
    console.log('✅ Submit button clicked');
    
    // Step 4: Monitor authentication process
    console.log('⏳ Step 4: Monitoring authentication process...');
    
    let currentUrl = page.url();
    let previousUrl = currentUrl;
    let authStartTime = Date.now();
    let maxWaitTime = 15000; // 15 seconds max
    
    while (Date.now() - authStartTime < maxWaitTime) {
      await sleep(1000);
      currentUrl = page.url();
      
      if (currentUrl !== previousUrl) {
        console.log(`🔄 URL changed: ${previousUrl} → ${currentUrl}`);
        previousUrl = currentUrl;
      }
      
      // Check if we've been redirected to home page
      if (currentUrl.includes(`/${role}/home`)) {
        console.log(`✅ SUCCESS: Redirected to home page!`);
        break;
      }
      
      // Check for error messages
      const bodyText = await page.textContent('body');
      if (bodyText.includes('Login failed') || bodyText.includes('Invalid credentials')) {
        console.log(`❌ Login failed - error message detected`);
        break;
      }
      
      // Check for loading indicators
      const hasLoading = bodyText.includes('Signing in') || bodyText.includes('Loading');
      if (hasLoading) {
        console.log(`⏳ Still loading...`);
      }
    }
    
    // Step 5: Final analysis
    console.log('📊 Step 5: Final analysis...');
    await sleep(2000);
    await takeScreenshot(page, `${role}_step5_final_state`);
    
    const finalUrl = page.url();
    const finalBodyText = await page.textContent('body');
    const finalBodyLength = finalBodyText.length;
    
    console.log(`🔗 Final URL: ${finalUrl}`);
    console.log(`📝 Body Length: ${finalBodyLength}`);
    
    // Check for authentication success indicators
    const authSuccess = finalUrl.includes(`/${role}/home`);
    const hasError = finalBodyText.includes('Login failed') || finalBodyText.includes('Invalid credentials');
    const stillOnLogin = finalUrl.includes(`/login/${role}`);
    
    console.log(`🎯 Authentication Success: ${authSuccess ? 'YES' : 'NO'}`);
    console.log(`❌ Has Error: ${hasError ? 'YES' : 'NO'}`);
    console.log(`📍 Still on Login: ${stillOnLogin ? 'YES' : 'NO'}`);
    
    // Check for Flutter content
    const hasFlutterIndicators = finalBodyText.includes('flutter-view') || 
                                finalBodyText.includes('flt-scene-host') ||
                                finalBodyText.includes('flt-semantic');
    
    console.log(`🦋 Flutter Content: ${hasFlutterIndicators ? 'YES' : 'NO'}`);
    
    // Check for expected content
    const expectedContent = ['Dashboard', 'Overview', 'Welcome', 'Profile'];
    const foundContent = expectedContent.filter(content => finalBodyText.includes(content));
    
    if (foundContent.length > 0) {
      console.log(`🎯 Found Expected Content: ${foundContent.join(', ')}`);
    }
    
    // Filter relevant console messages
    const relevantMessages = consoleMessages.filter(msg => 
      msg.type === 'error' || 
      msg.text.includes('Auth') || 
      msg.text.includes('Login') || 
      msg.text.includes('GoRouter') ||
      msg.text.includes('Error')
    );
    
    if (relevantMessages.length > 0) {
      console.log(`📝 Relevant Console Messages:`);
      relevantMessages.forEach(msg => {
        console.log(`  ${msg.type}: ${msg.text}`);
      });
    }
    
    return {
      role,
      finalUrl,
      authSuccess,
      hasError,
      stillOnLogin,
      hasFlutterIndicators,
      foundContent,
      consoleMessages: relevantMessages,
      bodyLength: finalBodyLength
    };
    
  } catch (error) {
    console.error(`❌ Debug error:`, error.message);
    return {
      role,
      error: error.message,
      authSuccess: false
    };
  }
}

async function runAuthDebug() {
  console.log('🔍 AUTHENTICATION DEBUG TEST');
  console.log('==========================');
  
  const browser = await chromium.launch({ 
    headless: false,
    devtools: true 
  });
  const context = await browser.newContext({
    viewport: { width: 1280, height: 720 }
  });
  
  const roles = ['customer', 'staff', 'admin'];
  const results = [];
  
  for (const role of roles) {
    const page = await context.newPage();
    const result = await debugAuthentication(page, role);
    results.push(result);
    await page.close();
    
    // Small delay between tests
    await sleep(2000);
  }
  
  await browser.close();
  
  // Generate report
  console.log('\n\n📊 AUTHENTICATION DEBUG REPORT');
  console.log('==============================');
  
  results.forEach(result => {
    console.log(`\n👤 ${result.role.toUpperCase()}:`);
    console.log(`  🔐 Auth Success: ${result.authSuccess ? 'YES' : 'NO'}`);
    console.log(`  🔗 Final URL: ${result.finalUrl || 'ERROR'}`);
    console.log(`  ❌ Has Error: ${result.hasError ? 'YES' : 'NO'}`);
    console.log(`  📍 Still on Login: ${result.stillOnLogin ? 'YES' : 'NO'}`);
    console.log(`  🦋 Flutter Content: ${result.hasFlutterIndicators ? 'YES' : 'NO'}`);
    console.log(`  📝 Body Length: ${result.bodyLength || 'N/A'}`);
    
    if (result.foundContent && result.foundContent.length > 0) {
      console.log(`  🎯 Found Content: ${result.foundContent.join(', ')}`);
    }
    
    if (result.consoleMessages && result.consoleMessages.length > 0) {
      console.log(`  📝 Console Messages: ${result.consoleMessages.length}`);
      result.consoleMessages.forEach(msg => {
        console.log(`    ${msg.type}: ${msg.text}`);
      });
    }
    
    if (result.error) {
      console.log(`  ❌ Error: ${result.error}`);
    }
  });
  
  // Save results
  const reportData = {
    timestamp: new Date().toISOString(),
    results
  };
  
  const reportPath = path.join(SCREENSHOT_DIR, `auth_debug_report_${timestamp()}.json`);
  fs.writeFileSync(reportPath, JSON.stringify(reportData, null, 2));
  console.log(`\n📄 Debug report saved: ${reportPath}`);
  
  return reportData;
}

// Run the test if this file is executed directly
if (require.main === module) {
  runAuthDebug().catch(console.error);
}

module.exports = { runAuthDebug };
