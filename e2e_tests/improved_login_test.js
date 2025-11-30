// improved_login_test.js - Fixed login test with proper selectors and validation
const { chromium } = require('playwright');

class ImprovedLoginTest {
  constructor() {
    this.browser = null;
    this.page = null;
    this.testResults = [];
  }

  async setup() {
    console.log('🚀 Setting up Improved Login Test...');
    this.browser = await chromium.launch({ 
      headless: false,
      slowMo: 500 // Slow down actions for better visibility
    });
    this.page = await this.browser.newPage();
    
    // Set viewport
    await this.page.setViewportSize({ width: 1280, height: 720 });
    
    console.log('✅ Browser launched');
  }

  async recordResult(testName, passed, details = '') {
    this.testResults.push({
      test: testName,
      passed: passed,
      details: details,
      timestamp: new Date().toISOString()
    });
    
    const status = passed ? '✅ PASS' : '❌ FAIL';
    console.log(`${status}: ${testName}`);
    if (details) console.log(`   Details: ${details}`);
  }

  async waitForElement(selector, timeout = 10000) {
    try {
      await this.page.waitForSelector(selector, { timeout });
      return await this.page.$(selector);
    } catch (e) {
      console.log(`⚠️ Element not found: ${selector}`);
      return null;
    }
  }

  async waitForText(text, timeout = 10000) {
    try {
      await this.page.waitForSelector(`text=${text}`, { timeout });
      return await this.page.$(`text=${text}`);
    } catch (e) {
      console.log(`⚠️ Text not found: ${text}`);
      return null;
    }
  }

  async clickElement(selector) {
    try {
      await this.page.click(selector);
      await this.page.waitForTimeout(1000);
      return true;
    } catch (e) {
      console.log(`❌ Failed to click: ${selector}`);
      return false;
    }
  }

  async typeText(selector, text) {
    try {
      await this.page.fill(selector, text);
      await this.page.waitForTimeout(500);
      return true;
    } catch (e) {
      console.log(`❌ Failed to type in: ${selector}`);
      return false;
    }
  }

  async takeScreenshot(name) {
    const timestamp = new Date().toISOString().replace(/[:.]/g, '-');
    const filename = `test-results/${name}_${timestamp}.png`;
    await this.page.screenshot({ path: filename, fullPage: true });
    console.log(`📸 Screenshot saved: ${filename}`);
    return filename;
  }

