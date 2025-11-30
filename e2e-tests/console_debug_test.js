// e2e-tests/console_debug_test.js - Capture console errors for Staff and Admin routes
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
  const filename = `console_debug_${name}_${timestamp()}.png`;
  const filepath = path.join(SCREENSHOT_DIR, filename);
  await page.screenshot({ path: filepath, fullPage: true });
  console.log(`📸 Screenshot: ${filename}`);
  return filename;
}

async function debugRoute(page, route) {
  console.log(`\n🔍 DEBUGGING ROUTE: ${route}`);
  console.log(`${'='.repeat(50)}`);
  
  // Capture all console messages
  const consoleMessages = [];
  page.on('console', msg => {
    const text = msg.text();
    const logEntry = { type: msg.type(), text, timestamp: new Date().toISOString() };
    consoleMessages.push(logEntry);
    
    // Log important messages immediately
    if (text.includes('Error') || text.includes('Exception') || text.includes('Failed') || 
        text.includes('assert') || text.includes('undefined') || text.includes('null')) {
      console.log(`🚨 ${msg.type().toUpperCase()}: ${text}`);
    }
  });
  
  // Capture page errors
  page.on('pageerror', error => {
    const errorEntry = { 
      type: 'pageerror', 
      message: error.message, 
      stack: error.stack,
      timestamp: new Date().toISOString()
    };
    consoleMessages.push(errorEntry);
    console.log(`💥 PAGE ERROR: ${error.message}`);
  });
  
  // Capture network errors
  page.on('requestfailed', request => {
    const failure = request.failure();
    if (failure) {
      const errorEntry = {
        type: 'networkerror',
        url: request.url(),
        errorText: failure.errorText,
        timestamp: new Date().toISOString()
      };
      consoleMessages.push(errorEntry);
      console.log(`🌐 NETWORK ERROR: ${request.url()} - ${failure.errorText}`);
    }
  });
  
  try {
    console.log(`🚀 Navigating to: ${BASE_URL}${route}`);
    await page.goto(`${BASE_URL}${route}`, { waitUntil: 'networkidle' });
    
    // Wait longer for any async operations
    await sleep(5000);
    
    // Take screenshot
    await takeScreenshot(page, route.replace(/\//g, '_'));
    
    // Analyze page content
    const bodyText = await page.textContent('body');
    const bodyTextLength = bodyText.length;
    const title = await page.title();
    
    console.log(`📄 Title: "${title}"`);
    console.log(`📝 Body Length: ${bodyTextLength}`);
    
    // Check for Flutter indicators
    const flutterIndicators = [
      'flutter-view',
      'flt-scene-host', 
      'flt-semantic'
    ];
    
    const flutterChecks = flutterIndicators.map(indicator => ({
      indicator,
      found: bodyText.includes(indicator)
    }));
    
    const hasFlutter = flutterChecks.some(check => check.found);
    console.log(`🦋 Flutter Loaded: ${hasFlutter ? 'YES' : 'NO'}`);
    
    // Check for error messages in body
    const errorIndicators = [
      'Error',
      'Exception',
      'Failed to load',
      'TypeError',
      'ReferenceError',
      'undefined',
      'null'
    ];
    
    const bodyErrors = errorIndicators.map(indicator => ({
      indicator,
      found: bodyText.includes(indicator)
    })).filter(check => check.found);
    
    if (bodyErrors.length > 0) {
      console.log(`🚨 Body Error Indicators:`);
      bodyErrors.forEach(error => console.log(`  - ${error.indicator}`));
    }
    
    // Filter important console messages
    const importantMessages = consoleMessages.filter(msg => 
      msg.type === 'error' || 
      msg.type === 'pageerror' || 
      msg.type === 'networkerror' ||
      (msg.text && (
        msg.text.includes('Error') || 
        msg.text.includes('Exception') || 
        msg.text.includes('Failed') || 
        msg.text.includes('assert') ||
        msg.text.includes('undefined') ||
        msg.text.includes('null')
      ))
    );
    
    if (importantMessages.length > 0) {
      console.log(`\n📝 Important Console Messages (${importantMessages.length}):`);
      importantMessages.forEach((msg, index) => {
        console.log(`\n${index + 1}. ${msg.type.toUpperCase()}:`);
        console.log(`   ${msg.text || msg.message}`);
        if (msg.stack) {
          console.log(`   Stack: ${msg.stack.split('\n')[0]}`); // First line of stack
        }
      });
    } else {
      console.log(`✅ No important console messages detected`);
    }
    
    return {
      route,
      title,
      bodyTextLength,
      hasFlutter,
      flutterChecks,
      bodyErrors,
      consoleMessages: importantMessages,
      totalConsoleMessages: consoleMessages.length
    };
    
  } catch (error) {
    console.error(`❌ Error debugging route ${route}:`, error.message);
    return {
      route,
      error: error.message,
      hasFlutter: false
    };
  }
}

async function runConsoleDebug() {
  console.log('🔍 CONSOLE DEBUG TEST');
  console.log('====================');
  
  const browser = await chromium.launch({ 
    headless: false,
    devtools: true 
  });
  const context = await browser.newContext({
    viewport: { width: 1280, height: 720 }
  });
  
  // Focus on the problematic routes
  const routes = ['/customer/home', '/staff/home', '/admin/home'];
  const results = [];
  
  for (const route of routes) {
    const page = await context.newPage();
    const result = await debugRoute(page, route);
    results.push(result);
    await page.close();
    
    // Small delay between tests
    await sleep(2000);
  }
  
  await browser.close();
  
  // Generate report
  console.log('\n\n📊 CONSOLE DEBUG REPORT');
  console.log('========================');
  
  results.forEach(result => {
    console.log(`\n📍 ${result.route}:`);
    console.log(`  📄 Title: "${result.title || 'N/A'}"`);
    console.log(`  📝 Body Length: ${result.bodyTextLength || 'N/A'}`);
    console.log(`  🦋 Flutter: ${result.hasFlutter ? 'YES' : 'NO'}`);
    console.log(`  📝 Console Messages: ${result.totalConsoleMessages || 0} total, ${result.consoleMessages?.length || 0} important`);
    
    if (result.error) {
      console.log(`  ❌ Error: ${result.error}`);
    }
    
    if (result.bodyErrors && result.bodyErrors.length > 0) {
      console.log(`  🚨 Body Errors: ${result.bodyErrors.map(e => e.indicator).join(', ')}`);
    }
    
    if (result.consoleMessages && result.consoleMessages.length > 0) {
      console.log(`  📝 Important Messages:`);
      result.consoleMessages.forEach(msg => {
        console.log(`    - ${msg.text || msg.message}`);
      });
    }
  });
  
  // Save results
  const reportData = {
    timestamp: new Date().toISOString(),
    results
  };
  
  const reportPath = path.join(SCREENSHOT_DIR, `console_debug_report_${timestamp()}.json`);
  fs.writeFileSync(reportPath, JSON.stringify(reportData, null, 2));
  console.log(`\n📄 Debug report saved: ${reportPath}`);
  
  return reportData;
}

// Run the test if this file is executed directly
if (require.main === module) {
  runConsoleDebug().catch(console.error);
}

module.exports = { runConsoleDebug };
