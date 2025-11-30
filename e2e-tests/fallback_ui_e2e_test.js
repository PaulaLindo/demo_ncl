// e2e-tests/fallback_ui_e2e_test.js - Enhanced E2E Test for Fallback UI
const { chromium } = require('playwright');
const fs = require('fs');
const path = require('path');

// Test configuration
const BASE_URL = 'http://localhost:8081';
const SCREENSHOT_DIR = path.join(__dirname, '..', 'test-results');
const TEST_TIMEOUT = 30000;

// Ensure screenshot directory exists
if (!fs.existsSync(SCREENSHOT_DIR)) {
  fs.mkdirSync(SCREENSHOT_DIR, { recursive: true });
}

// Test data
const CREDENTIALS = {
  customer: {
    email: 'customer@example.com',
    password: 'customer123',
    expectedTitle: 'Customer Login'
  },
  staff: {
    email: 'staff@example.com',
    password: 'staff123',
    expectedTitle: 'Staff Access'
  },
  admin: {
    email: 'admin@example.com',
    password: 'admin123',
    expectedTitle: 'Admin Portal'
  }
};

// Utility functions
function sleep(ms) {
  return new Promise(resolve => setTimeout(resolve, ms));
}

function timestamp() {
  return new Date().toISOString().replace(/[:.]/g, '-');
}

async function takeScreenshot(page, name) {
  const filename = `fallback_${name}_${timestamp()}.png`;
  const filepath = path.join(SCREENSHOT_DIR, filename);
  await page.screenshot({ path: filepath, fullPage: true });
  console.log(`📸 Screenshot saved: ${filename}`);
  return filename;
}

async function waitForElement(page, selector, timeout = 5000) {
  try {
    await page.waitForSelector(selector, { timeout });
    return true;
  } catch (error) {
    return false;
  }
}

// Test functions for Fallback UI
async function testFallbackHomePage(page) {
  console.log('\n🏠 Testing Fallback Home Page...');
  
  await page.goto(BASE_URL);
  await sleep(3000); // Wait for Flutter to load
  
  // Check page title
  const title = await page.title();
  console.log(`📄 Page Title: ${title}`);
  
  // Check for welcome text
  const bodyText = await page.textContent('body');
  const hasWelcomeText = bodyText.includes('Welcome to NCL');
  const hasProfessionalServices = bodyText.includes('Professional home services');
  console.log(`👋 Welcome Text: ${hasWelcomeText ? '✅' : '❌'}`);
  console.log(`🏢 Professional Services: ${hasProfessionalServices ? '✅' : '❌'}`);
  
  // Check for login buttons with multiple selectors
  const customerButton = await waitForElement(page, 'button:has-text("Customer Login")') ||
                        await waitForElement(page, '[data-testid="customer-login-button"]');
  const staffButton = await waitForElement(page, 'button:has-text("Staff Access")') ||
                      await waitForElement(page, '[data-testid="staff-access-button"]');
  const adminButton = await waitForElement(page, 'button:has-text("Admin Portal")') ||
                      await waitForElement(page, '[data-testid="admin-portal-button"]');
  
  console.log(`🔘 Customer Button: ${customerButton ? '✅' : '❌'}`);
  console.log(`👷 Staff Button: ${staffButton ? '✅' : '❌'}`);
  console.log(`👤 Admin Button: ${adminButton ? '✅' : '❌'}`);
  
  // Check for help button
  const helpButton = await waitForElement(page, 'button:has-text("Need help signing in?")');
  console.log(`❓ Help Button: ${helpButton ? '✅' : '❌'}`);
  
  await takeScreenshot(page, 'home_page');
  
  return {
    title,
    hasWelcomeText,
    hasProfessionalServices,
    customerButton,
    staffButton,
    adminButton,
    helpButton
  };
}

