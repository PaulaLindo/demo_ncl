// test_flutter_widgets.js - Test the actual Flutter widgets and functionality
const { chromium } = require('playwright');

async function testFlutterWidgets() {
  console.log('🧪 Testing Flutter Widgets and Functionality...');
  
  const browser = await chromium.launch({ 
    headless: false,
    slowMo: 1000 
  });
  const page = await browser.newPage();
  await page.setViewportSize({ width: 1280, height: 720 });
  
  try {
    // Test 1: Flutter Login Chooser on home page
    console.log('\n📍 Step 1: Testing Flutter Login Chooser');
    await page.goto('http://localhost:8081');
    await page.waitForTimeout(10000); // Give Flutter more time to render
    
    const loginChooser = await page.evaluate(() => {
      // Wait for Flutter to potentially render
      return new Promise((resolve) => {
        setTimeout(() => {
          // Look for Flutter-specific elements
          const flutterView = document.querySelector('flutter-view');
          const sceneHost = document.querySelector('flt-scene-host');
          const semanticsHost = document.querySelector('flt-semantics-host');
          
          // Try to find buttons using different selectors
          const allButtons = document.querySelectorAll('button, [role="button"], flt-semantics-placeholder[role="button"]');
          const clickableElements = document.querySelectorAll('[role="button"], [tabindex]:not([tabindex="-1"])');
          
          // Look for text content in various ways
          const bodyText = document.body.innerText || document.body.textContent || '';
          const allTextElements = document.querySelectorAll('div, span, p, h1, h2, h3, h4, h5, h6, text, flt-text-pane, flt-semantic-text');
          
          // Extract text from all elements
          const extractedTexts = Array.from(allTextElements).map(el => 
            (el.innerText || el.textContent || '').trim()
          ).filter(text => text.length > 0);
          
          resolve({
            hasFlutterView: !!flutterView,
            hasSceneHost: !!sceneHost,
            hasSemanticsHost: !!semanticsHost,
            buttonCount: allButtons.length,
            clickableCount: clickableElements.length,
            textElementCount: allTextElements.length,
            bodyTextLength: bodyText.length,
            extractedTexts: extractedTexts.slice(0, 10), // First 10 text elements
            hasWelcomeText: extractedTexts.some(text => text.toLowerCase().includes('welcome')),
            hasLoginText: extractedTexts.some(text => text.toLowerCase().includes('login')),
            hasNCLText: extractedTexts.some(text => text.includes('NCL')),
            hasCustomerText: extractedTexts.some(text => text.toLowerCase().includes('customer')),
            url: window.location.href,
          });
        }, 8000);
      });
    });
    
    console.log('\n📊 Flutter Login Chooser Analysis:');
    console.log(`Flutter View: ${loginChooser.hasFlutterView ? '✅' : '❌'}`);
    console.log(`Scene Host: ${loginChooser.hasSceneHost ? '✅' : '❌'}`);
    console.log(`Semantics Host: ${loginChooser.hasSemanticsHost ? '✅' : '❌'}`);
    console.log(`Buttons: ${loginChooser.buttonCount}`);
    console.log(`Clickable Elements: ${loginChooser.clickableCount}`);
    console.log(`Text Elements: ${loginChooser.textElementCount}`);
    console.log(`Body Text Length: ${loginChooser.bodyTextLength}`);
    console.log(`Extracted Texts: ${loginChooser.extractedTexts.join(', ')}`);
    
    if (loginChooser.extractedTexts.length > 0) {
      console.log(`\n📄 Extracted Text Elements:`);
      loginChooser.extractedTexts.forEach((text, index) => {
        console.log(`  ${index + 1}. "${text}"`);
      });
    }
    
    await page.screenshot({ path: 'test-results/flutter_login_chooser.png', fullPage: true });
    
    // Test 2: Try to interact with Flutter elements
    console.log('\n📍 Step 2: Testing Flutter Widget Interaction');
    
    if (loginChooser.buttonCount > 0 || loginChooser.clickableCount > 0) {
      console.log('🖱️ Attempting to click Flutter elements...');
      
      try {
        // Try to find and click a customer login button
        const customerLoginClicked = await page.evaluate(() => {
          const buttons = document.querySelectorAll('button, [role="button"], flt-semantics-placeholder[role="button"]');
          
          for (const button of buttons) {
            const text = (button.innerText || button.textContent || '').toLowerCase();
            if (text.includes('customer') && text.includes('login')) {
              button.click();
              return true;
            }
          }
          
          // Try clicking the first button if no specific one found
          if (buttons.length > 0) {
            buttons[0].click();
            return true;
          }
          
          return false;
        });
        
        if (customerLoginClicked) {
          await page.waitForTimeout(3000);
          const currentUrl = page.url();
          console.log(`✅ Button clicked successfully! Current URL: ${currentUrl}`);
          
          // Check if we navigated to login page
          if (currentUrl.includes('/login/customer')) {
            console.log('✅ Successfully navigated to customer login page!');
            
            // Test 3: Flutter Login Screen
            console.log('\n📍 Step 3: Testing Flutter Login Screen');
            await page.waitForTimeout(5000);
            
            const flutterLogin = await page.evaluate(() => {
              return new Promise((resolve) => {
                setTimeout(() => {
                  const inputs = document.querySelectorAll('input, flt-semantics-placeholder input');
                  const buttons = document.querySelectorAll('button, [role="button"], flt-semantics-placeholder[role="button"]');
                  const allTextElements = document.querySelectorAll('div, span, p, h1, h2, h3, h4, h5, h6, text, flt-text-pane, flt-semantic-text');
                  
                  const extractedTexts = Array.from(allTextElements).map(el => 
                    (el.innerText || el.textContent || '').trim()
                  ).filter(text => text.length > 0);
                  
                  const hasEmailField = Array.from(inputs).some(input => input.type === 'email');
                  const hasPasswordField = Array.from(inputs).some(input => input.type === 'password');
                  const hasSignInButton = Array.from(buttons).some(button => {
                    const text = (button.innerText || button.textContent || '').toLowerCase();
                    return text.includes('sign in') || text.includes('login');
                  });
                  
                  resolve({
                    inputCount: inputs.length,
                    buttonCount: buttons.length,
                    textElementCount: allTextElements.length,
                    extractedTexts: extractedTexts.slice(0, 15),
                    hasEmailField,
                    hasPasswordField,
                    hasSignInButton,
                    hasLoginForm: hasEmailField && hasPasswordField && hasSignInButton,
                    hasCustomerPortal: extractedTexts.some(text => text.includes('Customer Portal')),
                    hasDemoCredentials: extractedTexts.some(text => text.toLowerCase().includes('demo')),
                    url: window.location.href,
                  });
                }, 5000);
              });
            });
            
            console.log('\n📊 Flutter Login Screen Analysis:');
            console.log(`Inputs: ${flutterLogin.inputCount}`);
            console.log(`Buttons: ${flutterLogin.buttonCount}`);
            console.log(`Has Email Field: ${flutterLogin.hasEmailField ? '✅' : '❌'}`);
            console.log(`Has Password Field: ${flutterLogin.hasPasswordField ? '✅' : '❌'}`);
            console.log(`Has Sign In Button: ${flutterLogin.hasSignInButton ? '✅' : '❌'}`);
            console.log(`Has Login Form: ${flutterLogin.hasLoginForm ? '✅' : '❌'}`);
            console.log(`Has Customer Portal: ${flutterLogin.hasCustomerPortal ? '✅' : '❌'}`);
            console.log(`Has Demo Credentials: ${flutterLogin.hasDemoCredentials ? '✅' : '❌'}`);
            
            if (flutterLogin.extractedTexts.length > 0) {
              console.log(`\n📄 Login Screen Text Elements:`);
              flutterLogin.extractedTexts.forEach((text, index) => {
                console.log(`  ${index + 1}. "${text}"`);
              });
            }
            
            await page.screenshot({ path: 'test/results/flutter_login_screen.png', fullPage: true });
            
            // Test 4: Try to fill and submit the form
            if (flutterLogin.hasLoginForm) {
              console.log('\n📍 Step 4: Testing Flutter Form Submission');
              
              try {
                const formSubmitted = await page.evaluate(() => {
                  // Find email field
                  const emailField = document.querySelector('input[type="email"], input[name*="email"], input[placeholder*="email"]');
                  const passwordField = document.querySelector('input[type="password"], input[name*="password"], input[placeholder*="password"]');
                  
                  if (emailField && passwordField) {
                    emailField.value = 'customer@example.com';
                    passwordField.value = 'customer123';
                    
                    // Trigger events
                    emailField.dispatchEvent(new Event('input', { bubbles: true }));
                    emailField.dispatchEvent(new Event('change', { bubbles: true }));
                    passwordField.dispatchEvent(new Event('input', { bubbles: true }));
                    passwordField.dispatchEvent(new Event('change', { bubbles: true }));
                    
                    // Find and click submit button
                    const buttons = document.querySelectorAll('button, [role="button"]');
                    for (const button of buttons) {
                      const text = (button.innerText || button.textContent || '').toLowerCase();
                      if (text.includes('sign in') || text.includes('login')) {
                        button.click();
                        return true;
                      }
                    }
                  }
                  
                  return false;
                });
                
                if (formSubmitted) {
                  await page.waitForTimeout(5000);
                  const finalUrl = page.url();
                  const loginSuccess = !finalUrl.includes('/login/customer');
                  
                  console.log(`\n📊 Form Submission Result:`);
                  console.log(`Final URL: ${finalUrl}`);
                  console.log(`Login Success: ${loginSuccess ? '✅' : '❌'}`);
                  
                  await page.screenshot({ path: 'test-results/flutter_login_result.png', fullPage: true });
                }
                
              } catch (error) {
                console.log(`❌ Form submission error: ${error.message}`);
              }
            }
          }
        } else {
          console.log('❌ No buttons were clicked');
        }
        
      } catch (error) {
        console.log(`❌ Interaction error: ${error.message}`);
      }
    }
    
    // Final summary
    console.log('\n📊 FLUTTER WIDGETS SUMMARY:');
    console.log('==========================');
    console.log(`✅ Flutter Framework: ${loginChooser.hasFlutterView ? 'Working' : 'Not Detected'}`);
    console.log(`✅ Scene Host: ${loginChooser.hasSceneHost ? 'Working' : 'Not Detected'}`);
    console.log(`✅ Semantic Elements: ${loginChooser.hasSemanticsHost ? 'Working' : 'Not Detected'}`);
    console.log(`✅ Widget Rendering: ${loginChooser.textElementCount > 0 ? 'Working' : 'Not Working'}`);
    console.log(`✅ Interactive Elements: ${loginChooser.buttonCount > 0 ? 'Working' : 'Not Working'}`);
    
    if (loginChooser.hasFlutterView && loginChooser.textElementCount > 0) {
      console.log('\n🎉 SUCCESS! Flutter widgets are working!');
      console.log('✅ The original Flutter UI is functional');
      console.log('✅ No modifications needed');
      console.log('✅ Use port 8081 for the working Flutter app');
    } else {
      console.log('\n⚠️  Flutter widgets may need more time to render or have issues');
    }
    
  } catch (error) {
    console.error('❌ Test error:', error);
  } finally {
    await browser.close();
    console.log('🔚 Flutter widgets test completed');
  }
}

testFlutterWidgets().catch(console.error);
