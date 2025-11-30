// e2e-tests/authenticated_routes_debug.js - Debug authenticated routes to see why they show fallback
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
  const filename = `debug_${name}_${timestamp()}.png`;
  const filepath = path.join(SCREENSHOT_DIR, filename);
  await page.screenshot({ path: filepath, fullPage: true });
  console.log(`📸 Screenshot: ${filename}`);
  return filename;
}

async function debugAuthenticatedRoute(page, routeInfo) {
  console.log(`\n🔍 DEBUGGING: ${routeInfo.name}`);
  console.log(`🔗 URL: ${BASE_URL}${routeInfo.path}`);
  console.log(`${'='.repeat(60)}`);
  
  // Capture console logs
  const consoleMessages = [];
  page.on('console', msg => {
    const text = msg.text();
    consoleMessages.push({ type: msg.type(), text });
    if (text.includes('Flutter') || text.includes('Error') || text.includes('NCL')) {
      console.log(`📝 ${msg.type()}: ${text}`);
    }
  });
  
  page.on('pageerror', error => {
    console.log(`🚨 Page Error: ${error.message}`);
    consoleMessages.push({ type: 'error', text: error.message });
  });
  
  try {
    // Navigate with longer timeout
    console.log('🚀 Navigating to route...');
    await page.goto(`${BASE_URL}${routeInfo.path}`, { 
      waitUntil: 'networkidle',
      timeout: 30000 
    });
    
    // Wait for various time intervals to see loading progression
    for (let i = 1; i <= 10; i++) {
      await sleep(2000); // Wait 2 seconds
      
      const bodyText = await page.textContent('body');
      const bodyTextLength = bodyText.length;
      
      // Check for Flutter elements
      const flutterElements = await page.$$('flutter-view, flt-scene-host, [flt-semantic-role]');
      const hasFlutterElements = flutterElements.length > 0;
      
      // Check for fallback elements
      const fallbackContainer = await page.$('#flutter-fallback-container');
      const hasFallback = !!fallbackContainer;
      
      // Check for specific content
      const hasExpectedContent = routeInfo.expectedContent.some(content => bodyText.includes(content));
      
      console.log(`⏰ T+${i*2}s: Length=${bodyTextLength}, Flutter=${hasFlutterElements}, Fallback=${hasFallback}, Expected=${hasExpectedContent}`);
      
      // Take screenshot at key intervals
      if (i === 3 || i === 6 || i === 10) {
        await takeScreenshot(page, `${routeInfo.name.toLowerCase().replace(/\s+/g, '_')}_t${i*2}s`);
      }
      
      // If we have stable content, break early
      if (bodyTextLength > 2000 && (hasFlutterElements || hasExpectedContent)) {
        console.log('✅ Stable content detected, stopping wait');
        break;
      }
    }
    
    // Final analysis
    console.log('\n📊 FINAL ANALYSIS:');
    
    const finalBodyText = await page.textContent('body');
    const finalBodyTextLength = finalBodyText.length;
    
    // Check for Flutter indicators
    const flutterIndicators = [
      'flutter-view',
      'flt-scene-host',
      'flt-semantic',
      'CanvasKit',
      'engine',
      'NCLApp'
    ];
    
    const flutterChecks = flutterIndicators.map(indicator => ({
      indicator,
      found: finalBodyText.includes(indicator)
    }));
    
    console.log('🦋 Flutter Indicators:');
    flutterChecks.forEach(check => {
      console.log(`  ${check.found ? '✅' : '❌'} ${check.indicator}`);
    });
    
    // Check for fallback indicators
    const fallbackIndicators = [
      'Welcome to NCL',
      'flutter-fallback-container',
      'Demo Credentials',
      'Sign In'
    ];
    
    const fallbackChecks = fallbackIndicators.map(indicator => ({
      indicator,
      found: finalBodyText.includes(indicator)
    }));
    
    console.log('🔄 Fallback Indicators:');
    fallbackChecks.forEach(check => {
      console.log(`  ${check.found ? '✅' : '❌'} ${check.indicator}`);
    });
    
    // Check for expected content
    const contentChecks = routeInfo.expectedContent.map(content => ({
      content,
      found: finalBodyText.includes(content)
    }));
    
    console.log('🎯 Expected Content:');
    contentChecks.forEach(check => {
      console.log(`  ${check.found ? '✅' : '❌'} "${check.content}"`);
    });
    
    // Determine what we're actually seeing
    let contentType = 'UNKNOWN';
    let confidence = 0;
    
    if (flutterChecks.some(check => check.found)) {
      contentType = 'FLUTTER_LOADING';
      confidence = flutterChecks.filter(check => check.found).length / flutterChecks.length;
    } else if (fallbackChecks.some(check => check.found)) {
      contentType = 'FALLBACK_ACTIVE';
      confidence = fallbackChecks.filter(check => check.found).length / fallbackChecks.length;
    } else if (finalBodyTextLength > 1000) {
      contentType = 'SOME_CONTENT';
      confidence = 0.5;
    } else {
      contentType = 'EMPTY_OR_ERROR';
      confidence = 0.2;
    }
    
    console.log(`\n🎯 CONCLUSION: ${contentType} (confidence: ${(confidence * 100).toFixed(1)}%)`);
    
    // Check page title and URL
    const title = await page.title();
    const url = page.url();
    console.log(`📄 Title: "${title}"`);
    console.log(`🔗 Final URL: "${url}"`);
    
    // Look for any redirects
    if (url !== `${BASE_URL}${routeInfo.path}`) {
      console.log(`🔄 REDIRECT DETECTED: ${BASE_URL}${routeInfo.path} → ${url}`);
    }
    
    return {
      routeName: routeInfo.name,
      path: routeInfo.path,
      title,
      finalUrl: url,
      bodyTextLength: finalBodyTextLength,
      contentType,
      confidence,
      flutterChecks,
      fallbackChecks,
      contentChecks,
      consoleMessages: consoleMessages.filter(msg => 
        msg.type === 'error' || 
        msg.text.includes('Flutter') || 
        msg.text.includes('NCL') ||
        msg.text.includes('Error')
      ),
      hasExpectedContent: contentChecks.some(check => check.found),
      success: contentChecks.some(check => check.found) || contentType === 'FLUTTER_LOADING'
    };
    
  } catch (error) {
    console.error(`❌ Error debugging ${routeInfo.name}:`, error.message);
    return {
      routeName: routeInfo.name,
      path: routeInfo.path,
      error: error.message,
      success: false
    };
  }
}