async function testFallbackCustomerLogin(page) {
  console.log('\n👤 Testing Fallback Customer Login...');
  
  // Navigate to customer login
  await page.goto(`${BASE_URL}/login/customer`);
  await sleep(3000);
  
  // Check page title and content
  const title = await page.title();
  const bodyText = await page.textContent('body');
  
  console.log(`📄 Page Title: ${title}`);
  console.log(`📏 Body Text Length: ${bodyText.length}`);
  
  // Check for key elements
  const hasCustomerPortal = bodyText.includes('Welcome Back') || bodyText.includes('Customer Login');
  const hasEmailField = await waitForElement(page, 'input[type="email"]') ||
                        await waitForElement(page, 'input[placeholder*="email" i]');
  const hasPasswordField = await waitForElement(page, 'input[type="password"]') ||
                          await waitForElement(page, 'input[placeholder*="password" i]');
  const hasLoginButton = await waitForElement(page, 'button:has-text("Sign In")') ||
                        await waitForElement(page, 'button:has-text("Login")');
  const hasDemoCredentials = bodyText.includes('customer@example.com') || 
                            bodyText.includes('Demo Credentials');
  const hasBackButton = await waitForElement(page, 'button:has-text("arrow_back")') ||
                       await waitForElement(page, 'button[aria-label*="back" i]');
  
  console.log(`🏢 Customer Portal: ${hasCustomerPortal ? '✅' : '❌'}`);
  console.log(`📧 Email Field: ${hasEmailField ? '✅' : '❌'}`);
  console.log(`🔒 Password Field: ${hasPasswordField ? '✅' : '❌'}`);
  console.log(`🔑 Login Button: ${hasLoginButton ? '✅' : '❌'}`);
  console.log(`📋 Demo Credentials: ${hasDemoCredentials ? '✅' : '❌'}`);
  console.log(`⬅️ Back Button: ${hasBackButton ? '✅' : '❌'}`);
  
  // Test form interaction
  let formTestPassed = false;
  if (hasEmailField && hasPasswordField) {
    try {
      await page.fill('input[type="email"]', 'test@example.com');
      await page.fill('input[type="password"]', 'testpassword');
      
      const emailValue = await page.inputValue('input[type="email"]');
      const passwordValue = await page.inputValue('input[type="password"]');
      
      formTestPassed = emailValue === 'test@example.com' && passwordValue === 'testpassword';
      console.log(`📝 Form Interaction: ${formTestPassed ? '✅' : '❌'}`);
    } catch (error) {
      console.log(`📝 Form Interaction: ❌ (${error.message})`);
    }
  }
  
  // Test demo credential click
  let credentialClickTest = false;
  if (hasDemoCredentials) {
    try {
      // Look for clickable demo credentials
      const credentialElements = await page.$$('text=customer@example.com');
      if (credentialElements.length > 0) {
        await credentialElements[0].click();
        await sleep(1000);
        
        // Check for snackbar or feedback
        const hasFeedback = bodyText.includes('copied') || bodyText.includes('Email copied');
        credentialClickTest = hasFeedback;
        console.log(`👆 Credential Click: ${credentialClickTest ? '✅' : '❌'}`);
      } else {
        console.log(`👆 Credential Click: ❌ (No clickable credentials found)`);
      }
    } catch (error) {
      console.log(`👆 Credential Click: ❌ (${error.message})`);
    }
  }
  
  await takeScreenshot(page, 'customer_login');
  
  return {
    title,
    hasCustomerPortal,
    hasEmailField,
    hasPasswordField,
    hasLoginButton,
    hasDemoCredentials,
    hasBackButton,
    formTestPassed,
    credentialClickTest
  };
}

