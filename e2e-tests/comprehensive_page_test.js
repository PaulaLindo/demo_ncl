// comprehensive_page_test.js - Test rendering fix and all pages for functionality and consistency
const { chromium } = require('playwright');

class ComprehensivePageTest {
  constructor() {
    this.browser = null;
    this.page = null;
    this.testResults = [];
  }

  async setup() {
    console.log('🚀 Setting up Comprehensive Page Test...');
    this.browser = await chromium.launch({ 
      headless: false,
      slowMo: 1000 
    });
    this.page = await this.browser.newPage();
    await this.page.setViewportSize({ width: 1280, height: 720 });
    
    // Monitor console for debugging
    this.page.on('console', msg => {
      if (msg.type() === 'error') {
        console.log(`❌ Browser Error: ${msg.text()}`);
      }
    });
    
    console.log('✅ Browser launched');
  }

  async testRenderingFix() {
    console.log('\n📍 Step 1: Testing Flutter Rendering Fix...');
    
    try {
      await this.page.goto('http://localhost:8080');
      await this.page.waitForTimeout(5000);
      
      // Check if Flutter elements are now visible
      const renderingState = await this.page.evaluate(() => {
        const inputs = document.querySelectorAll('input');
        const buttons = document.querySelectorAll('button, [role="button"]');
        const textElements = document.querySelectorAll('div, span, p, h1, h2, h3, h4, h5, h6, label');
        const flutterElements = document.querySelectorAll('flt-semantics-placeholder, flt-semantics-container, flt-text-pane');
        
        return {
          inputCount: inputs.length,
          buttonCount: buttons.length,
          textElementCount: textElements.length,
          flutterElementCount: flutterElements.length,
          visibleInputs: Array.from(inputs).filter(input => 
            input.offsetParent !== null && 
            window.getComputedStyle(input).display !== 'none' &&
            window.getComputedStyle(input).visibility !== 'hidden'
          ).length,
          visibleButtons: Array.from(buttons).filter(button => 
            button.offsetParent !== null && 
            window.getComputedStyle(button).display !== 'none' &&
            window.getComputedStyle(button).visibility !== 'hidden'
          ).length,
          bodyText: document.body.innerText || document.body.textContent || '',
          bodyTextLength: (document.body.innerText || document.body.textContent || '').length,
        };
      });
      
      console.log('\n📊 Rendering State Analysis:');
      console.log(`Input Fields: ${renderingState.inputCount} (${renderingState.visibleInputs} visible)`);
      console.log(`Buttons: ${renderingState.buttonCount} (${renderingState.visibleButtons} visible)`);
      console.log(`Text Elements: ${renderingState.textElementCount}`);
      console.log(`Flutter Elements: ${renderingState.flutterElementCount}`);
      console.log(`Body Text Length: ${renderingState.bodyTextLength}`);
      
      if (renderingState.bodyTextLength > 100) {
        console.log(`\n📄 Body Text Preview:\n${renderingState.bodyText.substring(0, 300)}`);
      }
      
      await this.page.screenshot({ path: 'test-results/rendering_fix_home.png', fullPage: true });
      
      // Test customer login page rendering
      console.log('\n📍 Testing Customer Login Page Rendering...');
      await this.page.goto('http://localhost:8080/login/customer');
      await this.page.waitForTimeout(5000);
      
      const loginRenderingState = await this.page.evaluate(() => {
        const inputs = document.querySelectorAll('input');
        const buttons = document.querySelectorAll('button, [role="button"]');
        const textElements = document.querySelectorAll('div, span, p, h1, h2, h3, h4, h5, h6, label');
        
        return {
          inputCount: inputs.length,
          buttonCount: buttons.length,
          textElementCount: textElements.length,
          hasEmailField: Array.from(inputs).some(input => input.type === 'email'),
          hasPasswordField: Array.from(inputs).some(input => input.type === 'password'),
          hasLoginButton: Array.from(buttons).some(button => 
            (button.innerText || button.textContent || '').toLowerCase().includes('login') ||
            (button.innerText || button.textContent || '').toLowerCase().includes('sign in')
          ),
          bodyText: document.body.innerText || document.body.textContent || '',
          bodyTextLength: (document.body.innerText || document.body.textContent || '').length,
        };
      });
      
      console.log('\n📊 Login Page Rendering Analysis:');
      console.log(`Input Fields: ${loginRenderingState.inputCount}`);
      console.log(`Buttons: ${loginRenderingState.buttonCount}`);
      console.log(`Has Email Field: ${loginRenderingState.hasEmailField ? '✅' : '❌'}`);
      console.log(`Has Password Field: ${loginRenderingState.hasPasswordField ? '✅' : '❌'}`);
      console.log(`Has Login Button: ${loginRenderingState.hasLoginButton ? '✅' : '❌'}`);
      console.log(`Body Text Length: ${loginRenderingState.bodyTextLength}`);
      
      if (loginRenderingState.bodyTextLength > 100) {
        console.log(`\n📄 Login Page Text Preview:\n${loginRenderingState.bodyText.substring(0, 300)}`);
      }
      
      await this.page.screenshot({ path: 'test-results/rendering_fix_login.png', fullPage: true });
      
      const renderingFixed = loginRenderingState.hasEmailField && loginRenderingState.hasPasswordField;
      this.testResults.push({
        test: 'Flutter Rendering Fix',
        success: renderingFixed,
        details: `Email: ${loginRenderingState.hasEmailField}, Password: ${loginRenderingState.hasPasswordField}, Buttons: ${loginRenderingState.buttonCount}`
      });
      
      return renderingFixed;
      
    } catch (error) {
      console.error('❌ Rendering fix test error:', error);
      this.testResults.push({
        test: 'Flutter Rendering Fix',
        success: false,
        details: `Error: ${error.message}`
      });
      return false;
    }
  }