async function debugAuthenticatedRoutes() {
  console.log('🔍 DEBUGGING AUTHENTICATED ROUTES');
  console.log('==================================');
  
  const browser = await chromium.launch({ 
    headless: false,
    devtools: true 
  });
  const context = await browser.newContext({
    viewport: { width: 1280, height: 720 }
  });
  
  // Focus on the authenticated routes that are showing fallback
  const AUTHENTICATED_ROUTES = [
    { path: '/customer/home', name: 'Customer Home', expectedContent: ['Dashboard', 'Services', 'Bookings', 'Profile'] },
    { path: '/staff/home', name: 'Staff Home', expectedContent: ['Dashboard', 'Schedule', 'Jobs', 'Profile'] },
    { path: '/admin/home', name: 'Admin Home', expectedContent: ['Dashboard', 'Overview', 'Statistics', 'Management'] }
  ];
  
  const results = [];
  
  for (const routeInfo of AUTHENTICATED_ROUTES) {
    const page = await context.newPage();
    const result = await debugAuthenticatedRoute(page, routeInfo);
    results.push(result);
    await page.close();
    
    // Small delay between tests
    await sleep(2000);
  }
  
  await browser.close();
  
  // Generate comprehensive debug report
  console.log('\n\n📊 AUTHENTICATED ROUTES DEBUG REPORT');
  console.log('===================================');
  
  console.log('\n📈 SUMMARY:');
  results.forEach(result => {
    console.log(`\n📍 ${result.routeName}:`);
    console.log(`  📊 Content Type: ${result.contentType}`);
    console.log(`  📈 Confidence: ${(result.confidence * 100).toFixed(1)}%`);
    console.log(`  ✅ Success: ${result.success ? 'YES' : 'NO'}`);
    console.log(`  📝 Body Length: ${result.bodyTextLength || 'N/A'}`);
    
    if (result.finalUrl && result.finalUrl !== `${BASE_URL}${result.path}`) {
      console.log(`  🔄 Redirect: YES (${result.finalUrl})`);
    }
    
    if (result.consoleMessages && result.consoleMessages.length > 0) {
      console.log(`  📝 Console Messages: ${result.consoleMessages.length} important messages`);
      result.consoleMessages.forEach(msg => {
        console.log(`    ${msg.type}: ${msg.text}`);
      });
    }
  });
  
  // Save detailed debug report
  const reportData = {
    timestamp: new Date().toISOString(),
    results
  };
  
  const reportPath = path.join(SCREENSHOT_DIR, `authenticated_debug_report_${timestamp()}.json`);
  fs.writeFileSync(reportPath, JSON.stringify(reportData, null, 2));
  console.log(`\n📄 Detailed debug report saved: ${reportPath}`);
  
  return reportData;
}

// Run the test if this file is executed directly
if (require.main === module) {
  debugAuthenticatedRoutes().catch(console.error);
}

module.exports = { debugAuthenticatedRoutes };
