// e2e-tests/login_flow_test.js - Test complete login flow and then navigate to authenticated pages
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
  const filename = `login_flow_${name}_${timestamp()}.png`;
  const filepath = path.join(SCREENSHOT_DIR, filename);
  await page.screenshot({ path: filepath, fullPage: true });
  console.log(`📸 Screenshot: ${filename}`);
  return filename;
}

async function performLogin(page, role) {
  console.log(`\n🔐 Performing ${role} login...`);
  
  // Navigate to login page
  await page.goto(`${BASE_URL}/login/${role}`, { waitUntil: 'networkidle' });
  await sleep(3000);
  
  // Take screenshot of login form
  await takeScreenshot(page, `${role}_login_form`);
  
  // Check if we have Flutter login form or fallback form
  const bodyText = await page.textContent('body');
  const hasFlutterForm = bodyText.includes('Welcome Back') || bodyText.includes('Staff Portal') || bodyText.includes('Admin System');
  const hasFallbackForm = bodyText.includes('Email') && bodyText.includes('Password');
  
  console.log(`📊 Form Type: ${hasFlutterForm ? 'Flutter' : hasFallbackForm ? 'Fallback' : 'Unknown'}`);
  
  // Demo credentials for each role
  const credentials = {
    customer: { email: 'customer@example.com', password: 'customer123' },
    staff: { email: 'staff@example.com', password: 'staff123' },
    admin: { email: 'admin@example.com', password: 'admin123' }
  };
  
  const cred = credentials[role];
  
  try {
    if (hasFlutterForm) {
      // Try to interact with Flutter form elements
      console.log('🔍 Looking for Flutter form elements...');
      
      // Look for input fields by various selectors
      const emailSelectors = [
        'input[type="email"]',
        'input[placeholder*="email" i]',
        'input[id*="email" i]',
        'input[aria-label*="email" i]',
        '[data-testid="email"]',
        'input'
      ];
      
      const passwordSelectors = [
        'input[type="password"]',
        'input[placeholder*="password" i]',
        'input[id*="password" i]',
        'input[aria-label*="password" i]',
        '[data-testid="password"]'
      ];
      
      const buttonSelectors = [
        'button[type="submit"]',
        'button:has-text("Sign In")',
        'button:has-text("Login")',
        '[data-testid="login_button"]',
        'button'
      ];
      
      // Find and fill email field
      let emailFilled = false;
      for (const selector of emailSelectors) {
        try {
          const emailField = await page.$(selector);
          if (emailField) {
            await emailField.fill(cred.email);
            emailFilled = true;
            console.log(`✅ Email filled using selector: ${selector}`);
            break;
          }
        } catch (e) {
          // Continue trying other selectors
        }
      }
      
      // Find and fill password field
      let passwordFilled = false;
      for (const selector of passwordSelectors) {
        try {
          const passwordField = await page.$(selector);
          if (passwordField) {
            await passwordField.fill(cred.password);
            passwordFilled = true;
            console.log(`✅ Password filled using selector: ${selector}`);
            break;
          }
        } catch (e) {
          // Continue trying other selectors
        }
      }
      
      // Find and click submit button
      let buttonClicked = false;
      for (const selector of buttonSelectors) {
        try {
          const button = await page.$(selector);
          if (button) {
            await button.click();
            buttonClicked = true;
            console.log(`✅ Button clicked using selector: ${selector}`);
            break;
          }
        } catch (e) {
          // Continue trying other selectors
        }
      }
      
      if (!emailFilled || !passwordFilled || !buttonClicked) {
        console.log('⚠️ Could not complete Flutter form interaction, trying fallback method...');
        return await performFallbackLogin(page, role, cred);
      }
      
    } else {
      // Use fallback login method
      return await performFallbackLogin(page, role, cred);
    }
    
    // Wait for login to process
    console.log('⏳ Waiting for login processing...');
    await sleep(5000);
    
    // Check if login was successful
    const finalUrl = page.url();
    const finalBodyText = await page.textContent('body');
    
    // Take screenshot after login attempt
    await takeScreenshot(page, `${role}_after_login`);
    
    console.log(`🔗 Final URL: ${finalUrl}`);
    console.log(`📝 Body Length: ${finalBodyText.length}`);
    
    // Check for login success indicators
    const loginSuccess = finalUrl.includes('/home') || 
                        finalBodyText.includes('Dashboard') || 
                        finalBodyText.includes('Welcome') ||
                        !finalBodyText.includes('Sign In');
    
    console.log(`✅ Login Success: ${loginSuccess ? 'YES' : 'NO'}`);
    
    return {
      success: loginSuccess,
      finalUrl,
      bodyTextLength: finalBodyText.length,
      formType: hasFlutterForm ? 'Flutter' : 'Fallback'
    };
    
  } catch (error) {
    console.error(`❌ Login error:`, error.message);
    return { success: false, error: error.message };
  }
}