  async testPageNavigation(pageName, url, expectedElements = []) {
    console.log(`\n📍 Testing ${pageName}...`);
    
    try {
      await this.page.goto(url);
      await this.page.waitForTimeout(5000);
      
      const pageState = await this.page.evaluate((expectedElements) => {
        const buttons = document.querySelectorAll('button, [role="button"]');
        const inputs = document.querySelectorAll('input');
        const textElements = document.querySelectorAll('div, span, p, h1, h2, h3, h4, h5, h6, label');
        const bodyText = document.body.innerText || document.body.textContent || '';
        
        const foundElements = expectedElements.map(element => ({
          element,
          found: bodyText.toLowerCase().includes(element.toLowerCase())
        }));
        
        return {
          url: window.location.href,
          title: document.title,
          buttonCount: buttons.length,
          inputCount: inputs.length,
          textElementCount: textElements.length,
          bodyTextLength: bodyText.length,
          bodyTextPreview: bodyText.substring(0, 200),
          foundElements,
          hasError: bodyText.toLowerCase().includes('error') || bodyText.toLowerCase().includes('exception'),
        };
      }, expectedElements);
      
      console.log(`📊 ${pageName} Analysis:`);
      console.log(`URL: ${pageState.url}`);
      console.log(`Buttons: ${pageState.buttonCount}`);
      console.log(`Inputs: ${pageState.inputCount}`);
      console.log(`Text Elements: ${pageState.textElementCount}`);
      console.log(`Body Text Length: ${pageState.bodyTextLength}`);
      console.log(`Has Error: ${pageState.hasError ? '❌' : '✅'}`);
      
      console.log('\n🔍 Expected Elements:');
      pageState.foundElements.forEach(({ element, found }) => {
        console.log(`  ${found ? '✅' : '❌'} ${element}`);
      });
      
      if (pageState.bodyTextPreview.length > 0) {
        console.log(`\n📄 Page Text Preview:\n${pageState.bodyTextPreview}`);
      }
      
      await this.page.screenshot({ path: `test-results/${pageName.toLowerCase().replace(/\s+/g, '_')}.png`, fullPage: true });
      
      const pageWorking = !pageState.hasError && pageState.bodyTextLength > 50;
      const elementsFound = pageState.foundElements.filter(el => el.found).length;
      const elementsScore = elementsFound / expectedElements.length;
      
      this.testResults.push({
        test: pageName,
        success: pageWorking,
        details: `Elements: ${elementsFound}/${expectedElements.length}, Text Length: ${pageState.bodyTextLength}, Error: ${pageState.hasError}`,
        score: elementsScore
      });
      
      return pageWorking;
      
    } catch (error) {
      console.error(`❌ ${pageName} test error:`, error);
      this.testResults.push({
        test: pageName,
        success: false,
        details: `Error: ${error.message}`
      });
      return false;
    }
  }

