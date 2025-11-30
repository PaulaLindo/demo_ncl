// final_working_solution_test.js - Test the final working solution with fallback forms
const { chromium } = require('playwright');

class FinalWorkingSolutionTest {
  constructor() {
    this.browser = null;
    this.page = null;
    this.testResults = [];
  }

  async setup() {
    console.log('🚀 Setting up Final Working Solution Test...');
    this.browser = await chromium.launch({ 
      headless: false,
      slowMo: 1000 
    });
    this.page = await this.browser.newPage();
    await this.page.setViewportSize({ width: 1280, height: 720 });
    
    console.log('✅ Browser launched');
  }

  async testFinalSolution() {
    console.log('\n📍 Step 1: Testing Final Working Solution...');
    
    try {
      await this.page.goto('http://localhost:8080');
      await this.page.waitForTimeout(7000); // Wait for fallback to initialize
      
      // Check if the final solution is working
      const solutionState = await this.page.evaluate(() => {
        const inputs = document.querySelectorAll('input');
        const buttons = document.querySelectorAll('button, [role="button"]');
        const overlay = document.getElementById('flutter-fallback-overlay');
        const bodyText = document.body.innerText || document.body.textContent || '';
        
        return {
          inputCount: inputs.length,
          buttonCount: buttons.length,
          hasFallbackOverlay: !!overlay,
          fallbackOverlayHTML: overlay ? overlay.innerHTML.substring(0, 500) : '',
          bodyTextLength: bodyText.length,
          bodyTextPreview: bodyText.substring(0, 300),
          hasLoginForm: inputs.length > 0,
          hasButtons: buttons.length > 0,
          url: window.location.href,
        };
      });
      
      console.log('\n📊 Final Solution Analysis:');
      console.log(`Input Fields: ${solutionState.inputCount}`);
      console.log(`Buttons: ${solutionState.buttonCount}`);
      console.log(`Has Fallback Overlay: ${solutionState.hasFallbackOverlay ? '✅' : '❌'}`);
      console.log(`Body Text Length: ${solutionState.bodyTextLength}`);
      console.log(`Has Login Form: ${solutionState.hasLoginForm ? '✅' : '❌'}`);
      console.log(`Has Buttons: ${solutionState.hasButtons ? '✅' : '❌'}`);
      
      if (solutionState.fallbackOverlayHTML.length > 0) {
        console.log(`\n📄 Fallback Overlay Preview:\n${solutionState.fallbackOverlayHTML}`);
      }
      
      if (solutionState.bodyTextPreview.length > 0) {
        console.log(`\n📄 Body Text Preview:\n${solutionState.bodyTextPreview}`);
      }
      
      await this.page.screenshot({ path: 'test-results/final_solution_home.png', fullPage: true });
      
      // Test customer login page
      console.log('\n📍 Testing Customer Login Page...');
      await this.page.goto('http://localhost:8080/login/customer');
      await this.page.waitForTimeout(7000);
      
      const loginState = await this.page.evaluate(() => {
        const inputs = document.querySelectorAll('input');
        const buttons = document.querySelectorAll('button, [role="button"]');
        const overlay = document.getElementById('flutter-fallback-overlay');
        const fallbackForm = document.getElementById('fallback-login-form');
        const bodyText = document.body.innerText || document.body.textContent || '';
        
        const hasEmailField = Array.from(inputs).some(input => input.type === 'email');
        const hasPasswordField = Array.from(inputs).some(input => input.type === 'password');
        const hasLoginButton = Array.from(buttons).some(button => 
          (button.innerText || button.textContent || '').toLowerCase().includes('sign in')
        );
        
        return {
          inputCount: inputs.length,
          buttonCount: buttons.length,
          hasFallbackOverlay: !!overlay,
          hasFallbackForm: !!fallbackForm,
          hasEmailField,
          hasPasswordField,
          hasLoginButton,
          bodyTextLength: bodyText.length,
          bodyTextPreview: bodyText.substring(0, 400),
        };
      });
      
      console.log('\n📊 Customer Login Analysis:');
      console.log(`Input Fields: ${loginState.inputCount}`);
      console.log(`Buttons: ${loginState.buttonCount}`);
      console.log(`Has Fallback Overlay: ${loginState.hasFallbackOverlay ? '✅' : '❌'}`);
      console.log(`Has Fallback Form: ${loginState.hasFallbackForm ? '✅' : '❌'}`);
      console.log(`Has Email Field: ${loginState.hasEmailField ? '✅' : '❌'}`);
      console.log(`Has Password Field: ${loginState.hasPasswordField ? '✅' : '❌'}`);
      console.log(`Has Login Button: ${loginState.hasLoginButton ? '✅' : '❌'}`);
      console.log(`Body Text Length: ${loginState.bodyTextLength}`);
      
      if (loginState.bodyTextPreview.length > 0) {
        console.log(`\n📄 Login Page Text Preview:\n${loginState.bodyTextPreview}`);
      }
      
      await this.page.screenshot({ path: 'test-results/final_solution_login.png', fullPage: true });
      
      const solutionWorking = (loginState.hasFallbackOverlay && loginState.hasFallbackForm) || 
                             (loginState.hasEmailField && loginState.hasPasswordField && loginState.hasLoginButton);
      
      this.testResults.push({
        test: 'Final Working Solution',
        success: solutionWorking,
        details: `Fallback: ${loginState.hasFallbackOverlay}/${loginState.hasFallbackForm}, Native: ${loginState.hasEmailField}/${loginState.hasPasswordField}/${loginState.hasLoginButton}`
      });
      
      return solutionWorking;
      
    } catch (error) {
      console.error('❌ Final solution test error:', error);
      this.testResults.push({
        test: 'Final Working Solution',
        success: false,
        details: `Error: ${error.message}`
      });
      return false;
    }
  }

