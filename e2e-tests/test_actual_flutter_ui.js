// test_actual_flutter_ui.js - Test the actual Flutter app UI without modifications
const { chromium } = require('playwright');
const fs = require('fs');
const path = require('path');

async function testActualFlutterUI() {
  console.log('🧪 Testing Actual Flutter App UI...');
  
  const browser = await chromium.launch({ 
    headless: false,
    slowMo: 1000 
  });
  const page = await browser.newPage();
  await page.setViewportSize({ width: 1280, height: 720 });
  
  try {
    // First, let's backup and disable our modifications to see the original Flutter UI
    console.log('\n📍 Step 1: Testing Original Flutter UI (without our modifications)');
    
    // Temporarily rename our CSS and JS files to disable them
    const webDir = 'c:\\dev\\demo_ncl\\web';
    const cssFile = path.join(webDir, 'clean_solution.css');
    const jsFile = path.join(webDir, 'flutter_fallback_forms.js');
    const uiHelperFile = path.join(webDir, 'flutter_ui_helper.js');
    
    // Backup files if they exist
    const backupCss = cssFile + '.backup';
    const backupJs = jsFile + '.backup';
    const backupUiHelper = uiHelperFile + '.backup';
    
    if (fs.existsSync(cssFile)) {
      fs.renameSync(cssFile, backupCss);
      console.log('✅ Temporarily disabled CSS file');
    }
    
    if (fs.existsSync(jsFile)) {
      fs.renameSync(jsFile, backupJs);
      console.log('✅ Temporarily disabled fallback forms');
    }
    
    if (fs.existsSync(uiHelperFile)) {
      fs.renameSync(uiHelperFile, backupUiHelper);
      console.log('✅ Temporarily disabled UI helper');
    }
    
    // Test 1: Original Flutter home page
    console.log('\n📍 Testing Original Flutter Home Page...');
    await page.goto('http://localhost:8080');
    await page.waitForTimeout(8000); // Give Flutter time to render
    
    const originalHome = await page.evaluate(() => {
      // Wait a bit more for Flutter to potentially render
      return new Promise((resolve) => {
        setTimeout(() => {
          const bodyText = document.body.innerText || document.body.textContent || '';
          const flutterElements = document.querySelectorAll('flutter-view, flt-scene-host, flt-semantics-host');
          const buttons = document.querySelectorAll('button, [role="button"]');
          const inputs = document.querySelectorAll('input');
          const textElements = document.querySelectorAll('div, span, p, h1, h2, h3, h4, h5, h6');
          
          resolve({
            bodyTextLength: bodyText.length,
            bodyTextPreview: bodyText.substring(0, 500),
            flutterElementCount: flutterElements.length,
            buttonCount: buttons.length,
            inputCount: inputs.length,
            textElementCount: textElements.length,
            hasVisibleContent: bodyText.length > 50,
            hasFlutterElements: flutterElements.length > 0,
            hasInteractiveElements: buttons.length > 0 || inputs.length > 0,
            url: window.location.href,
            pageTitle: document.title,
            htmlContent: document.documentElement.outerHTML.substring(0, 2000),
          });
        }, 3000);
      });
    });
    
    console.log('\n📊 Original Flutter Home Page Analysis:');
    console.log(`Body Text Length: ${originalHome.bodyTextLength}`);
    console.log(`Flutter Elements: ${originalHome.flutterElementCount}`);
    console.log(`Buttons: ${originalHome.buttonCount}`);
    console.log(`Inputs: ${originalHome.inputCount}`);
    console.log(`Text Elements: ${originalHome.textElementCount}`);
    console.log(`Has Visible Content: ${originalHome.hasVisibleContent ? '✅' : '❌'}`);
    console.log(`Has Flutter Elements: ${originalHome.hasFlutterElements ? '✅' : '❌'}`);
    console.log(`Has Interactive Elements: ${originalHome.hasInteractiveElements ? '✅' : '❌'}`);
    
    if (originalHome.bodyTextPreview.length > 0) {
      console.log(`\n📄 Body Text Preview:\n${originalHome.bodyTextPreview}`);
    }
    
    await page.screenshot({ path: 'test-results/original_flutter_home.png', fullPage: true });
    
    // Test 2: Original Flutter login pages
    const loginPages = [
      { name: 'Customer Login', url: '/login/customer' },
      { name: 'Staff Login', url: '/login/staff' },
      { name: 'Admin Login', url: '/login/admin' },
    ];
    
    for (const loginPage of loginPages) {
      console.log(`\n📍 Testing Original Flutter ${loginPage.name}...`);
      await page.goto(`http://localhost:8080${loginPage.url}`);
      await page.waitForTimeout(8000);
      
      const originalLogin = await page.evaluate(() => {
        return new Promise((resolve) => {
          setTimeout(() => {
            const bodyText = document.body.innerText || document.body.textContent || '';
            const inputs = document.querySelectorAll('input');
            const buttons = document.querySelectorAll('button, [role="button"]');
            const flutterElements = document.querySelectorAll('flutter-view, flt-scene-host, flt-semantics-host');
            
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
              flutterElementCount: flutterElements.length,
              hasEmailField,
              hasPasswordField,
              hasLoginButton,
              hasLoginForm: hasEmailField && hasPasswordField && hasLoginButton,
              hasVisibleContent: bodyText.length > 50,
              url: window.location.href,
            });
          }, 3000);
        });
      });
      
      console.log(`\n📊 Original Flutter ${loginPage.name} Analysis:`);
      console.log(`Body Text Length: ${originalLogin.bodyTextLength}`);
      console.log(`Inputs: ${originalLogin.inputCount}`);
      console.log(`Buttons: ${originalLogin.buttonCount}`);
      console.log(`Has Email Field: ${originalLogin.hasEmailField ? '✅' : '❌'}`);
      console.log(`Has Password Field: ${originalLogin.hasPasswordField ? '✅' : '❌'}`);
      console.log(`Has Login Button: ${originalLogin.hasLoginButton ? '✅' : '❌'}`);
      console.log(`Has Login Form: ${originalLogin.hasLoginForm ? '✅' : '❌'}`);
      console.log(`Has Visible Content: ${originalLogin.hasVisibleContent ? '✅' : '❌'}`);
      
      if (originalLogin.bodyTextPreview.length > 0) {
        console.log(`\n📄 ${loginPage.name} Text Preview:\n${originalLogin.bodyTextPreview}`);
      }
      
      await page.screenshot({ path: `test-results/original_flutter_${loginPage.name.toLowerCase().replace(' ', '_')}.png`, fullPage: true });
    }
    
    // Now restore our modifications and compare
    console.log('\n📍 Step 2: Restoring Our Solution and Comparing...');
    
    // Restore files
    if (fs.existsSync(backupCss)) {
      fs.renameSync(backupCss, cssFile);
      console.log('✅ Restored CSS file');
    }
    
    if (fs.existsSync(backupJs)) {
      fs.renameSync(backupJs, jsFile);
      console.log('✅ Restored fallback forms');
    }
    
    if (fs.existsSync(backupUiHelper)) {
      fs.renameSync(backupUiHelper, uiHelperFile);
      console.log('✅ Restored UI helper');
    }
    
    // Test our solution side by side
    console.log('\n📍 Step 3: Testing Our Solution Side by Side...');
    
    await page.goto('http://localhost:8080');
    await page.waitForTimeout(7000);
    
    const ourSolution = await page.evaluate(() => {
      const overlay = document.getElementById('flutter-fallback-overlay');
      const bodyText = document.body.innerText || document.body.textContent || '';
      const buttons = document.querySelectorAll('button, [role="button"]');
      
      return {
        hasOverlay: !!overlay,
        overlayHTML: overlay ? overlay.innerHTML.substring(0, 500) : '',
        bodyTextLength: bodyText.length,
        buttonCount: buttons.length,
        hasLoginButtons: overlay && overlay.innerHTML.includes('Customer Login'),
        hasGradientBackground: overlay && overlay.innerHTML.includes('gradient'),
        url: window.location.href,
      };
    });
    
    console.log('\n📊 Our Solution Analysis:');
    console.log(`Has Overlay: ${ourSolution.hasOverlay ? '✅' : '❌'}`);
    console.log(`Has Login Buttons: ${ourSolution.hasLoginButtons ? '✅' : '❌'}`);
    console.log(`Has Gradient Background: ${ourSolution.hasGradientBackground ? '✅' : '❌'}`);
    console.log(`Button Count: ${ourSolution.buttonCount}`);
    console.log(`Body Text Length: ${ourSolution.bodyTextLength}`);
    
    if (ourSolution.overlayHTML.length > 0) {
      console.log(`\n📄 Our Solution Overlay Preview:\n${ourSolution.overlayHTML}`);
    }
    
    await page.screenshot({ path: 'test-results/our_solution_comparison.png', fullPage: true });
    
    // Final comparison
    console.log('\n📊 COMPARISON SUMMARY:');
    console.log('======================');
    console.log('🔍 Original Flutter UI:');
    console.log(`   Home Page Content: ${originalHome.hasVisibleContent ? '✅' : '❌'} (${originalHome.bodyTextLength} chars)`);
    console.log(`   Interactive Elements: ${originalHome.hasInteractiveElements ? '✅' : '❌'} (${originalHome.buttonCount} buttons, ${originalHome.inputCount} inputs)`);
    console.log(`   Flutter Elements: ${originalHome.hasFlutterElements ? '✅' : '❌'} (${originalHome.flutterElementCount} elements)`);
    
    console.log('\n🔍 Our Solution:');
    console.log(`   Overlay System: ${ourSolution.hasOverlay ? '✅' : '❌'}`);
    console.log(`   Login Buttons: ${ourSolution.hasLoginButtons ? '✅' : '❌'}`);
    console.log(`   Gradient Background: ${ourSolution.hasGradientBackground ? '✅' : '❌'}`);
    console.log(`   Interactive Elements: ${ourSolution.buttonCount} buttons`);
    
    console.log('\n🎯 CONCLUSION:');
    if (originalHome.hasVisibleContent && originalHome.hasInteractiveElements) {
      console.log('✅ Original Flutter UI is working - our solution provides enhancement');
    } else {
      console.log('❌ Original Flutter UI has rendering issues - our solution provides necessary fallback');
    }
    
    console.log('📸 Screenshots saved for visual comparison in test-results/');
    
  } catch (error) {
    console.error('❌ Test error:', error);
  } finally {
    // Make sure to restore files even if there's an error
    try {
      if (fs.existsSync(backupCss)) fs.renameSync(backupCss, cssFile);
      if (fs.existsSync(backupJs)) fs.renameSync(backupJs, jsFile);
      if (fs.existsSync(backupUiHelper)) fs.renameSync(backupUiHelper, uiHelperFile);
    } catch (restoreError) {
      console.error('Error restoring files:', restoreError);
    }
    
    await browser.close();
    console.log('🔚 Actual Flutter UI test completed');
  }
}

testActualFlutterUI().catch(console.error);