async function testFallbackStaffLogin(page) {
  console.log('\n👷 Testing Fallback Staff Login...');
  
  await page.goto(`${BASE_URL}/login/staff`);
  await sleep(3000);
  
  const title = await page.title();
  const bodyText = await page.textContent('body');
  
  console.log(`📄 Page Title: ${title}`);
  console.log(`📏 Body Text Length: ${bodyText.length}`);
  
  const hasStaffPortal = bodyText.includes('Staff Portal') || bodyText.includes('Staff Access');
  const hasEmailField = await waitForElement(page, 'input[type="email"]') ||
                        await waitForElement(page, 'input[placeholder*="email" i]');
  const hasPasswordField = await waitForElement(page, 'input[type="password"]') ||
                          await waitForElement(page, 'input[placeholder*="password" i]');
  const hasLoginButton = await waitForElement(page, 'button:has-text("Sign In")') ||
                        await waitForElement(page, 'button:has-text("Login")');
  const hasDemoCredentials = bodyText.includes('staff@example.com') || 
                            bodyText.includes('Demo Credentials');
  const hasBackButton = await waitForElement(page, 'button:has-text("arrow_back")') ||
                       await waitForElement(page, 'button[aria-label*="back" i]');
  
  console.log(`🏢 Staff Portal: ${hasStaffPortal ? '✅' : '❌'}`);
  console.log(`📧 Email Field: ${hasEmailField ? '✅' : '❌'}`);
  console.log(`🔒 Password Field: ${hasPasswordField ? '✅' : '❌'}`);
  console.log(`🔑 Login Button: ${hasLoginButton ? '✅' : '❌'}`);
  console.log(`📋 Demo Credentials: ${hasDemoCredentials ? '✅' : '❌'}`);
  console.log(`⬅️ Back Button: ${hasBackButton ? '✅' : '❌'}`);
  
  await takeScreenshot(page, 'staff_login');
  
  return {
    title,
    hasStaffPortal,
    hasEmailField,
    hasPasswordField,
    hasLoginButton,
    hasDemoCredentials,
    hasBackButton
  };
}

async function testFallbackAdminLogin(page) {
  console.log('\n👤 Testing Fallback Admin Login...');
  
  await page.goto(`${BASE_URL}/login/admin`);
  await sleep(3000);
  
  const title = await page.title();
  const bodyText = await page.textContent('body');
  
  console.log(`📄 Page Title: ${title}`);
  console.log(`📏 Body Text Length: ${bodyText.length}`);
  
  const hasAdminPortal = bodyText.includes('Admin System') || bodyText.includes('Admin Portal');
  const hasEmailField = await waitForElement(page, 'input[type="email"]') ||
                        await waitForElement(page, 'input[placeholder*="email" i]');
  const hasPasswordField = await waitForElement(page, 'input[type="password"]') ||
                          await waitForElement(page, 'input[placeholder*="password" i]');
  const hasLoginButton = await waitForElement(page, 'button:has-text("Sign In")') ||
                        await waitForElement(page, 'button:has-text("Login")');
  const hasDemoCredentials = bodyText.includes('admin@example.com') || 
                            bodyText.includes('Demo Credentials');
  const hasBackButton = await waitForElement(page, 'button:has-text("arrow_back")') ||
                       await waitForElement(page, 'button[aria-label*="back" i]');
  
  console.log(`🏢 Admin Portal: ${hasAdminPortal ? '✅' : '❌'}`);
  console.log(`📧 Email Field: ${hasEmailField ? '✅' : '❌'}`);
  console.log(`🔒 Password Field: ${hasPasswordField ? '✅' : '❌'}`);
  console.log(`🔑 Login Button: ${hasLoginButton ? '✅' : '❌'}`);
  console.log(`📋 Demo Credentials: ${hasDemoCredentials ? '✅' : '❌'}`);
  console.log(`⬅️ Back Button: ${hasBackButton ? '✅' : '❌'}`);
  
  await takeScreenshot(page, 'admin_login');
  
  return {
    title,
    hasAdminPortal,
    hasEmailField,
    hasPasswordField,
    hasLoginButton,
    hasDemoCredentials,
    hasBackButton
  };
}