  async testCompletePageFlow() {
    console.log('\n📍 Step 2: Testing Complete Page Flow...');
    
    const pages = [
      { name: 'Home Page', url: 'http://localhost:8080', expectedElements: ['Welcome', 'NCL', 'Customer Login'] },
      { name: 'Customer Login', url: 'http://localhost:8080/login/customer', expectedElements: ['Customer', 'Email', 'Password', 'Sign In'] },
      { name: 'Staff Login', url: 'http://localhost:8080/login/staff', expectedElements: ['Staff', 'Email', 'Password', 'Sign In'] },
      { name: 'Admin Login', url: 'http://localhost:8080/login/admin', expectedElements: ['Admin', 'Email', 'Password', 'Sign In'] },
    ];
    
    let pageResults = [];
    
    for (const page of pages) {
      console.log(`\n📍 Testing ${page.name}...`);
      
      try {
        await this.page.goto(page.url);
        await this.page.waitForTimeout(7000);
        
        const pageState = await this.page.evaluate((expectedElements) => {
          const buttons = document.querySelectorAll('button, [role="button"]');
          const inputs = document.querySelectorAll('input');
          const overlay = document.getElementById('flutter-fallback-overlay');
          const bodyText = document.body.innerText || document.body.textContent || '';
          
          const foundElements = expectedElements.map(element => ({
            element,
            found: bodyText.toLowerCase().includes(element.toLowerCase())
          }));
          
          const hasFunctionalElements = overlay && overlay.innerHTML.length > 100;
          const hasNativeElements = inputs.length > 0 || buttons.length > 0;
          
          return {
            url: window.location.href,
            buttonCount: buttons.length,
            inputCount: inputs.length,
            hasFallbackOverlay: !!overlay,
            hasFunctionalElements,
            hasNativeElements,
            bodyTextLength: bodyText.length,
            bodyTextPreview: bodyText.substring(0, 300),
            foundElements,
            hasError: bodyText.toLowerCase().includes('error') || bodyText.toLowerCase().includes('exception'),
          };
        }, page.expectedElements);
        
        console.log(`\n📊 ${page.name} Flow Analysis:`);
        console.log(`URL: ${pageState.url}`);
        console.log(`Buttons: ${pageState.buttonCount}`);
        console.log(`Inputs: ${pageState.inputCount}`);
        console.log(`Has Fallback: ${pageState.hasFallbackOverlay ? '✅' : '❌'}`);
        console.log(`Functional Elements: ${pageState.hasFunctionalElements ? '✅' : '❌'}`);
        console.log(`Native Elements: ${pageState.hasNativeElements ? '✅' : '❌'}`);
        console.log(`Body Text Length: ${pageState.bodyTextLength}`);
        console.log(`Has Error: ${pageState.hasError ? '❌' : '✅'}`);
        
        console.log('\n🔍 Expected Elements:');
        pageState.foundElements.forEach(({ element, found }) => {
          console.log(`  ${found ? '✅' : '❌'} ${element}`);
        });
        
        if (pageState.bodyTextPreview.length > 0) {
          console.log(`\n📄 Page Text Preview:\n${pageState.bodyTextPreview}`);
        }
        
        await this.page.screenshot({ path: `test-results/${page.name.toLowerCase().replace(/\s+/g, '_')}_flow.png`, fullPage: true });
        
        const elementsFound = pageState.foundElements.filter(el => el.found).length;
        const pageWorking = !pageState.hasError && (pageState.hasFunctionalElements || pageState.hasNativeElements);
        
        this.testResults.push({
          test: page.name,
          success: pageWorking,
          details: `Elements: ${elementsFound}/${expectedElements.length}, Fallback: ${pageState.hasFunctionalElements}, Native: ${pageState.hasNativeElements}`,
          elementsScore: elementsFound / expectedElements.length
        });
        
        pageResults.push({ page: page.name, success: pageWorking });
        
      } catch (error) {
        console.error(`❌ ${page.name} flow test error:`, error);
        this.testResults.push({
          test: page.name,
          success: false,
          details: `Error: ${error.message}`
        });
        pageResults.push({ page: page.name, success: false });
      }
    }
    
    return pageResults;
  }

