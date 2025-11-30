// test_javascript_loading.js - Test if JavaScript files are loading properly
const { chromium } = require('playwright');

async function testJavaScriptLoading() {
  console.log('🧪 Testing JavaScript Loading...');
  
  const browser = await chromium.launch({ 
    headless: false,
    slowMo: 2000 
  });
  const page = await browser.newPage();
  await page.setViewportSize({ width: 1280, height: 720 });
  
  try {
    // Listen for console messages
    const consoleMessages = [];
    page.on('console', msg => {
      consoleMessages.push(msg.text());
      console.log(`📝 Console: ${msg.text()}`);
    });
    
    console.log('\n📍 Step 1: Loading Home Page');
    await page.goto('http://localhost:8080');
    await page.waitForTimeout(5000);
    
    // Check if JavaScript files loaded
    const jsLoaded = await page.evaluate(() => {
      return {
        hasFlutterUIHelper: typeof window.flutterUIHelper !== 'undefined',
        hasFallbackForms: typeof window.createLoginForm !== 'undefined',
        hasOverlayContainer: !!document.querySelector('#flutter-ui-helper'),
        bodyText: document.body.innerText || document.body.textContent || '',
        url: window.location.href
      };
    });
    
    console.log('\n📊 JavaScript Loading Analysis:');
    console.log(`Flutter UI Helper Loaded: ${jsLoaded.hasFlutterUIHelper ? '✅' : '❌'}`);
    console.log(`Fallback Forms Loaded: ${jsLoaded.hasFallbackForms ? '✅' : '❌'}`);
    console.log(`Overlay Container: ${jsLoaded.hasOverlayContainer ? '✅' : '❌'}`);
    console.log(`Body Text Length: ${jsLoaded.bodyText.length}`);
    console.log(`Current URL: ${jsLoaded.url}`);
    
    if (jsLoaded.bodyText.length > 0) {
      console.log(`\n📄 Body Text Preview:\n${jsLoaded.bodyText.substring(0, 300)}`);
    }
    
    console.log(`\n📝 Console Messages (${consoleMessages.length}):`);
    consoleMessages.forEach((msg, index) => {
      console.log(`  ${index + 1}. ${msg}`);
    });
    
    // Test login page
    console.log('\n📍 Step 2: Loading Customer Login Page');
    await page.goto('http://localhost:8080/login/customer');
    await page.waitForTimeout(5000);
    
    const loginPageAnalysis = await page.evaluate(() => {
      return {
        bodyText: document.body.innerText || document.body.textContent || '',
        hasOverlay: !!document.querySelector('#flutter-ui-helper'),
        hasForm: !!document.querySelector('form'),
        hasInputs: !!document.querySelector('input'),
        hasButtons: !!document.querySelector('button'),
        url: window.location.href
      };
    });
    
    console.log('\n📊 Login Page Analysis:');
    console.log(`Body Text Length: ${loginPageAnalysis.bodyText.length}`);
    console.log(`Has Overlay: ${loginPageAnalysis.hasOverlay ? '✅' : '❌'}`);
    console.log(`Has Form: ${loginPageAnalysis.hasForm ? '✅' : '❌'}`);
    console.log(`Has Inputs: ${loginPageAnalysis.hasInputs ? '✅' : '❌'}`);
    console.log(`Has Buttons: ${loginPageAnalysis.hasButtons ? '✅' : '❌'}`);
    
    if (loginPageAnalysis.bodyText.length > 0) {
      console.log(`\n📄 Login Page Text Preview:\n${loginPageAnalysis.bodyText.substring(0, 300)}`);
    }
    
    await page.screenshot({ path: 'test-results/javascript_test.png', fullPage: true });
    
    console.log('\n📊 JAVASCRIPT LOADING SUMMARY:');
    console.log('===============================');
    
    const jsWorking = jsLoaded.hasFlutterUIHelper || jsLoaded.hasFallbackForms;
    const formsWorking = loginPageAnalysis.hasForm || loginPageAnalysis.hasInputs;
    
    console.log(`✅ JavaScript Files: ${jsWorking ? 'Working' : 'Not Working'}`);
    console.log(`✅ Forms/Overlays: ${formsWorking ? 'Working' : 'Not Working'}`);
    
    if (jsWorking && formsWorking) {
      console.log('\n🎉 SUCCESS! JavaScript fallback system is working!');
    } else {
      console.log('\n⚠️  JavaScript system needs debugging');
      if (!jsWorking) {
        console.log('❌ JavaScript files not loading properly');
      }
      if (!formsWorking) {
        console.log('❌ Forms/overlays not being created');
      }
    }
    
    console.log('\n📸 Screenshot saved: test-results/javascript_test.png');
    
  } catch (error) {
    console.error('❌ Test error:', error);
  } finally {
    await browser.close();
    console.log('🔚 JavaScript loading test completed');
  }
}

testJavaScriptLoading().catch(console.error);
