// e2e-tests/complete_navigation_test.js - Test all pages across all user types
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
  const filename = `navigation_${name}_${timestamp()}.png`;
  const filepath = path.join(SCREENSHOT_DIR, filename);
  await page.screenshot({ path: filepath, fullPage: true });
  console.log(`📸 Screenshot: ${filename}`);
  return filename;
}

// Define all expected pages for each user type
const ALL_PAGES = {
  customer: [
    { path: '/customer/home', name: 'Customer Home', expectedContent: ['Dashboard', 'Bookings', 'Services'] },
    { path: '/customer/bookings', name: 'Customer Bookings', expectedContent: ['My Bookings', 'Upcoming', 'History'] },
    { path: '/customer/services', name: 'Customer Services', expectedContent: ['Services', 'Categories', 'Book Now'] },
    { path: '/customer/account', name: 'Customer Account', expectedContent: ['Profile', 'Settings', 'Personal Info'] },
    { path: '/customer/booking/confirmation', name: 'Booking Confirmation', expectedContent: ['Confirmation', 'Details', 'Status'] },
    { path: '/register/customer', name: 'Customer Registration', expectedContent: ['Register', 'Sign Up', 'Create Account'] }
  ],
  staff: [
    { path: '/staff/home', name: 'Staff Home', name: 'Staff Dashboard', expectedContent: ['Dashboard', 'Schedule', 'Jobs'] },
    { path: '/staff/schedule', name: 'Staff Schedule', expectedContent: ['Schedule', 'Calendar', 'Shifts'] },
    { path: '/staff/jobs', name: 'Staff Jobs', expectedContent: ['Jobs', 'Assignments', 'Tasks'] },
    { path: '/staff/history', name: 'Staff History', expectedContent: ['History', 'Completed', 'Records'] },
    { path: '/staff/availability', name: 'Staff Availability', expectedContent: ['Availability', 'Time Off', 'Schedule'] },
    { path: '/staff/profile', name: 'Staff Profile', expectedContent: ['Profile', 'Information', 'Settings'] }
  ],
  admin: [
    { path: '/admin/home', name: 'Admin Home', expectedContent: ['Dashboard', 'Overview', 'Statistics'] },
    { path: '/admin/users', name: 'Admin Users', expectedContent: ['Users', 'Management', 'Accounts'] },
    { path: '/admin/staff', name: 'Admin Staff', expectedContent: ['Staff', 'Employees', 'Team'] },
    { path: '/admin/services', name: 'Admin Services', expectedContent: ['Services', 'Management', 'Offerings'] },
    { path: '/admin/bookings', name: 'Admin Bookings', expectedContent: ['Bookings', 'Management', 'Overview'] },
    { path: '/admin/reports', name: 'Admin Reports', expectedContent: ['Reports', 'Analytics', 'Data'] },
    { path: '/admin/settings', name: 'Admin Settings', expectedContent: ['Settings', 'Configuration', 'System'] }
  ]
};

async function testPageNavigation(page, userType, pageInfo) {
  console.log(`\n📍 Testing ${userType.toUpperCase()}: ${pageInfo.name}`);
  console.log(`🔗 URL: ${BASE_URL}${pageInfo.path}`);
  
  try {
    // Navigate to the page
    await page.goto(`${BASE_URL}${pageInfo.path}`, { waitUntil: 'networkidle' });
    await sleep(3000); // Wait for content to load
    
    // Take screenshot
    await takeScreenshot(page, `${userType}_${pageInfo.name.toLowerCase().replace(/\s+/g, '_')}`);
    
    // Check page title
    const title = await page.title();
    console.log(`📄 Page Title: "${title}"`);
    
    // Check body content
    const bodyText = await page.textContent('body');
    const bodyTextLength = bodyText.length;
    console.log(`📝 Body Text Length: ${bodyTextLength}`);
    
    // Check for expected content
    const contentChecks = pageInfo.expectedContent.map(content => ({
      content,
      found: bodyText.includes(content)
    }));
    
    console.log(`🔍 Content Checks:`);
    contentChecks.forEach(check => {
      console.log(`  ${check.found ? '✅' : '❌'} "${check.content}"`);
    });
    
    // Check for error indicators
    const hasError = bodyText.includes('Error') || bodyText.includes('Not Found') || bodyText.includes('404');
    const hasFallback = bodyText.includes('Welcome to NCL') || bodyText.includes('Login');
    
    // Determine page status
    let pageStatus = 'UNKNOWN';
    if (hasError) {
      pageStatus = 'ERROR';
    } else if (hasFallback && bodyTextLength < 2000) {
      pageStatus = 'FALLBACK_ACTIVE';
    } else if (contentChecks.some(check => check.found)) {
      pageStatus = 'CONTENT_FOUND';
    } else if (bodyTextLength > 1000) {
      pageStatus = 'HAS_CONTENT';
    } else {
      pageStatus = 'EMPTY_OR_LOADING';
    }
    
    console.log(`📊 Page Status: ${pageStatus}`);
    
    return {
      userType,
      pageName: pageInfo.name,
      path: pageInfo.path,
      title,
      bodyTextLength,
      contentChecks,
      pageStatus,
      hasError,
      hasFallback,
      success: !hasError && (pageStatus === 'CONTENT_FOUND' || pageStatus === 'HAS_CONTENT')
    };
    
  } catch (error) {
    console.error(`❌ Error testing ${pageInfo.name}:`, error.message);
    return {
      userType,
      pageName: pageInfo.name,
      path: pageInfo.path,
      error: error.message,
      success: false
    };
  }
}

