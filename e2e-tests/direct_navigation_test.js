// e2e-tests/direct_navigation_test.js - Test direct navigation to authenticated pages
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
  const filename = `direct_nav_${name}_${timestamp()}.png`;
  const filepath = path.join(SCREENSHOT_DIR, filename);
  await page.screenshot({ path: filepath, fullPage: true });
  console.log(`📸 Screenshot: ${filename}`);
  return filename;
}

async function testDirectNavigation(page, routeInfo) {
  console.log(`\n📍 Testing Direct Navigation: ${routeInfo.name}`);
  console.log(`🔗 URL: ${BASE_URL}${routeInfo.path}`);
  
  try {
    // Navigate directly to the route
    await page.goto(`${BASE_URL}${routeInfo.path}`, { waitUntil: 'networkidle' });
    await sleep(5000); // Wait for content to load
    
    // Take screenshot
    await takeScreenshot(page, routeInfo.name.toLowerCase().replace(/\s+/g, '_'));
    
    // Analyze the page
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
    
    console.log('🦋 Flutter Indicators:');
    flutterChecks.forEach(check => {
      console.log(`  ${check.found ? '✅' : '❌'} ${check.indicator}`);
    });
    
    // Check for fallback indicators
    const fallbackIndicators = [
      'Welcome to NCL',
      'flutter-fallback-container',
      'Login'
    ];
    
    const fallbackChecks = fallbackIndicators.map(indicator => ({
      indicator,
      found: bodyText.includes(indicator)
    }));
    
    console.log('🔄 Fallback Indicators:');
    fallbackChecks.forEach(check => {
      console.log(`  ${check.found ? '✅' : '❌'} ${check.indicator}`);
    });
    
    // Check for expected content
    const contentChecks = routeInfo.expectedContent.map(content => ({
      content,
      found: bodyText.includes(content)
    }));
    
    console.log('🎯 Expected Content:');
    contentChecks.forEach(check => {
      console.log(`  ${check.found ? '✅' : '❌'} "${check.content}"`);
    });
    
    // Determine what we're seeing
    let contentType = 'UNKNOWN';
    if (flutterChecks.some(check => check.found)) {
      contentType = 'FLUTTER_LOADED';
    } else if (fallbackChecks.some(check => check.found)) {
      contentType = 'FALLBACK_ACTIVE';
    } else if (bodyTextLength > 1000) {
      contentType = 'SOME_CONTENT';
    } else {
      contentType = 'EMPTY_OR_ERROR';
    }
    
    console.log(`📊 Content Type: ${contentType}`);
    
    // Check if we have the expected content
    const hasExpectedContent = contentChecks.some(check => check.found);
    const success = hasExpectedContent && !fallbackChecks.some(check => check.found);
    
    console.log(`✅ Success: ${success ? 'YES' : 'NO'}`);
    
    return {
      routeName: routeInfo.name,
      path: routeInfo.path,
      title,
      bodyTextLength,
      contentType,
      flutterChecks,
      fallbackChecks,
      contentChecks,
      hasExpectedContent,
      success
    };
    
  } catch (error) {
    console.error(`❌ Error testing ${routeInfo.name}:`, error.message);
    return {
      routeName: routeInfo.name,
      path: routeInfo.path,
      error: error.message,
      success: false
    };
  }
}

async function testAllDirectNavigation() {
  console.log('🌟 DIRECT NAVIGATION TEST');
  console.log('========================');
  
  const browser = await chromium.launch({ 
    headless: false,
    devtools: true 
  });
  const context = await browser.newContext({
    viewport: { width: 1280, height: 720 }
  });
  
  // Test all the routes that should exist
  const routes = [
    { path: '/customer/home', name: 'Customer Home', expectedContent: ['Dashboard', 'Services', 'Bookings', 'Profile'] },
    { path: '/staff/home', name: 'Staff Home', expectedContent: ['Dashboard', 'Schedule', 'Jobs', 'Profile'] },
    { path: '/admin/home', name: 'Admin Home', expectedContent: ['Dashboard', 'Overview', 'Statistics', 'Management'] },
  ];
  
  const results = [];
  
  for (const routeInfo of routes) {
    const page = await context.newPage();
    const result = await testDirectNavigation(page, routeInfo);
    results.push(result);
    await page.close();
    
    // Small delay between tests
    await sleep(2000);
  }
  
  await browser.close();
  
  // Generate report
  console.log('\n\n📊 DIRECT NAVIGATION REPORT');
  console.log('============================');
  
  const successfulTests = results.filter(r => r.success).length;
  const totalTests = results.length;
  const successRate = (successfulTests / totalTests * 100).toFixed(1);
  
  console.log(`\n📈 OVERALL STATISTICS:`);
  console.log(`📊 Total Routes Tested: ${totalTests}`);
  console.log(`✅ Successful: ${successfulTests}`);
  console.log(`❌ Failed: ${totalTests - successfulTests}`);
  console.log(`📈 Success Rate: ${successRate}%`);
  
  console.log('\n📋 DETAILED RESULTS:');
  console.log('==================');
  
  results.forEach(result => {
    console.log(`\n📍 ${result.routeName}:`);
    console.log(`  📁 Path: ${result.path}`);
    console.log(`  📄 Title: "${result.title || 'N/A'}"`);
    console.log(`  📝 Content Length: ${result.bodyTextLength || 'N/A'}`);
    console.log(`  📊 Content Type: ${result.contentType || result.error || 'UNKNOWN'}`);
    console.log(`  ✅ Success: ${result.success ? 'YES' : 'NO'}`);
    
    if (result.contentChecks) {
      const foundContent = result.contentChecks.filter(check => check.found);
      if (foundContent.length > 0) {
        console.log(`  🔍 Found Content: ${foundContent.map(c => `"${c.content}"`).join(', ')}`);
      }
    }
  });
  
  // Group results by content type
  const contentTypes = {};
  results.forEach(result => {
    const type = result.contentType || 'ERROR';
    if (!contentTypes[type]) {
      contentTypes[type] = [];
    }
    contentTypes[type].push(result.routeName);
  });
  
  console.log('\n📊 RESULTS BY CONTENT TYPE:');
  Object.entries(contentTypes).forEach(([type, routes]) => {
    console.log(`\n${type}: ${routes.length} routes`);
    routes.forEach(route => console.log(`  - ${route}`));
  });
  
  // Save results to file
  const reportData = {
    timestamp: new Date().toISOString(),
    summary: {
      total: totalTests,
      successful: successfulTests,
      failed: totalTests - successfulTests,
      successRate: parseFloat(successRate)
    },
    contentTypes,
    results
  };
  
  const reportPath = path.join(SCREENSHOT_DIR, `direct_navigation_report_${timestamp()}.json`);
  fs.writeFileSync(reportPath, JSON.stringify(reportData, null, 2));
  console.log(`\n📄 Detailed report saved: ${reportPath}`);
  
  return reportData;
}

// Run the test if this file is executed directly
if (require.main === module) {
  testAllDirectNavigation().catch(console.error);
}

module.exports = { testAllDirectNavigation };
