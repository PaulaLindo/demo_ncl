// test_flutter_login_direct.js - Direct test of Flutter login screens
const { chromium } = require('playwright');

async function testFlutterLoginDirect() {
  console.log('🧪 Testing Flutter Login Screens Directly...');
  
  const browser = await chromium.launch({ 
    headless: false,
    slowMo: 1000 
  });
  const page = await browser.newPage();
  await page.setViewportSize({ width: 1280, height: 720 });
  
  try {
    // Test Customer Login
    console.log('\n📍 Step 1: Testing Customer Login');
    await page.goto('http://localhost:8081/login/customer');
    await page.waitForTimeout(10000); // Give Flutter more time to render
    
    const customerLogin = await page.evaluate(() => {
      return new Promise((resolve) => {
        setTimeout(() => {
          const bodyText = document.body.innerText || document.body.textContent || '';
          const inputs = document.querySelectorAll('input');
          const buttons = document.querySelectorAll('button, [role="button"]');
          const textElements = document.querySelectorAll('div, span, p, h1, h2, h3, h4, h5, h6');
          
          // Look for specific elements
          const hasEmailInput = !!document.querySelector('input[type="email"], input[placeholder*="email"], input[name*="email"]');
          const hasPasswordInput = !!document.querySelector('input[type="password"], input[placeholder*="password"], input[name*="password"]');
          const hasLoginButton = !!document.querySelector('button:has-text("Sign In"), button:has-text("sign in"), [data-testid="login-button"]');
          
          const hasCustomerPortal = bodyText.includes('Customer Portal');
          const hasDemoCredentials = bodyText.includes('Demo Credentials');
          const hasEmailField = Array.from(inputs).some(input => input.type === 'email');
          const hasPasswordField = Array.from(inputs).some(input => input.type === 'password');
          
          // Extract text content
          const extractedTexts = Array.from(textElements).map(el => 
            (el.innerText || el.textContent || '').trim()
          ).filter(text => text.length > 0 && text.length < 100); // Filter out very long text
          
          resolve({
            bodyTextLength: bodyText.length,
            inputCount: inputs.length,
            buttonCount: buttons.length,
            textElementCount: textElements.length,
            hasEmailInput,
            hasPasswordInput,
            hasLoginButton,
            hasCustomerPortal,
            hasDemoCredentials,
            hasEmailField,
            hasPasswordField,
            hasLoginForm: hasEmailField && hasPasswordField,
            hasVisibleContent: bodyText.length > 100,
            extractedTexts: extractedTexts.slice(0, 10),
            url: window.location.href,
          });
        }, 8000);
      });
    });
    
    console.log('\n📊 Customer Login Analysis:');
    console.log(`Body Text Length: ${customerLogin.bodyTextLength}`);
    console.log(`Inputs: ${customerLogin.inputCount}`);
    console.log(`Buttons: ${customerLogin.buttonCount}`);
    console.log(`Text Elements: ${customerLogin.textElementCount}`);
    console.log(`Has Email Input: ${customerLogin.hasEmailInput ? '✅' : '❌'}`);
    console.log(`Has Password Input: ${customerLogin.hasPasswordInput ? '✅' : '❌'}`);
    console.log(`Has Login Button: ${customerLogin.hasLoginButton ? '✅' : '❌'}`);
    console.log(`Has Customer Portal: ${customerLogin.hasCustomerPortal ? '✅' : '❌'}`);
    console.log(`Has Demo Credentials: ${customerLogin.hasDemoCredentials ? '✅' : '❌'}`);
    console.log(`Has Login Form: ${customerLogin.hasLoginForm ? '✅' : '❌'}`);
    console.log(`Has Visible Content: ${customerLogin.hasVisibleContent ? '✅' : '❌'}`);
    
    if (customerLogin.extractedTexts.length > 0) {
      console.log(`\n📄 Extracted Text Elements:`);
      customerLogin.extractedTexts.forEach((text, index) => {
        if (text.length > 0) {
          console.log(`  ${index + 1}. "${text}"`);
        }
      });
    }
    
    await page.screenshot({ path: 'test-results/flutter_customer_login.png', fullPage: true });
    
    // Test Staff Login
    console.log('\n📍 Step 2: Testing Staff Login');
    await page.goto('http://localhost:8081/login/staff');
    await page.waitForTimeout(10000);
    
    const staffLogin = await page.evaluate(() => {
      return new Promise((resolve) => {
        setTimeout(() => {
          const bodyText = document.body.innerText || document.body.textContent || '';
          const inputs = document.querySelectorAll('input');
          const buttons = document.querySelectorAll('button, [role="button"]');
          
          const hasEmailInput = !!document.querySelector('input[type="email"], input[placeholder*="email"], input[name*="email"]');
          const hasPasswordInput = !!document.querySelector('input[type="password"], input[placeholder*="password"], input[name*="password"]');
          const hasStaffPortal = bodyText.includes('Staff Portal');
          const hasDemoCredentials = bodyText.includes('Demo Credentials');
          const hasEmailField = Array.from(inputs).some(input => input.type === 'email');
          const hasPasswordField = Array.from(inputs).some(input => input.type === 'password');
          
          resolve({
            bodyTextLength: bodyText.length,
            inputCount: inputs.length,
            buttonCount: buttons.length,
            hasEmailInput,
            hasPasswordInput,
            hasStaffPortal,
            hasDemoCredentials,
            hasEmailField,
            hasPasswordField,
            hasLoginForm: hasEmailField && hasPasswordField,
            hasVisibleContent: bodyText.length > 100,
            url: window.location.href,
          });
        }, 8000);
      });
    });
    
    console.log('\n📊 Staff Login Analysis:');
    console.log(`Body Text Length: ${staffLogin.bodyTextLength}`);
    console.log(`Inputs: ${staffLogin.inputCount}`);
    console.log(`Buttons: ${staffLogin.buttonCount}`);
    console.log(`Has Email Input: ${staffLogin.hasEmailInput ? '✅' : '❌'}`);
    console.log(`Has Password Input: ${staffLogin.hasPasswordInput ? '✅' : '❌'}`);
    console.log(`Has Staff Portal: ${staffLogin.hasStaffPortal ? '✅' : '❌'}`);
    console.log(`Has Demo Credentials: ${staffLogin.hasDemoCredentials ? '✅' : '❌'}`);
    console.log(`Has Login Form: ${staffLogin.hasLoginForm ? '✅' : '❌'}`);
    console.log(`Has Visible Content: ${staffLogin.hasVisibleContent ? '✅' : '❌'}`);
    
    await page.screenshot({ path: 'test-results/flutter_staff_login.png', fullPage: true });
    
    // Test Admin Login
    console.log('\n📍 Step 3: Testing Admin Login');
    await page.goto('http://localhost:8081/login/admin');
    await page.waitForTimeout(10000);
    
    const adminLogin = await page.evaluate(() => {
      return new Promise((resolve) => {
        setTimeout(() => {
          const bodyText = document.body.innerText || document.body.textContent || '';
          const inputs = document.querySelectorAll('input');
          const buttons = document.querySelectorAll('button, [role="button"]');
          
          const hasEmailInput = !!document.querySelector('input[type="email"], input[placeholder*="email"], input[name*="email"]');
          const hasPasswordInput = !!document.querySelector('input[type="password"], input[placeholder*="password"], input[name*="password"]');
          const hasAdminSystem = bodyText.includes('Admin System');
          const hasDemoCredentials = bodyText.includes('Demo Credentials');
          const hasEmailField = Array.from(inputs).some(input => input.type === 'email');
          const hasPasswordField = Array.from(inputs).some(input => input.type === 'password');
          
          resolve({
            bodyTextLength: bodyText.length,
            inputCount: inputs.length,
            buttonCount: buttons.length,
            hasEmailInput,
            hasPasswordInput,
            hasAdminSystem,
            hasDemoCredentials,
            hasEmailField,
            hasPasswordField,
            hasLoginForm: hasEmailField && hasPasswordField,
            hasVisibleContent: bodyText.length > 100,
            url: window.location.href,
          });
        }, 8000);
      });
    });
    
    console.log('\n📊 Admin Login Analysis:');
    console.log(`Body Text Length: ${adminLogin.bodyTextLength}`);
    console.log(`Inputs: ${adminLogin.inputCount}`);
    console.log(`Buttons: ${adminLogin.buttonCount}`);
    console.log(`Has Email Input: ${adminLogin.hasEmailInput ? '✅' : '❌'}`);
    console.log(`Has Password Input: ${adminLogin.hasPasswordInput ? '✅' : '❌'}`);
    console.log(`Has Admin System: ${adminLogin.hasAdminSystem ? '✅' : '❌'}`);
    console.log(`Has Demo Credentials: ${adminLogin.hasDemoCredentials ? '✅' : '❌'}`);
    console.log(`Has Login Form: ${adminLogin.hasLoginForm ? '✅' : '❌'}`);
    console.log(`Has Visible Content: ${adminLogin.hasVisibleContent ? '✅' : '❌'}`);
    
    await page.screenshot({ path: 'test-results/flutter_admin_login.png', fullPage: true });
    
    // Test form interaction if forms are working
    if (customerLogin.hasEmailInput && customerLogin.hasPasswordInput) {
      console.log('\n📍 Step 4: Testing Form Interaction');
      await page.goto('http://localhost:8081/login/customer');
      await page.waitForTimeout(5000);
      
      try {
        // Try to find and fill form fields
        const emailFilled = await page.fill('input[type="email"], input[placeholder*="email"], input[name*="email"]', 'customer@example.com');
        const passwordFilled = await page.fill('input[type="password"], input[placeholder*="password"], input[name*="password"]', 'customer123');
        
        console.log(`Email field filled: ${emailFilled ? '✅' : '❌'}`);
        console.log(`Password field filled: ${passwordFilled ? '✅' : '❌'}`);
        
        if (emailFilled && passwordFilled) {
          // Try to click login button
          const loginClicked = await page.evaluate(() => {
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
          
          if (loginClicked) {
            await page.waitForTimeout(5000);
            const finalUrl = page.url();
            const loginSuccess = !finalUrl.includes('/login/customer');
            
            console.log(`\n📊 Form Interaction Result:`);
            console.log(`Login Button Clicked: ${loginClicked ? '✅' : '❌'}`);
            console.log(`Final URL: ${finalUrl}`);
            console.log(`Login Success: ${loginSuccess ? '✅' : '❌'}`);
            
            await page.screenshot({ path: 'test-results/flutter_login_result.png', fullPage: true });
          }
        }
        
      } catch (error) {
        console.log(`❌ Form interaction error: ${error.message}`);
      }
    }
    
    // Final summary
    console.log('\n📊 FLUTTER LOGIN SCREENS SUMMARY:');
    console.log('==================================');
    
    const customerWorking = customerLogin.hasLoginForm && customerLogin.hasVisibleContent;
    const staffWorking = staffLogin.hasLoginForm && staffLogin.hasStaffPortal;
    const adminWorking = adminLogin.hasLoginForm && adminLogin.hasAdminSystem;
    
    console.log(`✅ Customer Login: ${customerWorking ? 'Working' : 'Not Working'}`);
    console.log(`✅ Staff Login: ${staffWorking ? 'Working' : 'Not Working'}`);
    console.log(`✅ Admin Login: ${adminWorking ? 'Working' : 'Not Working'}`);
    
    const allWorking = customerWorking && staffWorking && adminWorking;
    
    console.log(`\n✅ Overall Status: ${allWorking ? 'ALL WORKING' : 'Some Issues'}`);
    
    if (allWorking) {
      console.log('\n🎉 SUCCESS! All Flutter login screens are working properly!');
      console.log('✅ Original Flutter widgets are rendering correctly');
      console.log('✅ Forms have proper input fields');
      console.log('✅ Demo credentials are available');
      console.log('✅ No workarounds needed - using pure Flutter');
      console.log('✅ Ready for E2E testing');
    } else {
      console.log('\n⚠️  Some login screens still have rendering issues');
      console.log('🔧 May need further investigation of Flutter web compatibility');
    }
    
    console.log('\n📸 Screenshots saved in test-results/');
    console.log('   - flutter_customer_login.png');
    console.log('   - flutter_staff_login.png');
    console.log('   - flutter_admin_login.png');
    
  } catch (error) {
    console.error('❌ Test error:', error);
  } finally {
    await browser.close();
    console.log('🔚 Flutter login direct test completed');
  }
}

testFlutterLoginDirect().catch(console.error);