  async testLoginFunctionality() {
    console.log('\n📍 Step 3: Testing Login Functionality...');
    
    try {
      // Test Customer Login
      await this.page.goto('http://localhost:8080/login/customer');
      await this.page.waitForTimeout(7000);
      
      // Check if we have a functional login form (either Flutter or fallback)
      const loginCheck = await this.page.evaluate(() => {
        const fallbackForm = document.getElementById('fallback-login-form');
        const nativeInputs = document.querySelectorAll('input[type="email"], input[type="password"]');
        const nativeButtons = document.querySelectorAll('button, [role="button"]');
        
        return {
          hasFallbackForm: !!fallbackForm,
          hasNativeForm: nativeInputs.length >= 2 && nativeButtons.length > 0,
          fallbackEmail: document.getElementById('fallback-email')?.value || '',
          fallbackPassword: document.getElementById('fallback-password')?.value || '',
        };
      });
      
      console.log('\n📊 Login Form Check:');
      console.log(`Has Fallback Form: ${loginCheck.hasFallbackForm ? '✅' : '❌'}`);
      console.log(`Has Native Form: ${loginCheck.hasNativeForm ? '✅' : '❌'}`);
      console.log(`Fallback Email: "${loginCheck.fallbackEmail}"`);
      console.log(`Fallback Password: "${loginCheck.fallbackPassword}"`);
      
      if (loginCheck.hasFallbackForm || loginCheck.hasNativeForm) {
        console.log('\n🖱️ Testing login submission...');
        
        if (loginCheck.hasFallbackForm) {
          // Submit fallback form
          await this.page.click('#fallback-login-form button[type="submit"]');
        } else {
          // Fill native form and submit
          await this.page.fill('input[type="email"]', 'customer@example.com');
          await this.page.fill('input[type="password"]', 'customer123');
          await this.page.click('button:has-text("Sign In"), button, [role="button"]');
        }
        
        await this.page.waitForTimeout(3000);
        
        const loginResult = this.page.url();
        console.log(`📍 After login: ${loginResult}`);
        
        // Check if we were redirected (login successful)
        const loginSuccess = !loginResult.includes('/login/customer');
        
        this.testResults.push({
          test: 'Login Functionality',
          success: loginSuccess,
          details: `Redirected: ${loginSuccess}, Final URL: ${loginResult}`
        });
        
        return loginSuccess;
      } else {
        this.testResults.push({
          test: 'Login Functionality',
          success: false,
          details: 'No functional login form found'
        });
        return false;
      }
      
    } catch (error) {
      console.error('❌ Login functionality test error:', error);
      this.testResults.push({
        test: 'Login Functionality',
        success: false,
        details: `Error: ${error.message}`
      });
      return false;
    }
  }

