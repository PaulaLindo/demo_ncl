// quick_clean_test.js - Quick test to check if clean CSS works better
const { chromium } = require('playwright');

async function quickCleanTest() {
  console.log('🧪 Quick Clean Test Starting...');
  
  const browser = await chromium.launch({ 
    headless: false,
    slowMo: 1000 
  });
  const page = await browser.newPage();
  await page.setViewportSize({ width: 1280, height: 720 });
  
  try {
    // Test home page
    console.log('\n📍 Testing Home Page with Clean CSS...');
    await page.goto('http://localhost:8080');
    await page.waitForTimeout(5000);
    
    const homeState = await page.evaluate(() => {
      const bodyText = document.body.innerText || document.body.textContent || '';
      const overlay = document.getElementById('flutter-fallback-overlay');
      const buttons = document.querySelectorAll('button, [role="button"]');
      const inputs = document.querySelectorAll('input');
      
      return {
        bodyTextLength: bodyText.length,
        bodyTextPreview: bodyText.substring(0, 200),
        hasOverlay: !!overlay,
        overlayHTML: overlay ? overlay.innerHTML.substring(0, 300) : '',
        buttonCount: buttons.length,
        inputCount: inputs.length,
        url: window.location.href,
      };
    });
    
    console.log('\n📊 Home Page State:');
    console.log(`Body Text Length: ${homeState.bodyTextLength}`);
    console.log(`Has Overlay: ${homeState.hasOverlay ? '✅' : '❌'}`);
    console.log(`Buttons: ${homeState.buttonCount}`);
    console.log(`Inputs: ${homeState.inputCount}`);
    
    if (homeState.overlayHTML.length > 0) {
      console.log(`\n📄 Overlay Preview:\n${homeState.overlayHTML}`);
    }
    
    if (homeState.bodyTextPreview.length > 0) {
      console.log(`\n📄 Body Preview:\n${homeState.bodyTextPreview}`);
    }
    
    await page.screenshot({ path: 'test-results/clean_home.png', fullPage: true });
    
    // Test customer login
    console.log('\n📍 Testing Customer Login...');
    await page.goto('http://localhost:8080/login/customer');
    await page.waitForTimeout(5000);
    
    const loginState = await page.evaluate(() => {
      const bodyText = document.body.innerText || document.body.textContent || '';
      const overlay = document.getElementById('flutter-fallback-overlay');
      const fallbackForm = document.getElementById('fallback-login-form');
      const buttons = document.querySelectorAll('button, [role="button"]');
      const inputs = document.querySelectorAll('input');
      
      return {
        bodyTextLength: bodyText.length,
        bodyTextPreview: bodyText.substring(0, 300),
        hasOverlay: !!overlay,
        hasFallbackForm: !!fallbackForm,
        buttonCount: buttons.length,
        inputCount: inputs.length,
        url: window.location.href,
      };
    });
    
    console.log('\n📊 Login Page State:');
    console.log(`Body Text Length: ${loginState.bodyTextLength}`);
    console.log(`Has Overlay: ${loginState.hasOverlay ? '✅' : '❌'}`);
    console.log(`Has Fallback Form: ${loginState.hasFallbackForm ? '✅' : '❌'}`);
    console.log(`Buttons: ${loginState.buttonCount}`);
    console.log(`Inputs: ${loginState.inputCount}`);
    
    if (loginState.bodyTextPreview.length > 0) {
      console.log(`\n📄 Login Page Preview:\n${loginState.bodyTextPreview}`);
    }
    
    await page.screenshot({ path: 'test-results/clean_login.png', fullPage: true });
    
    // Test functionality if forms are present
    if (loginState.hasFallbackForm || loginState.inputCount > 0) {
      console.log('\n🖱️ Testing form interaction...');
      
      try {
        if (loginState.hasFallbackForm) {
          // Test fallback form
          await page.click('#fallback-login-form button[type="submit"]');
          await page.waitForTimeout(2000);
        } else {
          // Test native form
          await page.fill('input[type="email"]', 'customer@example.com');
          await page.fill('input[type="password"]', 'customer123');
          await page.click('button:has-text("Sign In"), button, [role="button"]');
          await page.waitForTimeout(2000);
        }
        
        const finalUrl = page.url();
        console.log(`📍 After login attempt: ${finalUrl}`);
        
        const success = !finalUrl.includes('/login/customer');
        console.log(`Login ${success ? '✅ Successful' : '❌ Failed'}`);
        
      } catch (error) {
        console.log(`❌ Form interaction error: ${error.message}`);
      }
    }
    
    console.log('\n🎯 Clean Test Results:');
    console.log(`Home Page: ${homeState.hasOverlay || homeState.bodyTextLength > 50 ? '✅ Working' : '❌ Not Working'}`);
    console.log(`Login Page: ${loginState.hasFallbackForm || loginState.inputCount > 0 ? '✅ Working' : '❌ Not Working'}`);
    
  } catch (error) {
    console.error('❌ Quick clean test error:', error);
  } finally {
    await browser.close();
    console.log('🔚 Quick clean test completed');
  }
}

quickCleanTest().catch(console.error);
