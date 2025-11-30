// e2e-tests/test_overlap_fix.js - Test for UI overlap fix
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
  const filename = `overlap_test_${name}_${timestamp()}.png`;
  const filepath = path.join(SCREENSHOT_DIR, filename);
  await page.screenshot({ path: filepath, fullPage: true });
  console.log(`📸 Screenshot saved: ${filename}`);
  return filename;
}

async function testOverlapFix() {
  console.log('🔍 Testing UI Overlap Fix...');
  console.log('============================');
  
  const browser = await chromium.launch({ headless: false });
  const context = await browser.newContext({
    viewport: { width: 1280, height: 720 }
  });
  const page = await context.newPage();
  
  try {
    // Test 1: Navigate to home page
    console.log('\n📍 Step 1: Testing Home Page...');
    await page.goto(BASE_URL);
    await sleep(3000);
    
    const homeBodyText = await page.textContent('body');
    const hasHomeContent = homeBodyText.includes('Welcome to NCL');
    console.log(`🏠 Home Content: ${hasHomeContent ? '✅' : '❌'}`);
    
    await takeScreenshot(page, 'home_page');
    
    // Test 2: Navigate to customer login
    console.log('\n📍 Step 2: Navigate to Customer Login...');
    const customerButton = await page.$('button:has-text("Customer Login")');
    if (customerButton) {
      await customerButton.click();
      await sleep(3000);
      
      const customerBodyText = await page.textContent('body');
      const hasCustomerContent = customerBodyText.includes('Welcome Back');
      const hasEmailField = await page.$('input[type="email"]');
      const hasPasswordField = await page.$('input[type="password"]');
      
      console.log(`👤 Customer Content: ${hasCustomerContent ? '✅' : '❌'}`);
      console.log(`📧 Email Field: ${hasEmailField ? '✅' : '❌'}`);
      console.log(`🔒 Password Field: ${hasPasswordField ? '✅' : '❌'}`);
      
      // Check for overlap - look for duplicate content
      const duplicateWelcome = (customerBodyText.match(/Welcome to NCL/g) || []).length > 1;
      const duplicateCustomer = (customerBodyText.match(/Welcome Back/g) || []).length > 1;
      
      console.log(`🔄 Overlap Detection: ${duplicateWelcome || duplicateCustomer ? '❌ OVERLAP FOUND' : '✅ NO OVERLAP'}`);
      
      await takeScreenshot(page, 'customer_login');
    }
    
    // Test 3: Navigate back to home
    console.log('\n📍 Step 3: Navigate Back to Home...');
    
    // Try multiple back button selectors
    const backButton = await page.$('button:has-text("arrow_back")') ||
                      await page.$('button[aria-label*="back" i]') ||
                      await page.$('.back-button');
    
    if (backButton) {
      await backButton.click();
      await sleep(3000);
      console.log(`⬅️ Back Button Clicked: ✅`);
    } else {
      // Manually navigate back
      await page.goto(BASE_URL);
      await sleep(3000);
      console.log(`⬅️ Manual Navigation Back: ✅`);
    }
    
    const homeBodyTextAgain = await page.textContent('body');
    const hasHomeContentAgain = homeBodyTextAgain.includes('Welcome to NCL');
    
    // Check for overlap after returning home
    const duplicateWelcomeAgain = (homeBodyTextAgain.match(/Welcome to NCL/g) || []).length > 1;
    const hasCustomerRemnants = homeBodyTextAgain.includes('Welcome Back') || homeBodyTextAgain.includes('Demo Credentials');
    
    console.log(`🏠 Home Content (After Back): ${hasHomeContentAgain ? '✅' : '❌'}`);
    console.log(`🔄 Overlap After Back: ${duplicateWelcomeAgain || hasCustomerRemnants ? '❌ OVERLAP FOUND' : '✅ NO OVERLAP'}`);
    
    await takeScreenshot(page, 'home_after_back');
    
    // Test 4: Test staff login navigation
    console.log('\n📍 Step 4: Test Staff Login Navigation...');
    const staffButton = await page.$('button:has-text("Staff Access")');
    if (staffButton) {
      await staffButton.click();
      await sleep(3000);
      
      const staffBodyText = await page.textContent('body');
      const hasStaffContent = staffBodyText.includes('Staff Portal');
      const hasStaffEmail = await page.$('input[type="email"]');
      
      console.log(`👷 Staff Content: ${hasStaffContent ? '✅' : '❌'}`);
      console.log(`📧 Staff Email Field: ${hasStaffEmail ? '✅' : '❌'}`);
      
      // Check for overlap
      const duplicateHomeInStaff = staffBodyText.includes('Welcome to NCL');
      const duplicateCustomerInStaff = staffBodyText.includes('Welcome Back');
      
      console.log(`🔄 Staff Overlap: ${duplicateHomeInStaff || duplicateCustomerInStaff ? '❌ OVERLAP FOUND' : '✅ NO OVERLAP'}`);
      
      await takeScreenshot(page, 'staff_login');
    }
    
    // Test 5: Test admin login navigation
    console.log('\n📍 Step 5: Test Admin Login Navigation...');
    await page.goto(BASE_URL);
    await sleep(2000);
    
    const adminButton = await page.$('button:has-text("Admin Portal")');
    if (adminButton) {
      await adminButton.click();
      await sleep(3000);
      
      const adminBodyText = await page.textContent('body');
      const hasAdminContent = adminBodyText.includes('Admin System');
      const hasAdminEmail = await page.$('input[type="email"]');
      
      console.log(`👤 Admin Content: ${hasAdminContent ? '✅' : '❌'}`);
      console.log(`📧 Admin Email Field: ${hasAdminEmail ? '✅' : '❌'}`);
      
      // Check for overlap
      const duplicateHomeInAdmin = adminBodyText.includes('Welcome to NCL');
      const duplicateOthersInAdmin = adminBodyText.includes('Welcome Back') || adminBodyText.includes('Staff Portal');
      
      console.log(`🔄 Admin Overlap: ${duplicateHomeInAdmin || duplicateOthersInAdmin ? '❌ OVERLAP FOUND' : '✅ NO OVERLAP'}`);
      
      await takeScreenshot(page, 'admin_login');
    }
    
    console.log('\n📊 OVERLAP TEST SUMMARY');
    console.log('====================');
    console.log('✅ Navigation tests completed');
    console.log('✅ Screenshots saved for visual inspection');
    console.log('✅ Check screenshots for any visual overlap issues');
    
  } catch (error) {
    console.error('❌ Test failed:', error);
  } finally {
    await browser.close();
  }
}

// Run test if this file is executed directly
if (require.main === module) {
  testOverlapFix().catch(console.error);
}

module.exports = { testOverlapFix };