async function performFallbackLogin(page, role, credentials) {
  console.log('🔄 Using fallback login method...');
  
  // Try to click on demo credentials to auto-fill
  try {
    const emailElement = await page.$(`text=${credentials.email}`);
    if (emailElement) {
      await emailElement.click();
      console.log('✅ Clicked demo email credential');
      await sleep(500);
    }
    
    const passwordElement = await page.$(`text=${credentials.password}`);
    if (passwordElement) {
      await passwordElement.click();
      console.log('✅ Clicked demo password credential');
      await sleep(500);
    }
  } catch (e) {
    console.log('⚠️ Could not click demo credentials, trying manual fill...');
  }
  
  // Try to find and fill form fields manually
  try {
    const emailInput = await page.$('input[type="email"], input[placeholder*="email" i]');
    if (emailInput) {
      await emailInput.fill(credentials.email);
      console.log('✅ Manually filled email');
    }
    
    const passwordInput = await page.$('input[type="password"], input[placeholder*="password" i]');
    if (passwordInput) {
      await passwordInput.fill(credentials.password);
      console.log('✅ Manually filled password');
    }
    
    const submitButton = await page.$('button[type="submit"], button:has-text("Sign In"), button:has-text("Login")');
    if (submitButton) {
      await submitButton.click();
      console.log('✅ Clicked submit button');
    }
  } catch (e) {
    console.log('⚠️ Manual form fill failed');
  }
  
  return { success: false, formType: 'Fallback' };
}

async function testAuthenticatedPages(page, role) {
  console.log(`\n🏠 Testing authenticated pages for ${role}...`);
  
  const pages = [
    { path: `/${role}/home`, name: `${role} Home`, expectedContent: ['Dashboard', 'Overview', 'Profile'] }
  ];
  
  const results = [];
  
  for (const pageInfo of pages) {
    console.log(`\n📍 Testing: ${pageInfo.name}`);
    console.log(`🔗 URL: ${BASE_URL}${pageInfo.path}`);
    
    try {
      // Navigate to the page
      await page.goto(`${BASE_URL}${pageInfo.path}`, { waitUntil: 'networkidle' });
      await sleep(5000); // Longer wait for content to load
      
      // Take screenshot
      await takeScreenshot(page, `${role}_${pageInfo.name.toLowerCase().replace(/\s+/g, '_')}`);
      
      // Analyze content
      const bodyText = await page.textContent('body');
      const bodyTextLength = bodyText.length;
      const title = await page.title();
      
      // Check for expected content
      const contentChecks = pageInfo.expectedContent.map(content => ({
        content,
        found: bodyText.includes(content)
      }));
      
      // Check for Flutter indicators
      const hasFlutterIndicators = bodyText.includes('flutter-view') || 
                                  bodyText.includes('flt-scene-host') ||
                                  bodyText.includes('flt-semantic');
      
      // Check for fallback indicators
      const hasFallbackIndicators = bodyText.includes('Welcome to NCL') || 
                                   bodyText.includes('flutter-fallback-container');
      
      console.log(`📄 Title: "${title}"`);
      console.log(`📝 Body Length: ${bodyTextLength}`);
      console.log(`🦋 Flutter Indicators: ${hasFlutterIndicators ? 'YES' : 'NO'}`);
      console.log(`🔄 Fallback Indicators: ${hasFallbackIndicators ? 'YES' : 'NO'}`);
      
      console.log('🎯 Content Checks:');
      contentChecks.forEach(check => {
        console.log(`  ${check.found ? '✅' : '❌'} "${check.content}"`);
      });
      
      const success = contentChecks.some(check => check.found) && !hasFallbackIndicators;
      console.log(`✅ Page Success: ${success ? 'YES' : 'NO'}`);
      
      results.push({
        pageName: pageInfo.name,
        path: pageInfo.path,
        title,
        bodyTextLength,
        hasFlutterIndicators,
        hasFallbackIndicators,
        contentChecks,
        success
      });
      
    } catch (error) {
      console.error(`❌ Error testing ${pageInfo.name}:`, error.message);
      results.push({
        pageName: pageInfo.name,
        path: pageInfo.path,
        error: error.message,
        success: false
      });
    }
  }
  
  return results;
}