async function testFallbackNavigation(page) {
  console.log('\n🧭 Testing Fallback Navigation...');
  
  const navigationResults = [];
  
  // Test home to customer login
  await page.goto(BASE_URL);
  await sleep(2000);
  
  try {
    const customerButton = await page.$('button:has-text("Customer Login")');
    if (customerButton) {
      await customerButton.click();
      await sleep(3000);
      
      const currentUrl = page.url();
      const navigatedToCustomer = currentUrl.includes('/login/customer');
      console.log(`🏠➡️👤 Home to Customer: ${navigatedToCustomer ? '✅' : '❌'}`);
      navigationResults.push({ from: 'home', to: 'customer', success: navigatedToCustomer });
    } else {
      console.log(`🏠➡️👤 Home to Customer: ❌ (Button not found)`);
      navigationResults.push({ from: 'home', to: 'customer', success: false });
    }
  } catch (error) {
    console.log(`🏠➡️👤 Home to Customer: ❌ (${error.message})`);
    navigationResults.push({ from: 'home', to: 'customer', success: false });
  }
  
  // Test home to staff login
  await page.goto(BASE_URL);
  await sleep(2000);
  
  try {
    const staffButton = await page.$('button:has-text("Staff Access")');
    if (staffButton) {
      await staffButton.click();
      await sleep(3000);
      
      const currentUrl = page.url();
      const navigatedToStaff = currentUrl.includes('/login/staff');
      console.log(`🏠➡️👷 Home to Staff: ${navigatedToStaff ? '✅' : '❌'}`);
      navigationResults.push({ from: 'home', to: 'staff', success: navigatedToStaff });
    } else {
      console.log(`🏠➡️👷 Home to Staff: ❌ (Button not found)`);
      navigationResults.push({ from: 'home', to: 'staff', success: false });
    }
  } catch (error) {
    console.log(`🏠➡️👷 Home to Staff: ❌ (${error.message})`);
    navigationResults.push({ from: 'home', to: 'staff', success: false });
  }
  
  // Test home to admin login
  await page.goto(BASE_URL);
  await sleep(2000);
  
  try {
    const adminButton = await page.$('button:has-text("Admin Portal")');
    if (adminButton) {
      await adminButton.click();
      await sleep(3000);
      
      const currentUrl = page.url();
      const navigatedToAdmin = currentUrl.includes('/login/admin');
      console.log(`🏠➡️👤 Home to Admin: ${navigatedToAdmin ? '✅' : '❌'}`);
      navigationResults.push({ from: 'home', to: 'admin', success: navigatedToAdmin });
    } else {
      console.log(`🏠➡️👤 Home to Admin: ❌ (Button not found)`);
      navigationResults.push({ from: 'home', to: 'admin', success: false });
    }
  } catch (error) {
    console.log(`🏠➡️👤 Home to Admin: ❌ (${error.message})`);
    navigationResults.push({ from: 'home', to: 'admin', success: false });
  }
  
  // Test back navigation
  try {
    await page.goto(`${BASE_URL}/login/customer`);
    await sleep(2000);
    
    // Try multiple back button selectors
    const backButton = await page.$('button:has-text("arrow_back")') ||
                      await page.$('button[aria-label*="back" i]') ||
                      await page.$('.back-button');
                      
    if (backButton) {
      await backButton.click();
      await sleep(3000);
      
      const currentUrl = page.url();
      const navigatedBack = currentUrl === BASE_URL || currentUrl.endsWith('/');
      console.log(`⬅️ Back to Home: ${navigatedBack ? '✅' : '❌'}`);
      navigationResults.push({ from: 'customer', to: 'home', success: navigatedBack });
    } else {
      console.log(`⬅️ Back to Home: ❌ (Back button not found)`);
      navigationResults.push({ from: 'customer', to: 'home', success: false });
    }
  } catch (error) {
    console.log(`⬅️ Back to Home: ❌ (${error.message})`);
    navigationResults.push({ from: 'customer', to: 'home', success: false });
  }
  
  await takeScreenshot(page, 'navigation_test');
  
  return navigationResults;
}

async function testFallbackFormValidation(page) {
  console.log('\n✅ Testing Fallback Form Validation...');
  
  const validationResults = [];
  
  // Test customer login validation
  await page.goto(`${BASE_URL}/login/customer`);
  await sleep(3000);
  
  try {
    // Try to submit empty form
    const loginButton = await page.$('button:has-text("Sign In")');
    if (loginButton) {
      await loginButton.click();
      await sleep(2000);
      
      // Check for validation messages
      const bodyText = await page.textContent('body');
      const hasValidation = bodyText.includes('required') || bodyText.includes('Required') || 
                          bodyText.includes('Invalid') || bodyText.includes('Please');
      console.log(`📝 Empty Form Validation: ${hasValidation ? '✅' : '❌'}`);
      validationResults.push({ test: 'empty_form', result: hasValidation });
    }
  } catch (error) {
    console.log(`📝 Empty Form Validation: ❌ (${error.message})`);
    validationResults.push({ test: 'empty_form', result: false });
  }
  
  // Test invalid email format
  try {
    const emailInput = await page.$('input[type="email"]');
    if (emailInput) {
      await emailInput.fill('invalid-email');
      await sleep(500);
      
      const loginButton = await page.$('button:has-text("Sign In")');
      if (loginButton) {
        await loginButton.click();
        await sleep(2000);
        
        const bodyText = await page.textContent('body');
        const hasEmailValidation = bodyText.includes('valid email') || bodyText.includes('Invalid email');
        console.log(`📧 Email Validation: ${hasEmailValidation ? '✅' : '❌'}`);
        validationResults.push({ test: 'email_validation', result: hasEmailValidation });
      }
    }
  } catch (error) {
    console.log(`📧 Email Validation: ❌ (${error.message})`);
    validationResults.push({ test: 'email_validation', result: false });
  }
  
  await takeScreenshot(page, 'form_validation');
  
  return validationResults;
}