  async testLoginFlow(role) {
    console.log(`\n🧪 Testing ${role} Login Flow`);
    
    try {
      // Step 1: Navigate to app
      await this.page.goto('http://localhost:8080');
      await this.page.waitForTimeout(3000);
      await this.takeScreenshot(`${role}_1_initial_page`);
      
      // Step 2: Look for role selection buttons
      console.log(`🔍 Looking for ${role} login button...`);
      
      const roleButtonSelector = `text=${role.charAt(0).toUpperCase() + role.slice(1)} Login`;
      const roleButton = await this.waitForText(roleButtonSelector);
      
      if (!roleButton) {
        this.recordResult(`${role} Login Button`, false, `${role} login button not found`);
        return false;
      }
      
      await this.clickElement(`text=${roleButtonSelector}`);
      await this.page.waitForTimeout(2000);
      await this.takeScreenshot(`${role}_2_login_page`);
      
      // Step 3: Fill login form
      console.log(`📝 Filling ${role} login form...`);
      
      const credentials = {
        customer: { email: 'customer@example.com', password: 'customer123' },
        staff: { email: 'staff@example.com', password: 'staff123' },
        admin: { email: 'admin@example.com', password: 'admin123' }
      };
      
      const cred = credentials[role];
      
      // Try multiple selectors for email field
      const emailSelectors = [
        'input[placeholder*="email" i]',
        'input[type="email"]',
        '[key="email_field"] input',
        'input:has-text("Email")',
        'input'
      ];
      
      let emailField = null;
      for (const selector of emailSelectors) {
        emailField = await this.waitForElement(selector, 2000);
        if (emailField) {
          console.log(`✅ Found email field with selector: ${selector}`);
          break;
        }
      }
      
      if (!emailField) {
        this.recordResult(`${role} Email Field`, false, 'Email field not found');
        return false;
      }
      
      await this.typeText(emailSelectors.find(s => this.page.$(s)), cred.email);
      
      // Try multiple selectors for password field
      const passwordSelectors = [
        'input[placeholder*="password" i]',
        'input[type="password"]',
        '[key="password_field"] input',
        'input:has-text("Password")'
      ];
      
      let passwordField = null;
      for (const selector of passwordSelectors) {
        passwordField = await this.waitForElement(selector, 2000);
        if (passwordField) {
          console.log(`✅ Found password field with selector: ${selector}`);
          break;
        }
      }
      
      if (!passwordField) {
        this.recordResult(`${role} Password Field`, false, 'Password field not found');
        return false;
      }
      
      await this.typeText(passwordSelectors.find(s => this.page.$(s)), cred.password);
      await this.takeScreenshot(`${role}_3_form_filled`);
      
      // Step 4: Click login button
      console.log(`🔐 Submitting ${role} login...`);
      
      const loginButtonSelectors = [
        'button:has-text("Sign In")',
        'button:has-text("Login")',
        'input[type="submit"]',
        'button',
        '[key="login_button"]'
      ];
      
      let loginButton = null;
      for (const selector of loginButtonSelectors) {
        loginButton = await this.waitForElement(selector, 2000);
        if (loginButton) {
          console.log(`✅ Found login button with selector: ${selector}`);
          break;
        }
      }
      
      if (!loginButton) {
        this.recordResult(`${role} Login Button`, false, 'Login button not found');
        return false;
      }
      
      await this.clickElement(loginButtonSelectors.find(s => this.page.$(s)));
      await this.page.waitForTimeout(3000);
      await this.takeScreenshot(`${role}_4_login_attempt`);
      
      // Step 5: Verify login success
      console.log(`✅ Verifying ${role} login success...`);
      
      // Look for dashboard indicators
      const successIndicators = {
        customer: ['Book', 'Bookings', 'Services', 'Account', 'Home'],
        staff: ['Dashboard', 'Schedule', 'Timekeeping', 'Profile', 'Scheduler'],
        admin: ['Overview', 'Temp Cards', 'Proxy Time', 'Quality Audit', 'Job Assignments']
      };
      
      const indicators = successIndicators[role];
      let loginSuccess = false;
      let foundIndicator = '';
      
      for (const indicator of indicators) {
        const element = await this.waitForText(indicator, 3000);
        if (element) {
          loginSuccess = true;
          foundIndicator = indicator;
          console.log(`✅ Found ${indicator} - login successful!`);
          break;
        }
      }
      
      if (loginSuccess) {
        await this.takeScreenshot(`${role}_5_login_success`);
        this.recordResult(`${role} Login Success`, true, `Found ${foundIndicator} element`);
        return true;
      } else {
        // Check for error messages
        const errorSelectors = [
          'text=Invalid',
          'text=Error',
          'text=Failed',
          '[role="alert"]',
          '.error'
        ];
        
        let errorMessage = '';
        for (const selector of errorSelectors) {
          const errorElement = await this.waitForElement(selector, 1000);
          if (errorElement) {
            errorMessage = await errorElement.textContent();
            break;
          }
        }
        
        await this.takeScreenshot(`${role}_5_login_failed`);
        this.recordResult(`${role} Login Success`, false, errorMessage || 'No dashboard elements found');
        return false;
      }
      
    } catch (error) {
      await this.takeScreenshot(`${role}_error`);
      this.recordResult(`${role} Login Flow`, false, error.message);
      return false;
    }
  }

  async testUIElements() {
    console.log('\n🧪 Testing UI Elements and Centering');
    
    try {
      await this.page.goto('http://localhost:8080');
      await this.page.waitForTimeout(3000);
      
      // Test customer login UI
      const customerButton = await this.waitForText('Customer Login');
      if (customerButton) {
        await this.clickElement('text=Customer Login');
        await this.page.waitForTimeout(2000);
        
        // Check for centered elements
        const emailLabel = await this.waitForElement('text=Email');
        const passwordLabel = await this.waitForElement('text=Password');
        const signInButton = await this.waitForElement('text=Sign In');
        const demoCredentials = await this.waitForElement('text=Demo Credentials');
        
        const uiElementsFound = [
          emailLabel ? 'Email label' : null,
          passwordLabel ? 'Password label' : null,
          signInButton ? 'Sign In button' : null,
          demoCredentials ? 'Demo credentials' : null
        ].filter(Boolean);
        
        await this.takeScreenshot('ui_elements_check');
        
        this.recordResult(
          'UI Elements Check',
          uiElementsFound.length >= 3,
          `Found: ${uiElementsFound.join(', ')}`
        );
        
        // Test auto-fill functionality
        const emailField = await this.waitForElement('input[placeholder*="email" i], input[type="email"]');
        if (emailField) {
          const initialEmail = await emailField.inputValue();
          await this.clickElement('text=customer@example.com');
          await this.page.waitForTimeout(1000);
          const filledEmail = await emailField.inputValue();
          
          const autoFillWorks = filledEmail !== initialEmail && filledEmail.includes('customer');
          this.recordResult(
            'Auto-fill Functionality',
            autoFillWorks,
            autoFillWorks ? 'Email field auto-filled successfully' : 'Auto-fill not working'
          );
        }
      }
      
    } catch (error) {
      this.recordResult('UI Elements Check', false, error.message);
    }
  }