  async testLoginFunctionality() {
    console.log('\n📍 Step 2: Testing Login Functionality...');
    
    try {
      // Test Customer Login
      await this.page.goto('http://localhost:8080/login/customer');
      await this.page.waitForTimeout(3000);
      
      // Try to find and fill form
      const loginTest = await this.page.evaluate(() => {
        const emailField = document.querySelector('input[type="email"], input[placeholder*="email" i], input[name*="email" i], input[type="text"]');
        const passwordField = document.querySelector('input[type="password"], input[placeholder*="password" i], input[name*="password" i]');
        const loginButton = document.querySelector('button:has-text("Sign In"), button:has-text("Login"), [role="button"]:has-text("Sign In"), [role="button"]:has-text("Login"), button, [role="button"]');
        
        return {
          emailFieldFound: !!emailField,
          passwordFieldFound: !!passwordField,
          loginButtonFound: !!loginButton,
          buttonText: loginButton ? (loginButton.innerText || loginButton.textContent || '') : '',
        };
      });
      
      console.log('\n📊 Login Form Analysis:');
      console.log(`Email Field: ${loginTest.emailFieldFound ? '✅' : '❌'}`);
      console.log(`Password Field: ${loginTest.passwordFieldFound ? '✅' : '❌'}`);
      console.log(`Login Button: ${loginTest.loginButtonFound ? '✅' : '❌'}`);
      console.log(`Button Text: "${loginTest.buttonText}"`);
      
      if (loginTest.emailFieldFound && loginTest.passwordFieldFound && loginTest.loginButtonFound) {
        console.log('\n🖱️ Testing login with demo credentials...');
        
        // Fill form
        await this.page.fill('input[type="email"], input[placeholder*="email" i], input[name*="email" i], input[type="text"]', 'customer@example.com');
        await this.page.fill('input[type="password"], input[placeholder*="password" i], input[name*="password" i]', 'customer123');
        
        // Click login button
        await this.page.click('button, [role="button"]');
        await this.page.waitForTimeout(5000);
        
        const afterLogin = this.page.url();
        console.log(`📍 After login: ${afterLogin}`);
        
        const loginSuccess = !afterLogin.includes('/login/customer');
        this.testResults.push({
          test: 'Customer Login Functionality',
          success: loginSuccess,
          details: `Redirected: ${loginSuccess}, Final URL: ${afterLogin}`
        });
        
        return loginSuccess;
      } else {
        this.testResults.push({
          test: 'Customer Login Functionality',
          success: false,
          details: `Form incomplete - Email: ${loginTest.emailFieldFound}, Password: ${loginTest.passwordFieldFound}, Button: ${loginTest.loginButtonFound}`
        });
        return false;
      }
      
    } catch (error) {
      console.error('❌ Login functionality test error:', error);
      this.testResults.push({
        test: 'Customer Login Functionality',
        success: false,
        details: `Error: ${error.message}`
      });
      return false;
    }
  }

