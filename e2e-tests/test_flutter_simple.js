// test_flutter_simple.js - Simple test of Flutter pages
const { chromium } = require('playwright');

async function testFlutterSimple() {
  console.log('🧪 Simple Flutter Test...');
  
  const browser = await chromium.launch({ 
    headless: false,
    slowMo: 2000 
  });
  const page = await browser.newPage();
  await page.setViewportSize({ width: 1280, height: 720 });
  
  try {
    // Test Customer Login
    console.log('\n📍 Testing Customer Login...');
    await page.goto('http://localhost:8081/login/customer');
    await page.waitForTimeout(12000);
    
    // Take screenshot first
    await page.screenshot({ path: 'test-results/simple_customer_login.png', fullPage: true });
    
    // Check basic page content
    const pageTitle = await page.title();
    const pageUrl = page.url();
    const bodyText = await page.textContent('body');
    
    console.log(`Page Title: ${pageTitle}`);
    console.log(`Page URL: ${pageUrl}`);
    console.log(`Body Text Length: ${bodyText?.length || 0}`);
    
    if (bodyText && bodyText.length > 100) {
      console.log('✅ Page has content');
      console.log(`\n📄 Body Text Preview:\n${bodyText.substring(0, 500)}`);
      
      // Check for key elements
      const hasCustomerPortal = bodyText.includes('Customer Portal');
      const hasDemoCredentials = bodyText.includes('Demo Credentials');
      const hasEmailField = bodyText.includes('Email Address') || bodyText.includes('Email');
      const hasPasswordField = bodyText.includes('Password');
      const hasSignInButton = bodyText.includes('Sign In');
      
      console.log(`\n📊 Content Analysis:`);
      console.log(`Has Customer Portal: ${hasCustomerPortal ? '✅' : '❌'}`);
      console.log(`Has Demo Credentials: ${hasDemoCredentials ? '✅' : '❌'}`);
      console.log(`Has Email Field: ${hasEmailField ? '✅' : '❌'}`);
      console.log(`Has Password Field: ${hasPasswordField ? '✅' : '❌'}`);
      console.log(`Has Sign In Button: ${hasSignInButton ? '✅' : '❌'}`);
      
      if (hasCustomerPortal && hasDemoCredentials && hasEmailField && hasPasswordField) {
        console.log('\n🎉 Customer Login Screen is Working!');
      } else {
        console.log('\n⚠️  Customer Login Screen has issues');
      }
    } else {
      console.log('❌ Page has insufficient content');
    }
    
    // Test Staff Login
    console.log('\n📍 Testing Staff Login...');
    await page.goto('http://localhost:8081/login/staff');
    await page.waitForTimeout(12000);
    
    await page.screenshot({ path: 'test-results/simple_staff_login.png', fullPage: true });
    
    const staffBodyText = await page.textContent('body');
    console.log(`Staff Page Body Text Length: ${staffBodyText?.length || 0}`);
    
    if (staffBodyText && staffBodyText.length > 100) {
      const hasStaffPortal = staffBodyText.includes('Staff Portal');
      const hasDemoCredentials = staffBodyText.includes('Demo Credentials');
      const hasEmailField = staffBodyText.includes('Email Address') || staffBodyText.includes('Email');
      const hasPasswordField = staffBodyText.includes('Password');
      
      console.log(`\n📊 Staff Content Analysis:`);
      console.log(`Has Staff Portal: ${hasStaffPortal ? '✅' : '❌'}`);
      console.log(`Has Demo Credentials: ${hasDemoCredentials ? '✅' : '❌'}`);
      console.log(`Has Email Field: ${hasEmailField ? '✅' : '❌'}`);
      console.log(`Has Password Field: ${hasPasswordField ? '✅' : '❌'}`);
      
      if (hasStaffPortal && hasDemoCredentials && hasEmailField && hasPasswordField) {
        console.log('\n🎉 Staff Login Screen is Working!');
      } else {
        console.log('\n⚠️  Staff Login Screen has issues');
      }
    }
    
    // Test Admin Login
    console.log('\n📍 Testing Admin Login...');
    await page.goto('http://localhost:8081/login/admin');
    await page.waitForTimeout(12000);
    
    await page.screenshot({ path: 'test-results/simple_admin_login.png', fullPage: true });
    
    const adminBodyText = await page.textContent('body');
    console.log(`Admin Page Body Text Length: ${adminBodyText?.length || 0}`);
    
    if (adminBodyText && adminBodyText.length > 100) {
      const hasAdminSystem = adminBodyText.includes('Admin System');
      const hasDemoCredentials = adminBodyText.includes('Demo Credentials');
      const hasEmailField = adminBodyText.includes('Email Address') || adminBodyText.includes('Email');
      const hasPasswordField = adminBodyText.includes('Password');
      
      console.log(`\n📊 Admin Content Analysis:`);
      console.log(`Has Admin System: ${hasAdminSystem ? '✅' : '❌'}`);
      console.log(`Has Demo Credentials: ${hasDemoCredentials ? '✅' : '❌'}`);
      console.log(`Has Email Field: ${hasEmailField ? '✅' : '❌'}`);
      console.log(`Has Password Field: ${hasPasswordField ? '✅' : '❌'}`);
      
      if (hasAdminSystem && hasDemoCredentials && hasEmailField && hasPasswordField) {
        console.log('\n🎉 Admin Login Screen is Working!');
      } else {
        console.log('\n⚠️  Admin Login Screen has issues');
      }
    }
    
    // Test Home Page
    console.log('\n📍 Testing Home Page...');
    await page.goto('http://localhost:8081');
    await page.waitForTimeout(12000);
    
    await page.screenshot({ path: 'test-results/simple_home_page.png', fullPage: true });
    
    const homeBodyText = await page.textContent('body');
    console.log(`Home Page Body Text Length: ${homeBodyText?.length || 0}`);
    
    if (homeBodyText && homeBodyText.length > 100) {
      console.log(`\n📄 Home Page Text Preview:\n${homeBodyText.substring(0, 500)}`);
      
      const hasWelcome = homeBodyText.includes('Welcome') || homeBodyText.includes('NCL');
      const hasLoginOptions = homeBodyText.includes('Customer') && homeBodyText.includes('Staff') && homeBodyText.includes('Admin');
      
      console.log(`\n📊 Home Content Analysis:`);
      console.log(`Has Welcome Text: ${hasWelcome ? '✅' : '❌'}`);
      console.log(`Has Login Options: ${hasLoginOptions ? '✅' : '❌'}`);
      
      if (hasLoginOptions) {
        console.log('\n🎉 Home Page is Working!');
      } else {
        console.log('\n⚠️  Home Page has issues');
      }
    }
    
    console.log('\n📊 FINAL SUMMARY:');
    console.log('==================');
    console.log('✅ Screenshots saved in test-results/');
    console.log('   - simple_customer_login.png');
    console.log('   - simple_staff_login.png');
    console.log('   - simple_admin_login.png');
    console.log('   - simple_home_page.png');
    console.log('\n🎯 Check the screenshots to see the actual Flutter UI rendering');
    
  } catch (error) {
    console.error('❌ Test error:', error);
  } finally {
    await browser.close();
    console.log('🔚 Simple Flutter test completed');
  }
}

testFlutterSimple().catch(console.error);
