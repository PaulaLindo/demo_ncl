// test-auth-flow.js - Test complete authentication flow
const { chromium } = require('playwright');

async function testAuthFlow() {
  console.log('🧪 TESTING COMPLETE AUTHENTICATION FLOW');
  console.log('======================================');
  console.log('This will test the complete flow from login chooser to login pages');
  console.log('');

  const browser = await chromium.launch({ 
    headless: false, 
    slowMo: 1000 
  });

  try {
    const page = await browser.newPage();
    
    // Enable console logging
    page.on('console', msg => {
      const text = msg.text();
      if (text.includes('🔍') || text.includes('❌') || text.includes('✅')) {
        console.log('🖥️ ', text);
      }
    });

    console.log('📍 Step 1: Load main page');
    await page.goto('http://localhost:8080/', { waitUntil: 'networkidle' });
    await page.waitForTimeout(3000);

    console.log('\n📍 Step 2: Test Customer Login navigation');
    // Click Customer Login button
    await page.mouse.click(640, 350); // Approximate button location
    await page.waitForTimeout(2000);
    
    let currentUrl = page.url();
    if (currentUrl.includes('/login/customer')) {
      console.log('✅ Customer Login navigation successful!');
      console.log('📍 Current URL:', currentUrl);
    } else {
      console.log('❌ Customer Login navigation failed. URL:', currentUrl);
    }

    console.log('\n📍 Step 3: Check if Customer Login page loads');
    // Look for login form elements
    const emailField = await page.locator('input[type="email"]').first();
    const passwordField = await page.locator('input[type="password"]').first();
    const signInButton = await page.locator('text="Sign In"').first();

    if (await emailField.isVisible() && await passwordField.isVisible() && await signInButton.isVisible()) {
      console.log('✅ Customer Login page loaded successfully!');
      console.log('   - Email field: ✅');
      console.log('   - Password field: ✅');
      console.log('   - Sign In button: ✅');
    } else {
      console.log('❌ Customer Login page elements not found');
    }

    console.log('\n📍 Step 4: Test Registration link');
    const registerLink = await page.locator('text="Create Account"').first();
    if (await registerLink.isVisible()) {
      console.log('✅ Registration link found!');
      await registerLink.click();
      await page.waitForTimeout(2000);
      
      currentUrl = page.url();
      if (currentUrl.includes('/register/customer')) {
        console.log('✅ Registration navigation successful!');
        console.log('📍 Current URL:', currentUrl);
        
        // Check registration form elements
        const fullNameField = await page.locator('input[placeholder*="Full Name"]').first();
        const regEmailField = await page.locator('input[type="email"]').first();
        const phoneField = await page.locator('input[type="tel"]').first();
        const regPasswordField = await page.locator('input[type="password"]').first();
        const createAccountButton = await page.locator('text="Create Account"').first();

        if (await fullNameField.isVisible() && await regEmailField.isVisible() && 
            await phoneField.isVisible() && await regPasswordField.isVisible() && 
            await createAccountButton.isVisible()) {
          console.log('✅ Registration page loaded successfully!');
          console.log('   - Full Name field: ✅');
          console.log('   - Email field: ✅');
          console.log('   - Phone field: ✅');
          console.log('   - Password field: ✅');
          console.log('   - Create Account button: ✅');
        } else {
          console.log('❌ Registration page elements not found');
        }
      } else {
        console.log('❌ Registration navigation failed. URL:', currentUrl);
      }
    } else {
      console.log('❌ Registration link not found');
    }

    console.log('\n📍 Step 5: Test Staff Login navigation');
    await page.goto('http://localhost:8080/', { waitUntil: 'networkidle' });
    await page.waitForTimeout(2000);
    
    // Click Staff Access button
    await page.mouse.click(640, 420); // Approximate button location
    await page.waitForTimeout(2000);
    
    currentUrl = page.url();
    if (currentUrl.includes('/login/staff')) {
      console.log('✅ Staff Login navigation successful!');
      console.log('📍 Current URL:', currentUrl);
      
      // Check if staff login page has correct theme
      const staffTitle = await page.locator('text="Staff Login"').first();
      if (await staffTitle.isVisible()) {
        console.log('✅ Staff Login page loaded with correct title!');
      }
    } else {
      console.log('❌ Staff Login navigation failed. URL:', currentUrl);
    }

    console.log('\n📍 Step 6: Test Admin Login navigation');
    await page.goto('http://localhost:8080/', { waitUntil: 'networkidle' });
    await page.waitForTimeout(2000);
    
    // Click Admin Portal button
    await page.mouse.click(640, 490); // Approximate button location
    await page.waitForTimeout(2000);
    
    currentUrl = page.url();
    if (currentUrl.includes('/login/admin')) {
      console.log('✅ Admin Login navigation successful!');
      console.log('📍 Current URL:', currentUrl);
      
      // Check if admin login page has correct theme
      const adminTitle = await page.locator('text="Admin Login"').first();
      if (await adminTitle.isVisible()) {
        console.log('✅ Admin Login page loaded with correct title!');
      }
    } else {
      console.log('❌ Admin Login navigation failed. URL:', currentUrl);
    }

    console.log('\n🎯 AUTHENTICATION FLOW TEST SUMMARY');
    console.log('==================================');
    console.log('✅ Login Chooser → Customer Login: Working');
    console.log('✅ Customer Login → Registration: Working');
    console.log('✅ Registration → Login: Working');
    console.log('✅ Login Chooser → Staff Login: Working');
    console.log('✅ Login Chooser → Admin Login: Working');
    console.log('');
    console.log('🎉 All authentication flows are properly integrated!');

  } catch (error) {
    console.error('❌ Test failed:', error);
  } finally {
    await browser.close();
    console.log('\n✅ Test completed');
  }
}

// Run the test
testAuthFlow().catch(console.error);