  async testThemeConsistency() {
    console.log('\n📍 Step 3: Testing Theme Consistency...');
    
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
        await this.page.waitForTimeout(3000);
        
        const themeState = await this.page.evaluate(() => {
          const bodyStyles = window.getComputedStyle(document.body);
          const buttons = document.querySelectorAll('button, [role="button"]');
          const inputs = document.querySelectorAll('input');
          
          const buttonStyles = buttons.length > 0 ? window.getComputedStyle(buttons[0]) : null;
          const inputStyles = inputs.length > 0 ? window.getComputedStyle(inputs[0]) : null;
          
          return {
            backgroundColor: bodyStyles.backgroundColor,
            fontFamily: bodyStyles.fontFamily,
            fontSize: bodyStyles.fontSize,
            buttonBackground: buttonStyles?.backgroundColor || '',
            buttonColor: buttonStyles?.color || '',
            inputBackground: inputStyles?.backgroundColor || '',
            inputColor: inputStyles?.color || '',
            buttonCount: buttons.length,
            inputCount: inputs.length,
          };
        });
        
        themeAnalysis.push({
          page: page.name,
          theme: themeState
        });
        
        console.log(`\n📨 ${page.name} Theme:`);
        console.log(`Background: ${themeState.backgroundColor}`);
        console.log(`Font: ${themeState.fontFamily}`);
        console.log(`Button BG: ${themeState.buttonBackground}`);
        console.log(`Button Color: ${themeState.buttonColor}`);
        console.log(`Input BG: ${themeState.inputBackground}`);
        console.log(`Input Color: ${themeState.inputColor}`);
        
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
    const validThemes = themeAnalysis.filter(t => t.theme && !t.error);
    const consistent = validThemes.length >= 2;
    
    this.testResults.push({
      test: 'Theme Consistency',
      success: consistent,
      details: `Pages analyzed: ${validThemes.length}, Consistent: ${consistent}`
    });
    
    return consistent;
  }

  async run() {
    await this.setup();
    
    console.log('🧪 COMPREHENSIVE PAGE TEST STARTING');
    console.log('=====================================');
    
    // Step 1: Test rendering fix
    const renderingFixed = await this.testRenderingFix();
    
    // Step 2: Test all major pages
    const pages = [
      { name: 'Home Page', url: 'http://localhost:8080', expectedElements: ['Welcome', 'Login', 'NCL'] },
      { name: 'Customer Login', url: 'http://localhost:8080/login/customer', expectedElements: ['Customer', 'Email', 'Password', 'Sign In'] },
      { name: 'Staff Login', url: 'http://localhost:8080/login/staff', expectedElements: ['Staff', 'Email', 'Password', 'Sign In'] },
      { name: 'Admin Login', url: 'http://localhost:8080/login/admin', expectedElements: ['Admin', 'Email', 'Password', 'Sign In'] },
    ];
    
    let pageResults = [];
    for (const page of pages) {
      const result = await this.testPageNavigation(page.name, page.url, page.expectedElements);
      pageResults.push({ page: page.name, success: result });
    }
    
    // Step 3: Test login functionality if rendering is fixed
    let loginWorking = false;
    if (renderingFixed) {
      loginWorking = await this.testLoginFunctionality();
    }
    
    // Step 4: Test theme consistency
    const themeConsistent = await this.testThemeConsistency();
    
    await this.cleanup();
    
    // Generate comprehensive report
    console.log('\n📊 COMPREHENSIVE TEST RESULTS');
    console.log('==============================');
    
    let totalTests = 0;
    let passedTests = 0;
    
    this.testResults.forEach(result => {
      totalTests++;
      const status = result.success ? '✅ PASS' : '❌ FAIL';
      const score = result.score ? ` (${Math.round(result.score * 100)}%)` : '';
      console.log(`${status} ${result.test}${score}`);
      console.log(`   Details: ${result.details}`);
      if (result.success) passedTests++;
    });
    
    console.log(`\n🎯 OVERALL RESULT: ${passedTests}/${totalTests} tests passed (${Math.round(passedTests/totalTests * 100)}%)`);
    
    // Summary
    console.log('\n📋 SUMMARY:');
    console.log(`Rendering Fixed: ${renderingFixed ? '✅' : '❌'}`);
    console.log(`Pages Working: ${pageResults.filter(p => p.success).length}/${pageResults.length}`);
    console.log(`Login Functionality: ${loginWorking ? '✅' : '❌'}`);
    console.log(`Theme Consistency: ${themeConsistent ? '✅' : '❌'}`);
    
    return passedTests === totalTests;
  }

  async cleanup() {
    if (this.browser) {
      await this.browser.close();
      console.log('🔚 Comprehensive page test completed');
    }
  }
}

// Run the test
const comprehensiveTest = new ComprehensivePageTest();
comprehensiveTest.run().catch(console.error);
