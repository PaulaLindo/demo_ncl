// e2e-tests/existing_routes_test.js - Test only the routes that actually exist in Flutter
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
  const filename = `existing_route_${name}_${timestamp()}.png`;
  const filepath = path.join(SCREENSHOT_DIR, filename);
  await page.screenshot({ path: filepath, fullPage: true });
  console.log(`📸 Screenshot: ${filename}`);
  return filename;
}

// Only test routes that actually exist in the Flutter app
const EXISTING_ROUTES = [
  { path: '/', name: 'Login Chooser', expectedContent: ['Welcome to NCL', 'Customer Login', 'Staff Access', 'Admin Portal'] },
  { path: '/login/customer', name: 'Customer Login', expectedContent: ['Welcome Back', 'Email Address', 'Password', 'Sign In'] },
  { path: '/login/staff', name: 'Staff Login', expectedContent: ['Staff Portal', 'Email Address', 'Password', 'Sign In'] },
  { path: '/login/admin', name: 'Admin Login', expectedContent: ['Admin System', 'Email Address', 'Password', 'Sign In'] },
  { path: '/register/customer', name: 'Customer Registration', expectedContent: ['Register', 'Sign Up', 'Create Account'] },
  { path: '/customer/home', name: 'Customer Home', expectedContent: ['Dashboard', 'Services', 'Bookings', 'Profile'] },
  { path: '/staff/home', name: 'Staff Home', expectedContent: ['Dashboard', 'Schedule', 'Jobs', 'Profile'] },
  { path: '/admin/home', name: 'Admin Home', expectedContent: ['Dashboard', 'Overview', 'Statistics', 'Management'] }
];

async function testExistingRoute(page, routeInfo) {
  console.log(`\n📍 Testing: ${routeInfo.name}`);
  console.log(`🔗 URL: ${BASE_URL}${routeInfo.path}`);
  
  try {
    // Navigate to the route
    await page.goto(`${BASE_URL}${routeInfo.path}`, { waitUntil: 'networkidle' });
    await sleep(3000); // Wait for content to load
    
    // Take screenshot
    await takeScreenshot(page, routeInfo.name.toLowerCase().replace(/\s+/g, '_'));
    
    // Check page title
    const title = await page.title();
    console.log(`📄 Page Title: "${title}"`);
    
    // Check body content
    const bodyText = await page.textContent('body');
    const bodyTextLength = bodyText.length;
    console.log(`📝 Body Text Length: ${bodyTextLength}`);
    
    // Check for expected content
    const contentChecks = routeInfo.expectedContent.map(content => ({
      content,
      found: bodyText.includes(content)
    }));
    
    console.log(`🔍 Content Checks:`);
    contentChecks.forEach(check => {
      console.log(`  ${check.found ? '✅' : '❌'} "${check.content}"`);
    });
    
    // Check if we have Flutter content or fallback
    const hasFlutterContent = bodyTextLength > 2000 && !bodyText.includes('Welcome to NCL');
    const hasFallbackContent = bodyText.includes('Welcome to NCL') || bodyText.includes('Login');
    const hasError = bodyText.includes('Error') || bodyText.includes('Not Found') || bodyText.includes('404');
    
    // Determine what type of content we're seeing
    let contentType = 'UNKNOWN';
    if (hasError) {
      contentType = 'ERROR';
    } else if (hasFlutterContent) {
      contentType = 'FLUTTER_CONTENT';
    } else if (hasFallbackContent) {
      contentType = 'FALLBACK_CONTENT';
    } else if (bodyTextLength > 500) {
      contentType = 'SOME_CONTENT';
    } else {
      contentType = 'EMPTY_OR_LOADING';
    }
    
    console.log(`📊 Content Type: ${contentType}`);
    
    // Determine success
    const hasExpectedContent = contentChecks.some(check => check.found);
    const success = !hasError && (hasExpectedContent || contentType === 'FLUTTER_CONTENT');
    
    console.log(`✅ Success: ${success ? 'YES' : 'NO'}`);
    
    return {
      routeName: routeInfo.name,
      path: routeInfo.path,
      title,
      bodyTextLength,
      contentChecks,
      contentType,
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

async function testAllExistingRoutes() {
  console.log('🌟 TESTING ALL EXISTING FLUTTER ROUTES');
  console.log('=======================================');
  
  const browser = await chromium.launch({ 
    headless: false,
    devtools: true 
  });
  const context = await browser.newContext({
    viewport: { width: 1280, height: 720 }
  });
  
  const results = [];
  
  console.log('\n🎯 TESTING ALL ROUTES');
  console.log(`${'='.repeat(50)}`);
  
  const page = await context.newPage();
  
  for (const routeInfo of EXISTING_ROUTES) {
    const result = await testExistingRoute(page, routeInfo);
    results.push(result);
    
    // Small delay between routes
    await sleep(1000);
  }
  
  await page.close();
  await browser.close();
  
  // Generate comprehensive report
  console.log('\n\n📊 EXISTING ROUTES TEST REPORT');
  console.log('===============================');
  
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
  
  const reportPath = path.join(SCREENSHOT_DIR, `existing_routes_report_${timestamp()}.json`);
  fs.writeFileSync(reportPath, JSON.stringify(reportData, null, 2));
  console.log(`\n📄 Detailed report saved: ${reportPath}`);
  
  return reportData;
}

// Run the test if this file is executed directly
if (require.main === module) {
  testAllExistingRoutes().catch(console.error);
}

module.exports = { testAllExistingRoutes };
