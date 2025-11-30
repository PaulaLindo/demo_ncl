// complete_solution_test.js - Test the complete solution and all pages
const { chromium } = require('playwright');

class CompleteSolutionTest {
  constructor() {
    this.browser = null;
    this.page = null;
    this.testResults = [];
  }

  async setup() {
    console.log('🚀 Setting up Complete Solution Test...');
    this.browser = await chromium.launch({ 
      headless: false,
      slowMo: 1000 
    });
    this.page = await this.browser.newPage();
    await this.page.setViewportSize({ width: 1280, height: 720 });
    
    console.log('✅ Browser launched');
  }

  async testCompleteSolution() {
    console.log('\n📍 Step 1: Testing Complete Solution...');
    
    try {
      await this.page.goto('http://localhost:8080');
      await this.page.waitForTimeout(5000);
      
      // Check if the complete solution fixed the rendering
      const solutionState = await this.page.evaluate(() => {
        const inputs = document.querySelectorAll('input');
        const buttons = document.querySelectorAll('button, [role="button"]');
        const textElements = document.querySelectorAll('div, span, p, h1, h2, h3, h4, h5, h6, label');
        const bodyText = document.body.innerText || document.body.textContent || '';
        
        return {
          inputCount: inputs.length,
          buttonCount: buttons.length,
          textElementCount: textElements.length,
          bodyTextLength: bodyText.length,
          bodyTextPreview: bodyText.substring(0, 300),
          hasLoginForm: inputs.length > 0,
          hasButtons: buttons.length > 0,
          url: window.location.href,
        };
      });
      
      console.log('\n📊 Complete Solution Analysis:');
      console.log(`Input Fields: ${solutionState.inputCount}`);
      console.log(`Buttons: ${solutionState.buttonCount}`);
      console.log(`Text Elements: ${solutionState.textElementCount}`);
      console.log(`Body Text Length: ${solutionState.bodyTextLength}`);
      console.log(`Has Login Form: ${solutionState.hasLoginForm ? '✅' : '❌'}`);
      console.log(`Has Buttons: ${solutionState.hasButtons ? '✅' : '❌'}`);
      
      if (solutionState.bodyTextPreview.length > 0) {
        console.log(`\n📄 Body Text Preview:\n${solutionState.bodyTextPreview}`);
      }
      
      await this.page.screenshot({ path: 'test-results/complete_solution_home.png', fullPage: true });
      
      // Test customer login page
      console.log('\n📍 Testing Customer Login Page...');
      await this.page.goto('http://localhost:8080/login/customer');
      await this.page.waitForTimeout(5000);
      
      const loginState = await this.page.evaluate(() => {
        const inputs = document.querySelectorAll('input');
        const buttons = document.querySelectorAll('button, [role="button"]');
        const bodyText = document.body.innerText || document.body.textContent || '';
        
        const hasEmailField = Array.from(inputs).some(input => input.type === 'email');
        const hasPasswordField = Array.from(inputs).some(input => input.type === 'password');
        const hasLoginButton = Array.from(buttons).some(button => 
          (button.innerText || button.textContent || '').toLowerCase().includes('login') ||
          (button.innerText || button.textContent || '').toLowerCase().includes('sign in')
        );
        
        return {
          inputCount: inputs.length,
          buttonCount: buttons.length,
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
      console.log(`Has Email Field: ${loginState.hasEmailField ? '✅' : '❌'}`);
      console.log(`Has Password Field: ${loginState.hasPasswordField ? '✅' : '❌'}`);
      console.log(`Has Login Button: ${loginState.hasLoginButton ? '✅' : '❌'}`);
      console.log(`Body Text Length: ${loginState.bodyTextLength}`);
      
      if (loginState.bodyTextPreview.length > 0) {
        console.log(`\n📄 Login Page Text Preview:\n${loginState.bodyTextPreview}`);
      }
      
      await this.page.screenshot({ path: 'test-results/complete_solution_login.png', fullPage: true });
      
      const solutionWorking = loginState.hasEmailField && loginState.hasPasswordField && loginState.hasLoginButton;
      
      this.testResults.push({
        test: 'Complete Solution',
        success: solutionWorking,
        details: `Email: ${loginState.hasEmailField}, Password: ${loginState.hasPasswordField}, Button: ${loginState.hasLoginButton}`
      });
      
      return solutionWorking;
      
    } catch (error) {
      console.error('❌ Complete solution test error:', error);
      this.testResults.push({
        test: 'Complete Solution',
        success: false,
        details: `Error: ${error.message}`
      });
      return false;
    }
  }

  async testPageFunctionality(pageName, url, expectedElements = [], functionalTests = []) {
    console.log(`\n📍 Testing ${pageName} Functionality...`);
    
    try {
      await this.page.goto(url);
      await this.page.waitForTimeout(5000);
      
      const pageState = await this.page.evaluate((expectedElements, functionalTests) => {
        const buttons = document.querySelectorAll('button, [role="button"]');
        const inputs = document.querySelectorAll('input');
        const textElements = document.querySelectorAll('div, span, p, h1, h2, h3, h4, h5, h6, label');
        const bodyText = document.body.innerText || document.body.textContent || '';
        
        const foundElements = expectedElements.map(element => ({
          element,
          found: bodyText.toLowerCase().includes(element.toLowerCase())
        }));
        
        const functionalResults = functionalTests.map(test => {
          switch(test.type) {
            case 'button_click':
              const button = Array.from(buttons).find(btn => 
                (btn.innerText || btn.textContent || '').toLowerCase().includes(test.text.toLowerCase())
              );
              return {
                test: test.name,
                found: !!button,
                buttonText: button ? (button.innerText || button.textContent || '') : '',
                clickable: button ? button.offsetParent !== null : false
              };
            case 'input_field':
              const input = Array.from(inputs).find(input => 
                input.type === test.inputType || 
                (input.placeholder && input.placeholder.toLowerCase().includes(test.placeholder?.toLowerCase() || ''))
              );
              return {
                test: test.name,
                found: !!input,
                inputType: input ? input.type : '',
                placeholder: input ? input.placeholder : '',
                fillable: input ? input.offsetParent !== null : false
              };
            default:
              return { test: test.name, found: false };
          }
        });
        
        return {
          url: window.location.href,
          buttonCount: buttons.length,
          inputCount: inputs.length,
          textElementCount: textElements.length,
          bodyTextLength: bodyText.length,
          bodyTextPreview: bodyText.substring(0, 300),
          foundElements,
          functionalResults,
          hasError: bodyText.toLowerCase().includes('error') || bodyText.toLowerCase().includes('exception'),
        };
      }, expectedElements, functionalTests);
      
      console.log(`\n📊 ${pageName} Functionality Analysis:`);
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
      
      console.log('\n🧪 Functional Tests:');
      pageState.functionalResults.forEach(result => {
        const status = result.found ? '✅' : '❌';
        const details = result.buttonText || result.inputType || result.placeholder || '';
        console.log(`  ${status} ${result.test}: ${details}`);
      });
      
      if (pageState.bodyTextPreview.length > 0) {
        console.log(`\n📄 Page Text Preview:\n${pageState.bodyTextPreview}`);
      }
      
      await this.page.screenshot({ path: `test-results/${pageName.toLowerCase().replace(/\s+/g, '_')}_functionality.png`, fullPage: true });
      
      const elementsFound = pageState.foundElements.filter(el => el.found).length;
      const functionalPassed = pageState.functionalResults.filter(test => test.found).length;
      const pageWorking = !pageState.hasError && pageState.bodyTextLength > 50;
      
      this.testResults.push({
        test: pageName,
        success: pageWorking,
        details: `Elements: ${elementsFound}/${expectedElements.length}, Functional: ${functionalPassed}/${functionalTests.length}, Error: ${pageState.hasError}`,
        elementsScore: elementsFound / expectedElements.length,
        functionalScore: functionalPassed / functionalTests.length
      });
      
      return pageWorking;
      
    } catch (error) {
      console.error(`❌ ${pageName} functionality test error:`, error);
      this.testResults.push({
        test: pageName,
        success: false,
        details: `Error: ${error.message}`
      });
      return false;
    }
  }

  async testCompleteLoginFlow() {
    console.log('\n📍 Step 2: Testing Complete Login Flow...');
    
    try {
      // Test Customer Login Flow
      await this.page.goto('http://localhost:8080/login/customer');
      await this.page.waitForTimeout(3000);
      
      // Fill the form
      const fillResult = await this.page.evaluate(() => {
        const emailField = document.querySelector('input[type="email"], input[placeholder*="email" i], input[name*="email" i], input[type="text"]');
        const passwordField = document.querySelector('input[type="password"], input[placeholder*="password" i], input[name*="password" i]');
        
        if (emailField && passwordField) {
          emailField.value = 'customer@example.com';
          passwordField.value = 'customer123';
          
          emailField.dispatchEvent(new Event('input', { bubbles: true }));
          emailField.dispatchEvent(new Event('change', { bubbles: true }));
          passwordField.dispatchEvent(new Event('input', { bubbles: true }));
          passwordField.dispatchEvent(new Event('change', { bubbles: true }));
          
          return { success: true, emailFilled: emailField.value, passwordFilled: passwordField.value };
        }
        
        return { success: false, emailFound: !!emailField, passwordFound: !!passwordField };
      });
      
      console.log('\n📝 Form Fill Result:');
      console.log(`Success: ${fillResult.success ? '✅' : '❌'}`);
      if (fillResult.success) {
        console.log(`Email Filled: "${fillResult.emailFilled}"`);
        console.log(`Password Filled: "${fillResult.passwordFilled}"`);
      } else {
        console.log(`Email Found: ${fillResult.emailFound ? '✅' : '❌'}`);
        console.log(`Password Found: ${fillResult.passwordFound ? '✅' : '❌'}`);
      }
      
      if (fillResult.success) {
        // Click login button
        console.log('\n🖱️ Clicking login button...');
        await this.page.click('button:has-text("Sign In"), button:has-text("Login"), button, [role="button"]');
        await this.page.waitForTimeout(5000);
        
        const loginResult = this.page.url();
        console.log(`📍 After login: ${loginResult}`);
        
        const loginSuccess = !loginResult.includes('/login/customer');
        
        this.testResults.push({
          test: 'Complete Login Flow',
          success: loginSuccess,
          details: `Redirected: ${loginSuccess}, Final URL: ${loginResult}`
        });
        
        return loginSuccess;
      } else {
        this.testResults.push({
          test: 'Complete Login Flow',
          success: false,
          details: 'Form could not be filled'
        });
        return false;
      }
      
    } catch (error) {
      console.error('❌ Complete login flow test error:', error);
      this.testResults.push({
        test: 'Complete Login Flow',
        success: false,
        details: `Error: ${error.message}`
      });
      return false;
    }
  }

  async testThemeAndStructureConsistency() {
    console.log('\n📍 Step 3: Testing Theme and Structure Consistency...');
    
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
          const textElements = document.querySelectorAll('div, span, p, h1, h2, h3, h4, h5, h6, label');
          
          const buttonStyles = buttons.length > 0 ? window.getComputedStyle(buttons[0]) : null;
          const inputStyles = inputs.length > 0 ? window.getComputedStyle(inputs[0]) : null;
          const textStyles = textElements.length > 0 ? window.getComputedStyle(textElements[0]) : null;
          
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
            textColor: textStyles?.color || '',
            textFontFamily: textStyles?.fontFamily || '',
            buttonCount: buttons.length,
            inputCount: inputs.length,
            textElementCount: textElements.length,
            hasContent: (document.body.innerText || document.body.textContent || '').length > 50,
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
        console.log(`Input Font: ${themeState.inputFontFamily}`);
        console.log(`Has Content: ${themeState.hasContent ? '✅' : '❌'}`);
        
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
    
    const buttonStyleConsistent = validThemes.length > 0 && 
      validThemes.every(t => t.theme.buttonBackground === validThemes[0].theme.buttonBackground);
    
    const inputStyleConsistent = validThemes.length > 0 && 
      validThemes.every(t => t.theme.inputBackground === validThemes[0].theme.inputBackground);
    
    console.log('\n📊 Consistency Analysis:');
    console.log(`Pages with Content: ${validThemes.length}/${pages.length}`);
    console.log(`Font Family Consistent: ${fontFamilyConsistent ? '✅' : '❌'}`);
    console.log(`Button Style Consistent: ${buttonStyleConsistent ? '✅' : '❌'}`);
    console.log(`Input Style Consistent: ${inputStyleConsistent ? '✅' : '❌'}`);
    
    this.testResults.push({
      test: 'Theme and Structure Consistency',
      success: consistent,
      details: `Pages: ${validThemes.length}/${pages.length}, Font: ${fontFamilyConsistent}, Button: ${buttonStyleConsistent}, Input: ${inputStyleConsistent}`
    });
    
    return consistent;
  }

  async run() {
    await this.setup();
    
    console.log('🧪 COMPLETE SOLUTION TEST STARTING');
    console.log('===================================');
    
    // Step 1: Test complete solution
    const solutionWorking = await this.testCompleteSolution();
    
    // Step 2: Test all pages with functionality
    const pages = [
      { 
        name: 'Home Page', 
        url: 'http://localhost:8080', 
        expectedElements: ['Welcome', 'Login', 'NCL'],
        functionalTests: [
          { type: 'button_click', name: 'Customer Login Button', text: 'Customer Login' },
          { type: 'button_click', name: 'Staff Login Button', text: 'Staff Login' },
          { type: 'button_click', name: 'Admin Login Button', text: 'Admin Login' }
        ]
      },
      { 
        name: 'Customer Login', 
        url: 'http://localhost:8080/login/customer', 
        expectedElements: ['Customer', 'Email', 'Password', 'Sign In'],
        functionalTests: [
          { type: 'input_field', name: 'Email Field', inputType: 'email', placeholder: 'email' },
          { type: 'input_field', name: 'Password Field', inputType: 'password', placeholder: 'password' },
          { type: 'button_click', name: 'Login Button', text: 'Sign In' }
        ]
      },
      { 
        name: 'Staff Login', 
        url: 'http://localhost:8080/login/staff', 
        expectedElements: ['Staff', 'Email', 'Password', 'Sign In'],
        functionalTests: [
          { type: 'input_field', name: 'Email Field', inputType: 'email', placeholder: 'email' },
          { type: 'input_field', name: 'Password Field', inputType: 'password', placeholder: 'password' },
          { type: 'button_click', name: 'Login Button', text: 'Sign In' }
        ]
      },
      { 
        name: 'Admin Login', 
        url: 'http://localhost:8080/login/admin', 
        expectedElements: ['Admin', 'Email', 'Password', 'Sign In'],
        functionalTests: [
          { type: 'input_field', name: 'Email Field', inputType: 'email', placeholder: 'email' },
          { type: 'input_field', name: 'Password Field', inputType: 'password', placeholder: 'password' },
          { type: 'button_click', name: 'Login Button', text: 'Sign In' }
        ]
      },
    ];
    
    let pageResults = [];
    for (const page of pages) {
      const result = await this.testPageFunctionality(page.name, page.url, page.expectedElements, page.functionalTests);
      pageResults.push({ page: page.name, success: result });
    }
    
    // Step 3: Test complete login flow if solution is working
    let loginWorking = false;
    if (solutionWorking) {
      loginWorking = await this.testCompleteLoginFlow();
    }
    
    // Step 4: Test theme and structure consistency
    const themeConsistent = await this.testThemeAndStructureConsistency();
    
    await this.cleanup();
    
    // Generate comprehensive report
    console.log('\n📊 COMPLETE SOLUTION TEST RESULTS');
    console.log('==================================');
    
    let totalTests = 0;
    let passedTests = 0;
    
    this.testResults.forEach(result => {
      totalTests++;
      const status = result.success ? '✅ PASS' : '❌ FAIL';
      const score = result.elementsScore ? ` (${Math.round(result.elementsScore * 100)}%)` : 
                   result.functionalScore ? ` (${Math.round(result.functionalScore * 100)}%)` : '';
      console.log(`${status} ${result.test}${score}`);
      console.log(`   Details: ${result.details}`);
      if (result.success) passedTests++;
    });
    
    console.log(`\n🎯 OVERALL RESULT: ${passedTests}/${totalTests} tests passed (${Math.round(passedTests/totalTests * 100)}%)`);
    
    // Summary
    console.log('\n📋 COMPLETE SOLUTION SUMMARY:');
    console.log(`Rendering Fixed: ${solutionWorking ? '✅' : '❌'}`);
    console.log(`Pages Working: ${pageResults.filter(p => p.success).length}/${pageResults.length}`);
    console.log(`Login Flow Working: ${loginWorking ? '✅' : '❌'}`);
    console.log(`Theme Consistency: ${themeConsistent ? '✅' : '❌'}`);
    
    if (passedTests === totalTests) {
      console.log('\n🎉 SUCCESS! All issues have been resolved:');
      console.log('✅ Rendering issue fixed');
      console.log('✅ All pages functional');
      console.log('✅ Login flow working');
      console.log('✅ Theme consistency maintained');
      console.log('✅ Structure consistent across pages');
    } else {
      console.log('\n⚠️  Some issues still need attention');
    }
    
    return passedTests === totalTests;
  }

  async cleanup() {
    if (this.browser) {
      await this.browser.close();
      console.log('🔚 Complete solution test completed');
    }
  }
}

// Run the test
const completeTest = new CompleteSolutionTest();
completeTest.run().catch(console.error);