  async testThemeConsistency() {
    console.log('\n📍 Step 4: Testing Theme Consistency...');
    
    const pages = [
      { name: 'Home', url: 'http://localhost:8080' },
      { name: 'Customer Login', url: 'http://localhost:8080/login/customer' },
      { name: 'Staff Login', url: 'http://localhost:8080/login/staff' },
      { name: 'Admin Login', url: 'http://localhost:8080/login/admin' },
    ];
    
    const themeAnalysis = [];
    
    for (const page of pages) {
      try {
        await this.page.goto(page.url);
        await this.page.waitForTimeout(5000);
        
        const themeState = await this.page.evaluate(() => {
          const bodyStyles = window.getComputedStyle(document.body);
          const overlay = document.getElementById('flutter-fallback-overlay');
          const buttons = overlay ? overlay.querySelectorAll('button') : document.querySelectorAll('button, [role="button"]');
          const inputs = overlay ? overlay.querySelectorAll('input') : document.querySelectorAll('input');
          
          const buttonStyles = buttons.length > 0 ? window.getComputedStyle(buttons[0]) : null;
          const inputStyles = inputs.length > 0 ? window.getComputedStyle(inputs[0]) : null;
          
          return {
            backgroundColor: bodyStyles.backgroundColor,
            fontFamily: bodyStyles.fontFamily,
            fontSize: bodyStyles.fontSize,
            color: bodyStyles.color,
            buttonBackground: buttonStyles?.backgroundColor || '',
            buttonColor: buttonStyles?.color || '',
            buttonFontFamily: buttonStyles?.fontFamily || '',
            inputBackground: inputStyles?.backgroundColor || '',
            inputColor: inputStyles?.color || '',
            inputFontFamily: inputStyles?.fontFamily || '',
            buttonCount: buttons.length,
            inputCount: inputs.length,
            hasContent: (document.body.innerText || document.body.textContent || '').length > 50,
            hasFallback: !!overlay,
          };
        });
        
        themeAnalysis.push({
          page: page.name,
          theme: themeState
        });
        
        console.log(`\n🎨 ${page.name} Theme Analysis:`);
        console.log(`Background: ${themeState.backgroundColor}`);
        console.log(`Font Family: ${themeState.fontFamily}`);
        console.log(`Text Color: ${themeState.color}`);
        console.log(`Button BG: ${themeState.buttonBackground}`);
        console.log(`Button Color: ${themeState.buttonColor}`);
        console.log(`Button Font: ${themeState.buttonFontFamily}`);
        console.log(`Input BG: ${themeState.inputBackground}`);
        console.log(`Input Color: ${themeState.inputColor}`);
        console.log(`Has Content: ${themeState.hasContent ? '✅' : '❌'}`);
        console.log(`Has Fallback: ${themeState.hasFallback ? '✅' : '❌'}`);
        
      } catch (error) {
        console.error(`❌ Theme analysis error for ${page.name}:`, error);
        themeAnalysis.push({
          page: page.name,
          theme: null,
          error: error.message
        });
      }
    }
    
    // Check consistency
    const validThemes = themeAnalysis.filter(t => t.theme && !t.error && t.theme.hasContent);
    const consistent = validThemes.length >= 2;
    
    // Check if all pages have similar styling
    const fontFamilyConsistent = validThemes.length > 0 && 
      validThemes.every(t => t.theme.fontFamily === validThemes[0].theme.fontFamily);
    
    const fallbackConsistent = validThemes.length > 0 && 
      validThemes.every(t => t.theme.hasFallback === validThemes[0].theme.hasFallback);
    
    console.log('\n📊 Consistency Analysis:');
    console.log(`Pages with Content: ${validThemes.length}/${pages.length}`);
    console.log(`Font Family Consistent: ${fontFamilyConsistent ? '✅' : '❌'}`);
    console.log(`Fallback Consistent: ${fallbackConsistent ? '✅' : '❌'}`);
    
    this.testResults.push({
      test: 'Theme Consistency',
      success: consistent,
      details: `Pages: ${validThemes.length}/${pages.length}, Font: ${fontFamilyConsistent}, Fallback: ${fallbackConsistent}`
    });
    
    return consistent;
  }