async function testAllUserTypes() {
  console.log('🌟 COMPLETE NAVIGATION TEST - ALL PAGES');
  console.log('=====================================');
  
  const browser = await chromium.launch({ 
    headless: false,
    devtools: true 
  });
  const context = await browser.newContext({
    viewport: { width: 1280, height: 720 }
  });
  
  const results = [];
  const summary = {
    customer: { total: 0, success: 0, failed: 0 },
    staff: { total: 0, success: 0, failed: 0 },
    admin: { total: 0, success: 0, failed: 0 }
  };
  
  // Test each user type
  for (const [userType, pages] of Object.entries(ALL_PAGES)) {
    console.log(`\n\n🎯 TESTING ${userType.toUpperCase()} PAGES`);
    console.log(`${'='.repeat(50)}`);
    
    const page = await context.newPage();
    
    for (const pageInfo of pages) {
      summary[userType].total++;
      
      const result = await testPageNavigation(page, userType, pageInfo);
      results.push(result);
      
      if (result.success) {
        summary[userType].success++;
      } else {
        summary[userType].failed++;
      }
      
      // Small delay between pages
      await sleep(1000);
    }
    
    await page.close();
  }
  
  await browser.close();
  
  // Generate comprehensive report
  console.log('\n\n📊 COMPREHENSIVE NAVIGATION REPORT');
  console.log('==================================');
  
  console.log('\n📈 SUMMARY BY USER TYPE:');
  Object.entries(summary).forEach(([userType, stats]) => {
    const successRate = stats.total > 0 ? (stats.success / stats.total * 100).toFixed(1) : '0.0';
    console.log(`\n👤 ${userType.toUpperCase()}:`);
    console.log(`  Total Pages: ${stats.total}`);
    console.log(`  ✅ Successful: ${stats.success}`);
    console.log(`  ❌ Failed: ${stats.failed}`);
    console.log(`  📊 Success Rate: ${successRate}%`);
  });
  
  console.log('\n📋 DETAILED RESULTS:');
  console.log('==================');
  
  results.forEach(result => {
    console.log(`\n📍 ${result.userType.toUpperCase()} - ${result.pageName}:`);
    console.log(`  📁 Path: ${result.path}`);
    console.log(`  📄 Title: "${result.title || 'N/A'}"`);
    console.log(`  📝 Content Length: ${result.bodyTextLength || 'N/A'}`);
    console.log(`  📊 Status: ${result.pageStatus || result.error || 'UNKNOWN'}`);
    console.log(`  ✅ Success: ${result.success ? 'YES' : 'NO'}`);
    
    if (result.contentChecks) {
      const foundContent = result.contentChecks.filter(check => check.found);
      if (foundContent.length > 0) {
        console.log(`  🔍 Found Content: ${foundContent.map(c => `"${c.content}"`).join(', ')}`);
      }
    }
  });
  
  // Calculate overall statistics
  const totalTests = results.length;
  const successfulTests = results.filter(r => r.success).length;
  const overallSuccessRate = (successfulTests / totalTests * 100).toFixed(1);
  
  console.log(`\n\n🎯 OVERALL STATISTICS:`);
  console.log(`===================`);
  console.log(`📊 Total Pages Tested: ${totalTests}`);
  console.log(`✅ Successful: ${successfulTests}`);
  console.log(`❌ Failed: ${totalTests - successfulTests}`);
  console.log(`📈 Overall Success Rate: ${overallSuccessRate}%`);
  
  // Save results to file
  const reportData = {
    timestamp: new Date().toISOString(),
    summary,
    overall: {
      total: totalTests,
      successful: successfulTests,
      failed: totalTests - successfulTests,
      successRate: parseFloat(overallSuccessRate)
    },
    results
  };
  
  const reportPath = path.join(SCREENSHOT_DIR, `complete_navigation_report_${timestamp()}.json`);
  fs.writeFileSync(reportPath, JSON.stringify(reportData, null, 2));
  console.log(`\n📄 Detailed report saved: ${reportPath}`);
  
  return reportData;
}

// Run the test if this file is executed directly
if (require.main === module) {
  testAllUserTypes().catch(console.error);
}

module.exports = { testAllUserTypes };
