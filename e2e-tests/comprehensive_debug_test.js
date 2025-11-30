// e2e-tests/comprehensive_debug_test.js - Complete debugging of Flutter app
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
  const filename = `comprehensive_${name}_${timestamp()}.png`;
  const filepath = path.join(SCREENSHOT_DIR, filename);
  await page.screenshot({ path: filepath, fullPage: true });
  console.log(`📸 Screenshot: ${filename}`);
  return filename;
}

async function comprehensiveDebug(page, route) {
  console.log(`\n🔍 COMPREHENSIVE DEBUG: ${route}`);
  console.log(`${'='.repeat(60)}`);
  
  // Capture ALL console messages
  const allMessages = [];
  page.on('console', msg => {
    const text = msg.text();
    const logEntry = { type: msg.type(), text, timestamp: new Date().toISOString() };
    allMessages.push(logEntry);
    
    // Log all messages for comprehensive debugging
    console.log(`📝 ${msg.type().toUpperCase()}: ${text}`);
  });
  
  // Capture page errors
  page.on('pageerror', error => {
    const errorEntry = { 
      type: 'pageerror', 
      message: error.message, 
      stack: error.stack,
      timestamp: new Date().toISOString()
    };
    allMessages.push(errorEntry);
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
      allMessages.push(errorEntry);
      console.log(`🌐 NETWORK ERROR: ${request.url()} - ${failure.errorText}`);
    }
  });
  
  // Capture response codes
  page.on('response', response => {
    if (response.status() >= 400) {
      console.log(`🚨 HTTP ERROR: ${response.status()} - ${response.url()}`);
    }
  });
  
  try {
    console.log(`🚀 Navigating to: ${BASE_URL}${route}`);
    await page.goto(`${BASE_URL}${route}`, { waitUntil: 'networkidle' });
    
    // Wait longer for any async operations
    console.log(`⏳ Waiting 10 seconds for Flutter to fully initialize...`);
    await sleep(10000);
    
    // Take screenshot
    await takeScreenshot(page, route.replace(/\//g, '_'));
    
    // Analyze page content
    const bodyText = await page.textContent('body');
    const bodyTextLength = bodyText.length;
    const title = await page.title();
    
    console.log(`\n📊 PAGE ANALYSIS:`);
    console.log(`📄 Title: "${title}"`);
    console.log(`📝 Body Length: ${bodyTextLength}`);
    
    // Check for Flutter indicators
    const flutterIndicators = [
      'flutter-view',
      'flt-scene-host', 
      'flt-semantic',
      'flutter-app'
    ];
    
    const flutterChecks = flutterIndicators.map(indicator => ({
      indicator,
      found: bodyText.includes(indicator)
    }));
    
    const hasFlutter = flutterChecks.some(check => check.found);
    console.log(`🦋 Flutter Indicators:`);
    flutterChecks.forEach(check => {
      console.log(`  ${check.found ? '✅' : '❌'} ${check.indicator}`);
    });
    
    // Check for error messages in body
    const errorIndicators = [
      'Error',
      'Exception',
      'Failed to load',
      'TypeError',
      'ReferenceError',
      'undefined',
      'null',
      'Cannot read property',
      'Cannot access'
    ];
    
    const bodyErrors = errorIndicators.map(indicator => ({
      indicator,
      found: bodyText.includes(indicator)
    })).filter(check => check.found);
    
    if (bodyErrors.length > 0) {
      console.log(`🚨 Body Error Indicators:`);
      bodyErrors.forEach(error => console.log(`  - ${error.indicator}`));
    }
    
    // Check for any actual content (not just CSS)
    const hasActualContent = bodyText.length > 1000 && 
                           !bodyText.startsWith('flutter-view flt-scene-host');
    
    console.log(`🎯 Has Actual Content: ${hasActualContent ? 'YES' : 'NO'}`);
    
    // Show first 500 characters of body text
    console.log(`📝 Body Preview (first 500 chars):`);
    console.log(`"${bodyText.substring(0, 500)}..."`);
    
    // Categorize messages
    const errorMessages = allMessages.filter(msg => 
      msg.type === 'error' || 
      msg.type === 'pageerror' || 
      msg.type === 'networkerror'
    );
    
    const warningMessages = allMessages.filter(msg => 
      msg.type === 'warning' ||
      (msg.text && msg.text.includes('Warning'))
    );
    
    const debugMessages = allMessages.filter(msg => 
      msg.type === 'debug' ||
      (msg.text && msg.text.includes('debug'))
    );
    
    console.log(`\n📊 MESSAGE ANALYSIS:`);
    console.log(`📝 Total Messages: ${allMessages.length}`);
    console.log(`🚨 Errors: ${errorMessages.length}`);
    console.log(`⚠️  Warnings: ${warningMessages.length}`);
    console.log(`🐛 Debug: ${debugMessages.length}`);
    
    if (errorMessages.length > 0) {
      console.log(`\n🚨 ERROR MESSAGES:`);
      errorMessages.forEach((msg, index) => {
        console.log(`\n${index + 1}. ${msg.type.toUpperCase()}:`);
        console.log(`   ${msg.text || msg.message}`);
        if (msg.stack) {
          console.log(`   Stack: ${msg.stack.split('\n')[0]}`);
        }
      });
    }
    
    if (warningMessages.length > 0) {
      console.log(`\n⚠️  WARNING MESSAGES:`);
      warningMessages.forEach((msg, index) => {
        console.log(`${index + 1}. ${msg.text}`);
      });
    }
    
    return {
      route,
      title,
      bodyTextLength,
      hasFlutter,
      hasActualContent,
      flutterChecks,
      bodyErrors,
      totalMessages: allMessages.length,
      errorMessages: errorMessages.length,
      warningMessages: warningMessages.length,
      debugMessages: debugMessages.length,
      allMessages: allMessages.slice(-20) // Keep last 20 messages
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

async function runComprehensiveDebug() {
  console.log('🔍 COMPREHENSIVE FLUTTER DEBUG TEST');
  console.log('===================================');
  
  const browser = await chromium.launch({ 
    headless: false,
    devtools: true 
  });
  const context = await browser.newContext({
    viewport: { width: 1280, height: 720 }
  });
  
  const routes = ['/', '/login/customer', '/customer/home', '/staff/home', '/admin/home'];
  const results = [];
  
  for (const route of routes) {
    const page = await context.newPage();
    const result = await comprehensiveDebug(page, route);
    results.push(result);
    await page.close();
    
    // Small delay between tests
    await sleep(3000);
  }
  
  await browser.close();
  
  // Generate comprehensive report
  console.log('\n\n📊 COMPREHENSIVE DEBUG REPORT');
  console.log('===============================');
  
  results.forEach(result => {
    console.log(`\n📍 ${result.route}:`);
    console.log(`  📄 Title: "${result.title || 'N/A'}"`);
    console.log(`  📝 Body Length: ${result.bodyTextLength || 'N/A'}`);
    console.log(`  🦋 Flutter: ${result.hasFlutter ? 'YES' : 'NO'}`);
    console.log(`  🎯 Actual Content: ${result.hasActualContent ? 'YES' : 'NO'}`);
    console.log(`  📝 Messages: ${result.totalMessages || 0} total`);
    console.log(`  🚨 Errors: ${result.errorMessages || 0}`);
    console.log(`  ⚠️  Warnings: ${result.warningMessages || 0}`);
    console.log(`  🐛 Debug: ${result.debugMessages || 0}`);
    
    if (result.error) {
      console.log(`  ❌ Error: ${result.error}`);
    }
  });
  
  // Save detailed results
  const reportData = {
    timestamp: new Date().toISOString(),
    results
  };
  
  const reportPath = path.join(SCREENSHOT_DIR, `comprehensive_debug_report_${timestamp()}.json`);
  fs.writeFileSync(reportPath, JSON.stringify(reportData, null, 2));
  console.log(`\n📄 Comprehensive debug report saved: ${reportPath}`);
  
  return reportData;
}

// Run the test if this file is executed directly
if (require.main === module) {
  runComprehensiveDebug().catch(console.error);
}

module.exports = { runComprehensiveDebug };