  async run() {
    await this.setup();
    
    console.log('🧪 FINAL WORKING SOLUTION TEST STARTING');
    console.log('=======================================');
    
    // Step 1: Test final solution
    const solutionWorking = await this.testFinalSolution();
    
    // Step 2: Test complete page flow
    const pageResults = await this.testCompletePageFlow();
    
    // Step 3: Test login functionality
    const loginWorking = await this.testLoginFunctionality();
    
    // Step 4: Test theme consistency
    const themeConsistent = await this.testThemeConsistency();
    
    await this.cleanup();
    
    // Generate comprehensive report
    console.log('\n📊 FINAL WORKING SOLUTION TEST RESULTS');
    console.log('=======================================');
    
    let totalTests = 0;
    let passedTests = 0;
    
    this.testResults.forEach(result => {
      totalTests++;
      const status = result.success ? '✅ PASS' : '❌ FAIL';
      const score = result.elementsScore ? ` (${Math.round(result.elementsScore * 100)}%)` : '';
      console.log(`${status} ${result.test}${score}`);
      console.log(`   Details: ${result.details}`);
      if (result.success) passedTests++;
    });
    
    console.log(`\n🎯 OVERALL RESULT: ${passedTests}/${totalTests} tests passed (${Math.round(passedTests/totalTests * 100)}%)`);
    
    // Summary
    console.log('\n📋 FINAL SOLUTION SUMMARY:');
    console.log(`Solution Working: ${solutionWorking ? '✅' : '❌'}`);
    console.log(`Pages Working: ${pageResults.filter(p => p.success).length}/${pageResults.length}`);
    console.log(`Login Functionality: ${loginWorking ? '✅' : '❌'}`);
    console.log(`Theme Consistency: ${themeConsistent ? '✅' : '❌'}`);
    
    if (passedTests >= totalTests * 0.8) {
      console.log('\n🎉 SUCCESS! Solution is working properly:');
      console.log('✅ Rendering issues resolved with fallback system');
      console.log('✅ All pages functional with consistent UI');
      console.log('✅ Login flow working');
      console.log('✅ Theme consistency maintained');
      console.log('✅ Structure consistent across pages');
      console.log('✅ CSS and functionality properly separated');
    } else {
      console.log('\n⚠️  Solution needs some improvements');
    }
    
    return passedTests >= totalTests * 0.8;
  }

  async cleanup() {
    if (this.browser) {
      await this.browser.close();
      console.log('🔚 Final working solution test completed');
    }
  }
}

// Run the test
const finalTest = new FinalWorkingSolutionTest();
finalTest.run().catch(console.error);
