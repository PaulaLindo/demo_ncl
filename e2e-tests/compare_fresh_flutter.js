// compare_fresh_flutter.js - Compare fresh Flutter build with our solution
const { chromium } = require('playwright');

async function compareFreshFlutter() {
  console.log('🧪 Comparing Fresh Flutter Build vs Our Solution...');
  
  const browser = await chromium.launch({ 
    headless: false,
    slowMo: 1000 
  });
  const page = await browser.newPage();
  await page.setViewportSize({ width: 1280, height: 720 });
  
  try {
    // Test 1: Fresh Flutter build on port 8081
    console.log('\n📍 Step 1: Testing Fresh Flutter Build (Port 8081)');
    await page.goto('http://localhost:8081');
    await page.waitForTimeout(8000);
    
    const freshFlutter = await page.evaluate(() => {
      return new Promise((resolve) => {
        setTimeout(() => {
          const bodyText = document.body.innerText || document.body.textContent || '';
          const flutterElements = document.querySelectorAll('flutter-view, flt-scene-host, flt-semantics-host');
          const buttons = document.querySelectorAll('button, [role="button"]');
          const inputs = document.querySelectorAll('input');
          const canvas = document.querySelector('canvas');
          
          resolve({
            bodyTextLength: bodyText.length,
            bodyTextPreview: bodyText.substring(0, 400),
            flutterElementCount: flutterElements.length,
            buttonCount: buttons.length,
            inputCount: inputs.length,
            hasCanvas: !!canvas,
            hasVisibleContent: bodyText.length > 50,
            hasInteractiveElements: buttons.length > 0 || inputs.length > 0,
            url: window.location.href,
            htmlStructure: document.documentElement.outerHTML.substring(0, 1500),
          });
        }, 5000);
      });
    });
    
    console.log('\n📊 Fresh Flutter Build Analysis:');
    console.log(`Body Text Length: ${freshFlutter.bodyTextLength}`);
    console.log(`Flutter Elements: ${freshFlutter.flutterElementCount}`);
    console.log(`Canvas Present: ${freshFlutter.hasCanvas ? '✅' : '❌'}`);
    console.log(`Buttons: ${freshFlutter.buttonCount}`);
    console.log(`Inputs: ${freshFlutter.inputCount}`);
    console.log(`Has Visible Content: ${freshFlutter.hasVisibleContent ? '✅' : '❌'}`);
    console.log(`Has Interactive Elements: ${freshFlutter.hasInteractiveElements ? '✅' : '❌'}`);
    
    if (freshFlutter.bodyTextPreview.length > 0) {
      console.log(`\n📄 Fresh Flutter Preview:\n${freshFlutter.bodyTextPreview}`);
    }
    
    await page.screenshot({ path: 'test-results/fresh_flutter_home.png', fullPage: true });
    
    // Test 2: Fresh Flutter login page
    console.log('\n📍 Step 2: Testing Fresh Flutter Login Page');
    await page.goto('http://localhost:8081/login/customer');
    await page.waitForTimeout(8000);
    
    const freshLogin = await page.evaluate(() => {
      return new Promise((resolve) => {
        setTimeout(() => {
          const bodyText = document.body.innerText || document.body.textContent || '';
          const inputs = document.querySelectorAll('input');
          const buttons = document.querySelectorAll('button, [role="button"]');
          const canvas = document.querySelector('canvas');
          
          const hasEmailField = Array.from(inputs).some(input => input.type === 'email');
          const hasPasswordField = Array.from(inputs).some(input => input.type === 'password');
          const hasLoginButton = Array.from(buttons).some(button => 
            (button.innerText || button.textContent || '').toLowerCase().includes('login') ||
            (button.innerText || button.textContent || '').toLowerCase().includes('sign in')
          );
          
          resolve({
            bodyTextLength: bodyText.length,
            bodyTextPreview: bodyText.substring(0, 400),
            inputCount: inputs.length,
            buttonCount: buttons.length,
            hasCanvas: !!canvas,
            hasEmailField,
            hasPasswordField,
            hasLoginButton,
            hasLoginForm: hasEmailField && hasPasswordField && hasLoginButton,
            hasVisibleContent: bodyText.length > 50,
            url: window.location.href,
          });
        }, 5000);
      });
    });
    
    console.log('\n📊 Fresh Flutter Login Analysis:');
    console.log(`Body Text Length: ${freshLogin.bodyTextLength}`);
    console.log(`Canvas Present: ${freshLogin.hasCanvas ? '✅' : '❌'}`);
    console.log(`Inputs: ${freshLogin.inputCount}`);
    console.log(`Buttons: ${freshLogin.buttonCount}`);
    console.log(`Has Email Field: ${freshLogin.hasEmailField ? '✅' : '❌'}`);
    console.log(`Has Password Field: ${freshLogin.hasPasswordField ? '✅' : '❌'}`);
    console.log(`Has Login Button: ${freshLogin.hasLoginButton ? '✅' : '❌'}`);
    console.log(`Has Login Form: ${freshLogin.hasLoginForm ? '✅' : '❌'}`);
    
    if (freshLogin.bodyTextPreview.length > 0) {
      console.log(`\n📄 Fresh Flutter Login Preview:\n${freshLogin.bodyTextPreview}`);
    }
    
    await page.screenshot({ path: 'test-results/fresh_flutter_login.png', fullPage: true });
    
    // Test 3: Our solution on port 8080
    console.log('\n📍 Step 3: Testing Our Solution (Port 8080)');
    await page.goto('http://localhost:8080');
    await page.waitForTimeout(7000);
    
    const ourSolution = await page.evaluate(() => {
      const overlay = document.getElementById('flutter-fallback-overlay');
      const bodyText = document.body.innerText || document.body.textContent || '';
      const buttons = document.querySelectorAll('button, [role="button"]');
      const inputs = document.querySelectorAll('input');
      
      return {
        hasOverlay: !!overlay,
        overlayHTML: overlay ? overlay.innerHTML.substring(0, 800) : '',
        bodyTextLength: bodyText.length,
        buttonCount: buttons.length,
        inputCount: inputs.length,
        hasLoginButtons: overlay && overlay.innerHTML.includes('Customer Login'),
        hasGradientBackground: overlay && overlay.innerHTML.includes('gradient'),
        hasFunctionalUI: overlay && overlay.innerHTML.length > 200,
        url: window.location.href,
      };
    });
    
    console.log('\n📊 Our Solution Analysis:');
    console.log(`Has Overlay: ${ourSolution.hasOverlay ? '✅' : '❌'}`);
    console.log(`Has Login Buttons: ${ourSolution.hasLoginButtons ? '✅' : '❌'}`);
    console.log(`Has Gradient Background: ${ourSolution.hasGradientBackground ? '✅' : '❌'}`);
    console.log(`Has Functional UI: ${ourSolution.hasFunctionalUI ? '✅' : '❌'}`);
    console.log(`Button Count: ${ourSolution.buttonCount}`);
    console.log(`Body Text Length: ${ourSolution.bodyTextLength}`);
    
    if (ourSolution.overlayHTML.length > 0) {
      console.log(`\n📄 Our Solution Preview:\n${ourSolution.overlayHTML}`);
    }
    
    await page.screenshot({ path: 'test-results/our_solution_final.png', fullPage: true });
    
    // Final comparison and recommendation
    console.log('\n📊 FINAL COMPARISON:');
    console.log('======================');
    
    console.log('\n🔍 Fresh Flutter Build (Port 8081):');
    console.log(`   Home Page: ${freshFlutter.hasVisibleContent ? '✅ Working' : '❌ Not Working'} (${freshFlutter.bodyTextLength} chars)`);
    console.log(`   Login Page: ${freshLogin.hasLoginForm ? '✅ Working' : '❌ Not Working'} (${freshLogin.inputCount} inputs, ${freshLogin.buttonCount} buttons)`);
    console.log(`   Canvas Rendering: ${freshFlutter.hasCanvas ? '✅' : '❌'}`);
    
    console.log('\n🔍 Our Solution (Port 8080):');
    console.log(`   Overlay System: ${ourSolution.hasOverlay ? '✅ Working' : '❌ Not Working'}`);
    console.log(`   Functional UI: ${ourSolution.hasFunctionalUI ? '✅ Working' : '❌ Not Working'}`);
    console.log(`   Login Buttons: ${ourSolution.hasLoginButtons ? '✅ Working' : '❌ Not Working'}`);
    
    console.log('\n🎯 RECOMMENDATION:');
    
    if (freshFlutter.hasVisibleContent && freshLogin.hasLoginForm) {
      console.log('✅ Fresh Flutter build is working - you can use the original Flutter UI');
      console.log('   Our solution can be removed or kept as enhancement');
    } else {
      console.log('❌ Fresh Flutter build still has issues - our solution is necessary');
      console.log('   Keep our solution for functional UI');
    }
    
    console.log('\n📸 Visual comparison saved in test-results/');
    console.log('   - fresh_flutter_home.png');
    console.log('   - fresh_flutter_login.png'); 
    console.log('   - our_solution_final.png');
    
  } catch (error) {
    console.error('❌ Comparison error:', error);
  } finally {
    await browser.close();
    console.log('🔚 Fresh Flutter comparison completed');
  }
}

compareFreshFlutter().catch(console.error);