async function testCompleteLoginFlow() {
  console.log('🌟 COMPLETE LOGIN FLOW TEST');
  console.log('==========================');
  
  const browser = await chromium.launch({ 
    headless: false,
    devtools: true 
  });
  const context = await browser.newContext({
    viewport: { width: 1280, height: 720 }
  });
  
  const roles = ['customer', 'staff', 'admin'];
  const allResults = [];
  
  for (const role of roles) {
    console.log(`\n\n🎯 TESTING ${role.toUpperCase()} LOGIN FLOW`);
    console.log(`${'='.repeat(60)}`);
    
    const page = await context.newPage();
    
    // Step 1: Perform login
    const loginResult = await performLogin(page, role);
    
    // Step 2: Test authenticated pages if login was successful
    let pageResults = [];
    if (loginResult.success) {
      pageResults = await testAuthenticatedPages(page, role);
    } else {
      console.log(`⚠️ Skipping authenticated pages due to login failure`);
    }
    
    allResults.push({
      role,
      loginResult,
      pageResults
    });
    
    await page.close();
    
    // Small delay between role tests
    await sleep(2000);
  }
  
  await browser.close();
  
  // Generate comprehensive report
  console.log('\n\n📊 COMPLETE LOGIN FLOW REPORT');
  console.log('=============================');
  
  console.log('\n📈 SUMMARY:');
  allResults.forEach(result => {
    console.log(`\n👤 ${result.role.toUpperCase()}:`);
    console.log(`  🔐 Login Success: ${result.loginResult.success ? 'YES' : 'NO'}`);
    console.log(`  📄 Login Form Type: ${result.loginResult.formType || 'Unknown'}`);
    if (result.loginResult.finalUrl) {
      console.log(`  🔗 Final URL: ${result.loginResult.finalUrl}`);
    }
    console.log(`  📝 Body Length: ${result.loginResult.bodyTextLength || 'N/A'}`);
    
    if (result.pageResults.length > 0) {
      const successfulPages = result.pageResults.filter(p => p.success).length;
      console.log(`  📠 Authenticated Pages: ${successfulPages}/${result.pageResults.length} successful`);
      
      result.pageResults.forEach(pageResult => {
        console.log(`    📍 ${pageResult.pageName}: ${pageResult.success ? '✅' : '❌'}`);
      });
    }
  });
  
  // Save results to file
  const reportData = {
    timestamp: new Date().toISOString(),
    results: allResults
  };
  
  const reportPath = path.join(SCREENSHOT_DIR, `login_flow_report_${timestamp()}.json`);
  fs.writeFileSync(reportPath, JSON.stringify(reportData, null, 2));
  console.log(`\n📄 Detailed report saved: ${reportPath}`);
  
  return reportData;
}

// Run the test if this file is executed directly
if (require.main === module) {
  testCompleteLoginFlow().catch(console.error);
}

module.exports = { testCompleteLoginFlow };