// Main test runner for Fallback UI
async function runFallbackUITests() {
  console.log('🧪 Starting Fallback UI E2E Tests...');
  console.log('=====================================');
  
  const browser = await chromium.launch({ headless: false });
  const context = await browser.newContext({
    viewport: { width: 1280, height: 720 }
  });
  const page = await context.newPage();
  
  const testResults = {
    startTime: new Date().toISOString(),
    endTime: null,
    totalTests: 0,
    passedTests: 0,
    failedTests: 0,
    results: {}
  };
  
  try {
    // Run all fallback UI tests
    testResults.results.homePage = await testFallbackHomePage(page);
    testResults.totalTests += 7;
    testResults.passedTests += Object.values(testResults.results.homePage).filter(Boolean).length;
    
    testResults.results.customerLogin = await testFallbackCustomerLogin(page);
    testResults.totalTests += 10;
    testResults.passedTests += Object.values(testResults.results.customerLogin).filter(Boolean).length;
    
    testResults.results.staffLogin = await testFallbackStaffLogin(page);
    testResults.totalTests += 7;
    testResults.passedTests += Object.values(testResults.results.staffLogin).filter(Boolean).length;
    
    testResults.results.adminLogin = await testFallbackAdminLogin(page);
    testResults.totalTests += 7;
    testResults.passedTests += Object.values(testResults.results.adminLogin).filter(Boolean).length;
    
    testResults.results.navigation = await testFallbackNavigation(page);
    testResults.totalTests += 4;
    testResults.passedTests += testResults.results.navigation.filter(n => n.success).length;
    
    testResults.results.validation = await testFallbackFormValidation(page);
    testResults.totalTests += 2;
    testResults.passedTests += testResults.results.validation.filter(v => v.result).length;
    
    testResults.failedTests = testResults.totalTests - testResults.passedTests;
    testResults.endTime = new Date().toISOString();
    
  } catch (error) {
    console.error('❌ Test execution failed:', error);
  } finally {
    await browser.close();
  }
  
  // Generate report
  console.log('\n📊 FALLBACK UI TEST REPORT');
  console.log('============================');
  console.log(`⏰ Started: ${testResults.startTime}`);
  console.log(`⏰ Ended: ${testResults.endTime}`);
  console.log(`📈 Total Tests: ${testResults.totalTests}`);
  console.log(`✅ Passed: ${testResults.passedTests}`);
  console.log(`❌ Failed: ${testResults.failedTests}`);
  console.log(`📊 Success Rate: ${((testResults.passedTests / testResults.totalTests) * 100).toFixed(1)}%`);
  
  console.log('\n📋 Detailed Results:');
  console.log('Home Page:', testResults.results.homePage);
  console.log('Customer Login:', testResults.results.customerLogin);
  console.log('Staff Login:', testResults.results.staffLogin);
  console.log('Admin Login:', testResults.results.adminLogin);
  console.log('Navigation:', testResults.results.navigation);
  console.log('Validation:', testResults.results.validation);
  
  // Save report to file
  const reportPath = path.join(SCREENSHOT_DIR, `fallback_ui_test_report_${timestamp()}.json`);
  fs.writeFileSync(reportPath, JSON.stringify(testResults, null, 2));
  console.log(`\n📄 Report saved: ${reportPath}`);
  
  return testResults;
}

// Run tests if this file is executed directly
if (require.main === module) {
  runFallbackUITests().catch(console.error);
}

module.exports = { runFallbackUITests };