  async testAllLoginFlows() {
    console.log('🎯 Starting Improved Login Test Suite...\n');
    
    await this.setup();
    
    // Test UI elements first
    await this.testUIElements();
    
    // Test each role login
    const roles = ['customer', 'staff', 'admin'];
    const results = {};
    
    for (const role of roles) {
      results[role] = await this.testLoginFlow(role);
      
      // Logout before next test (if possible)
      if (results[role]) {
        try {
          await this.page.goto('http://localhost:8080');
          await this.page.waitForTimeout(2000);
        } catch (e) {
          console.log('⚠️ Could not navigate back to login');
        }
      }
    }
    
    // Generate final report
    this.generateReport(results);
    
    await this.cleanup();
  }

  generateReport(results) {
    console.log('\n📊 IMPROVED LOGIN TEST SUITE REPORT');
    console.log('=====================================');
    
    const passedTests = this.testResults.filter(r => r.passed).length;
    const totalTests = this.testResults.length;
    
    console.log(`Overall Result: ${passedTests}/${totalTests} tests passed`);
    console.log(`Success Rate: ${Math.round((passedTests / totalTests) * 100)}%`);
    console.log('');
    
    this.testResults.forEach(result => {
      const status = result.passed ? '✅ PASS' : '❌ FAIL';
      console.log(`${status} ${result.test}`);
      if (result.details) {
        console.log(`    ${result.details}`);
      }
    });
    
    console.log('\n🔍 Login Flow Results:');
    Object.entries(results).forEach(([role, success]) => {
      const status = success ? '✅' : '❌';
      console.log(`${status} ${role.charAt(0).toUpperCase() + role.slice(1)} Login`);
    });
    
    // Save report to file
    const reportData = {
      summary: {
        total: totalTests,
        passed: passedTests,
        failed: totalTests - passedTests,
        successRate: Math.round((passedTests / totalTests) * 100),
        timestamp: new Date().toISOString()
      },
      results: this.testResults,
      loginResults: results,
      recommendations: this.getRecommendations(results)
    };
    
    require('fs').writeFileSync(
      'test-results/improved_login_test_report.json',
      JSON.stringify(reportData, null, 2)
    );
    
    console.log('\n📄 Detailed report saved to: test-results/improved_login_test_report.json');
    console.log('📸 Screenshots saved in: test-results/ directory');
  }

  getRecommendations(results) {
    const recommendations = [];
    
    if (!results.customer) {
      recommendations.push('Fix customer login flow - check form selectors and validation');
    }
    if (!results.staff) {
      recommendations.push('Fix staff login flow - verify staff dashboard elements');
    }
    if (!results.admin) {
      recommendations.push('Fix admin login flow - check admin navigation elements');
    }
    
    const uiTest = this.testResults.find(r => r.test === 'UI Elements Check');
    if (uiTest && !uiTest.passed) {
      recommendations.push('Improve UI element selectors and accessibility');
    }
    
    const autoFillTest = this.testResults.find(r => r.test === 'Auto-fill Functionality');
    if (autoFillTest && !autoFillTest.passed) {
      recommendations.push('Fix auto-fill functionality for demo credentials');
    }
    
    if (recommendations.length === 0) {
      recommendations.push('All login flows working correctly! Consider adding more comprehensive tests.');
    }
    
    return recommendations;
  }

  async cleanup() {
    if (this.browser) {
      await this.browser.close();
      console.log('\n🔚 Improved Login test suite completed, browser closed');
    }
  }
}

// Run the improved login test suite
const improvedLoginTest = new ImprovedLoginTest();
improvedLoginTest.testAllLoginFlows().catch(console.error);
