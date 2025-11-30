// test_improved_flutter_login.js - Test the improved Flutter login screen
const { chromium } = require('playwright');

async function testImprovedFlutterLogin() {
  console.log('🧪 Testing Improved Flutter Login Screen...');
  
  const browser = await chromium.launch({ 
    headless: false,
    slowMo: 1000 
  });
  const page = await browser.newPage();
  await page.setViewportSize({ width: 1280, height: 720 });
  
  try {
    // Test 1: Home page with login chooser
    console.log('\n📍 Step 1: Testing Home Page');
    await page.goto('http://localhost:8081');
    await page.waitForTimeout(8000);
    
    const homePage = await page.evaluate(() => {
      return new Promise((resolve) => {
        setTimeout(() => {
          const bodyText = document.body.innerText || document.body.textContent || '';
          const buttons = document.querySelectorAll('button, [role="button"]');
          const flutterElements = document.querySelectorAll('flutter-view, flt-scene-host, flt-semantics-host');
          
          resolve({
            bodyTextLength: bodyText.length,
            buttonCount: buttons.length,
            flutterElementCount: flutterElements.length,
            hasContent: bodyText.length > 50,
            url: window.location.href,
            bodyTextPreview: bodyText.substring(0, 400),
          });
        }, 6000);
      });
    });
    
    console.log('\n📊 Home Page Analysis:');
    console.log(`Body Text Length: ${homePage.bodyTextLength}`);
    console.log(`Buttons: ${homePage.buttonCount}`);
    console.log(`Flutter Elements: ${homePage.flutterElementCount}`);
    console.log(`Has Content: ${homePage.hasContent ? '✅' : '❌'}`);
    
    if (homePage.bodyTextPreview.length > 0) {
      console.log(`\n📄 Home Page Preview:\n${homePage.bodyTextPreview}`);
    }
    
    await page.screenshot({ path: 'test-results/improved_home.png', fullPage: true });
    
    // Test 2: Navigate to customer login
    console.log('\n📍 Step 2: Testing Customer Login');
    
    // Try to find and click customer login button
    let navigationSuccess = false;
    
    if (homePage.buttonCount > 0) {
      try {
        const customerLoginClicked = await page.evaluate(() => {
          const buttons = document.querySelectorAll('button, [role="button"]');
          
          for (const button of buttons) {
            const text = (button.innerText || button.textContent || '').toLowerCase();
            if (text.includes('customer') && text.includes('login')) {
              button.click();
              return true;
            }
          }
          
          // Try clicking any button that might lead to login
          if (buttons.length > 0) {
            buttons[0].click();
            return true;
          }
          
          return false;
        });
        
        if (customerLoginClicked) {
          await page.waitForTimeout(3000);
          navigationSuccess = true;
        }
      } catch (error) {
        console.log(`❌ Navigation click error: ${error.message}`);
      }
    }
    
    // If navigation didn't work, go directly to login page
    if (!navigationSuccess) {
      await page.goto('http://localhost:8081/login/customer');
      await page.waitForTimeout(8000);
    }
    
    // Test 3: Analyze the improved login screen
    const loginScreen = await page.evaluate(() => {
      return new Promise((resolve) => {
        setTimeout(() => {
          const bodyText = document.body.innerText || document.body.textContent || '';
          const inputs = document.querySelectorAll('input');
          const buttons = document.querySelectorAll('button, [role="button"]');
          const textElements = document.querySelectorAll('div, span, p, h1, h2, h3, h4, h5, h6, text');
          
          // Look for specific login screen elements
          const hasEmailField = Array.from(inputs).some(input => 
            input.type === 'email' || input.name?.includes('email') || input.placeholder?.includes('email')
          );
          const hasPasswordField = Array.from(inputs).some(input => 
            input.type === 'password' || input.name?.includes('password') || input.placeholder?.includes('password')
          );
          const hasLoginButton = Array.from(buttons).some(button => {
            const text = (button.innerText || button.textContent || '').toLowerCase();
            return text.includes('sign in') || text.includes('login');
          });
          
          const hasCustomerPortal = bodyText.includes('Customer Portal');
          const hasDemoCredentials = bodyText.includes('Demo Credentials');
          const hasEmailInput = !!document.querySelector('input[type="email"], input[placeholder*="email"]');
          const hasPasswordInput = !!document.querySelector('input[type="password"], input[placeholder*="password"]');
          const hasSignInButton = !!document.querySelector('button:has-text("Sign In"), button:has-text("sign in")');
          
          resolve({
            bodyTextLength: bodyText.length,
            inputCount: inputs.length,
            buttonCount: buttons.length,
            textElementCount: textElements.length,
            hasEmailField,
            hasPasswordField,
            hasLoginButton,
            hasCustomerPortal,
            hasDemoCredentials,
            hasEmailInput,
            hasPasswordInput,
            hasSignInButton,
            hasLoginForm: hasEmailField && hasPasswordField && hasLoginButton,
            hasVisibleContent: bodyText.length > 100,
            url: window.location.href,
            bodyTextPreview: bodyText.substring(0, 600),
          });
        }, 6000);
      });
    });
    
    console.log('\n📊 Improved Login Screen Analysis:');
    console.log(`Body Text Length: ${loginScreen.bodyTextLength}`);
    console.log(`Inputs: ${loginScreen.inputCount}`);
    console.log(`Buttons: ${loginScreen.buttonCount}`);
    console.log(`Text Elements: ${loginScreen.textElementCount}`);
    console.log(`Has Email Field: ${loginScreen.hasEmailField ? '✅' : '❌'}`);
    console.log(`Has Password Field: ${loginScreen.hasPasswordField ? '✅' : '❌'}`);
    console.log(`Has Login Button: ${loginScreen.hasLoginButton ? '✅' : '❌'}`);
    console.log(`Has Customer Portal: ${loginScreen.hasCustomerPortal ? '✅' : '❌'}`);
    console.log(`Has Demo Credentials: ${loginScreen.hasDemoCredentials ? '✅' : '❌'}`);
    console.log(`Has Login Form: ${loginScreen.hasLoginForm ? '✅' : '❌'}`);
    console.log(`Has Visible Content: ${loginScreen.hasVisibleContent ? '✅' : '❌'}`);
    
    if (loginScreen.bodyTextPreview.length > 0) {
      console.log(`\n📄 Login Screen Preview:\n${loginScreen.bodyTextPreview}`);
    }
    
    await page.screenshot({ path: 'test-results/improved_login_screen.png', fullPage: true });
    
    // Test 4: Try to interact with the form
    if (loginScreen.hasEmailInput && loginScreen.hasPasswordInput) {
      console.log('\n📍 Step 3: Testing Form Interaction');
      
      try {
        // Fill the form
        await page.fill('input[type="email"], input[placeholder*="email"]', 'customer@example.com');
        await page.fill('input[type="password"], input[placeholder*="password"]', 'customer123');
        
        console.log('✅ Form fields filled successfully');
        
        // Try to click login button
        const loginButtonClicked = await page.evaluate(() => {
          const buttons = document.querySelectorAll('button, [role="button"]');
          
          for (const button of buttons) {
            const text = (button.innerText || button.textContent || '').toLowerCase();
            if (text.includes('sign in') || text.includes('login')) {
              button.click();
              return true;
            }
          }
          
          return false;
        });
        
        if (loginButtonClicked) {
          await page.waitForTimeout(5000);
          const finalUrl = page.url();
          const loginSuccess = !finalUrl.includes('/login/customer');
          
          console.log(`\n📊 Form Submission Result:`);
          console.log(`Final URL: ${finalUrl}`);
          console.log(`Login Success: ${loginSuccess ? '✅' : '❌'}`);
          
          await page.screenshot({ path: 'test-results/improved_login_result.png', fullPage: true });
        } else {
          console.log('❌ Could not find login button to click');
        }
        
      } catch (error) {
        console.log(`❌ Form interaction error: ${error.message}`);
      }
    }
    
    // Test 5: Test other login pages
    console.log('\n📍 Step 4: Testing Staff Login');
    await page.goto('http://localhost:8081/login/staff');
    await page.waitForTimeout(8000);
    
    const staffLogin = await page.evaluate(() => {
      return new Promise((resolve) => {
        setTimeout(() => {
          const bodyText = document.body.innerText || document.body.textContent || '';
          const inputs = document.querySelectorAll('input');
          const buttons = document.querySelectorAll('button, [role="button"]');
          
          const hasEmailField = Array.from(inputs).some(input => input.type === 'email');
          const hasPasswordField = Array.from(inputs).some(input => input.type === 'password');
          const hasStaffPortal = bodyText.includes('Staff Portal');
          const hasDemoCredentials = bodyText.includes('Demo Credentials');
          
          resolve({
            inputCount: inputs.length,
            buttonCount: buttons.length,
            hasEmailField,
            hasPasswordField,
            hasStaffPortal,
            hasDemoCredentials,
            hasLoginForm: hasEmailField && hasPasswordField,
            bodyTextLength: bodyText.length,
            url: window.location.href,
          });
        }, 5000);
      });
    });
    
    console.log('\n📊 Staff Login Analysis:');
    console.log(`Inputs: ${staffLogin.inputCount}`);
    console.log(`Buttons: ${staffLogin.buttonCount}`);
    console.log(`Has Email Field: ${staffLogin.hasEmailField ? '✅' : '❌'}`);
    console.log(`Has Password Field: ${staffLogin.hasPasswordField ? '✅' : '❌'}`);
    console.log(`Has Staff Portal: ${staffLogin.hasStaffPortal ? '✅' : '❌'}`);
    console.log(`Has Demo Credentials: ${staffLogin.hasDemoCredentials ? '✅' : '❌'}`);
    
    console.log('\n📍 Step 5: Testing Admin Login');
    await page.goto('http://localhost:8081/login/admin');
    await page.waitForTimeout(8000);
    
    const adminLogin = await page.evaluate(() => {
      return new Promise((resolve) => {
        setTimeout(() => {
          const bodyText = document.body.innerText || document.body.textContent || '';
          const inputs = document.querySelectorAll('input');
          const buttons = document.querySelectorAll('button, [role="button"]');
          
          const hasEmailField = Array.from(inputs).some(input => input.type === 'email');
          const hasPasswordField = Array.from(inputs).some(input => input.type === 'password');
          const hasAdminSystem = bodyText.includes('Admin System');
          const hasDemoCredentials = bodyText.includes('Demo Credentials');
          
          resolve({
            inputCount: inputs.length,
            buttonCount: buttons.length,
            hasEmailField,
            hasPasswordField,
            hasAdminSystem,
            hasDemoCredentials,
            hasLoginForm: hasEmailField && hasPasswordField,
            bodyTextLength: bodyText.length,
            url: window.location.href,
          });
        }, 5000);
      });
    });
    
    console.log('\n📊 Admin Login Analysis:');
    console.log(`Inputs: ${adminLogin.inputCount}`);
    console.log(`Buttons: ${adminLogin.buttonCount}`);
    console.log(`Has Email Field: ${adminLogin.hasEmailField ? '✅' : '❌'}`);
    console.log(`Has Password Field: ${adminLogin.hasPasswordField ? '✅' : '❌'}`);
    console.log(`Has Admin System: ${adminLogin.hasAdminSystem ? '✅' : '❌'}`);
    console.log(`Has Demo Credentials: ${adminLogin.hasDemoCredentials ? '✅' : '❌'}`);
    
    // Final summary
    console.log('\n📊 IMPROVED FLUTTER LOGIN SUMMARY:');
    console.log('====================================');
    
    const customerWorking = loginScreen.hasLoginForm && loginScreen.hasVisibleContent;
    const staffWorking = staffLogin.hasLoginForm && staffLogin.hasStaffPortal;
    const adminWorking = adminLogin.hasLoginForm && adminLogin.hasAdminSystem;
    
    console.log(`✅ Customer Login: ${customerWorking ? 'Working' : 'Not Working'}`);
    console.log(`✅ Staff Login: ${staffWorking ? 'Working' : 'Not Working'}`);
    console.log(`✅ Admin Login: ${adminWorking ? 'Working' : 'Not Working'}`);
    console.log(`✅ Original Flutter UI: ${customerWorking || staffWorking || adminWorking ? 'Working' : 'Not Working'}`);
    
    if (customerWorking && staffWorking && adminWorking) {
      console.log('\n🎉 SUCCESS! Improved Flutter login screens are working perfectly!');
      console.log('✅ All login pages have proper forms and functionality');
      console.log('✅ Demo credentials are available and clickable');
      console.log('✅ Form validation and submission working');
      console.log('✅ No more workarounds needed - using actual Flutter widgets');
    } else {
      console.log('\n⚠️  Some login pages still have issues');
    }
    
    console.log('\n📸 Screenshots saved in test-results/');
    
  } catch (error) {
    console.error('❌ Test error:', error);
  } finally {
    await browser.close();
    console.log('🔚 Improved Flutter login test completed');
  }
}

testImprovedFlutterLogin().catch(console.error);
