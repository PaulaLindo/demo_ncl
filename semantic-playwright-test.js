const { chromium, firefox, webkit } = require('playwright');

class SemanticUITestSuite {
  constructor() {
    this.browsers = ['chromium', 'firefox', 'webkit'];
    this.testPort = 8082;
    this.baseUrl = `http://localhost:${this.testPort}`;
    this.results = {
      web: {},
      mobile: {},
      desktop: {}
    };
  }

  // Helper method to check server status
  async checkServerStatus() {
    try {
      const response = await fetch(this.baseUrl);
      return response.ok;
    } catch (error) {
      console.log('❌ Server check failed:', error.message);
      return false;
    }
  }

  // Helper method to wait for Flutter app to load
  async waitForFlutterApp(page, timeout = 30000) {
    console.log('⏳ Waiting for Flutter app to fully load...');
    
    try {
      // Wait for the page to be ready
      await page.waitForLoadState('domcontentloaded', { timeout });
      
      // Wait for Flutter-specific indicators
      await page.waitForTimeout(8000);
      
      // Check for Flutter app initialization
      const isAppReady = await page.evaluate(() => {
        return window.flutter || document.querySelector('flutter-view') || 
               document.querySelector('canvas') || 
               document.body.innerText.length > 50;
      });
      
      if (isAppReady) {
        console.log('✅ Flutter app appears to be loaded');
        return true;
      } else {
        console.log('⚠️ Flutter app may not be fully loaded');
        return false;
      }
    } catch (error) {
      console.log('❌ Error waiting for Flutter app:', error.message);
      return false;
    }
  }

  // Test login chooser screen using semantic labels
  async testLoginChooserWithSemantics(page, browserName) {
    console.log(`🔍 Testing login chooser screen with semantics on ${browserName}...`);
    
    const results = {
      foundWelcome: false,
      foundCustomerLogin: false,
      foundStaffLogin: false,
      foundAdminLogin: false,
      canInteract: false,
      screenshots: []
    };

    try {
      // Take initial screenshot
      await page.screenshot({ 
        path: `test-results/${browserName}-semantic-initial.png`, 
        fullPage: true 
      });
      results.screenshots.push('initial');

      // Look for elements using semantic labels
      const semanticSelectors = {
        welcome: '[aria-label="Welcome to NCL"]',
        customer: '[aria-label="Customer Login Button"]',
        staff: '[aria-label="Staff Access Button"]',
        admin: '[aria-label="Admin Portal Button"]'
      };

      for (const [key, selector] of Object.entries(semanticSelectors)) {
        try {
          const element = page.locator(selector).first();
          if (await element.isVisible({ timeout: 3000 })) {
            console.log(`✅ Found ${key} element: ${selector}`);
            results[`found${key.charAt(0).toUpperCase() + key.slice(1)}`] = true;
          } else {
            console.log(`❌ ${key} element not visible: ${selector}`);
          }
        } catch (e) {
          console.log(`❌ ${key} element not found: ${selector}`);
        }
      }

      // Test interaction - try to click customer login button
      if (results.foundCustomerLogin) {
        try {
          await page.locator('[aria-label="Customer Login Button"]').first().click();
          await page.waitForTimeout(2000);
          
          // Check if URL changed or new content appeared
          const currentUrl = page.url();
          if (currentUrl.includes('/login/customer') || currentUrl !== this.baseUrl) {
            results.canInteract = true;
            console.log('✅ Successfully interacted with Customer Login button');
          }
        } catch (e) {
          console.log('❌ Failed to interact with Customer Login button:', e.message);
        }
      }

      // Take final screenshot
      await page.screenshot({ 
        path: `test-results/${browserName}-semantic-final.png`, 
        fullPage: true 
      });
      results.screenshots.push('final');

    } catch (error) {
      console.log(`❌ Error testing login chooser on ${browserName}:`, error.message);
      results.error = error.message;
    }

    return results;
  }

  // Alternative method: Use accessibility tree
  async testWithAccessibilityTree(page, browserName) {
    console.log(`🔍 Testing with accessibility tree on ${browserName}...`);
    
    try {
      // Get accessibility tree
      const accessibilityTree = await page.accessibility.snapshot();
      console.log('📊 Accessibility tree depth:', this.getTreeDepth(accessibilityTree));
      
      // Look for semantic labels in the accessibility tree
      const semanticElements = this.findSemanticElements(accessibilityTree);
      console.log('📊 Found semantic elements:', semanticElements.length);
      
      return {
        semanticElements: semanticElements,
        hasWelcome: semanticElements.some(el => el.name?.includes('Welcome to NCL')),
        hasCustomerLogin: semanticElements.some(el => el.name?.includes('Customer Login')),
        hasStaffAccess: semanticElements.some(el => el.name?.includes('Staff Access')),
        hasAdminPortal: semanticElements.some(el => el.name?.includes('Admin Portal'))
      };
    } catch (error) {
      console.log('❌ Error with accessibility tree:', error.message);
      return { error: error.message };
    }
  }

  getTreeDepth(node, depth = 0) {
    if (!node.children || node.children.length === 0) return depth;
    return Math.max(...node.children.map(child => this.getTreeDepth(child, depth + 1)));
  }

  findSemanticElements(node, results = []) {
    if (node.name && node.role) {
      results.push({
        name: node.name,
        role: node.role,
        description: node.description
      });
    }
    if (node.children) {
      node.children.forEach(child => this.findSemanticElements(child, results));
    }
    return results;
  }

  // Run tests on a specific browser
  async runBrowserTest(browserName) {
    console.log(`🚀 Starting tests on ${browserName}...`);
    
    const browser = await { chromium, firefox, webkit }[browserName].launch();
    const context = await browser.newContext();
    const page = await context.newPage();
    
    try {
      // Navigate to the app
      console.log(`🌐 Navigating to ${this.baseUrl}...`);
      await page.goto(this.baseUrl);
      
      // Wait for Flutter app to load
      const isAppReady = await this.waitForFlutterApp(page);
      if (!isAppReady) {
        throw new Error('Flutter app failed to load');
      }

      // Test with semantic labels
      const semanticResults = await this.testLoginChooserWithSemantics(page, browserName);
      
      // Test with accessibility tree
      const accessibilityResults = await this.testWithAccessibilityTree(page, browserName);
      
      return {
        browser: browserName,
        tests: {
          loginChooser: semanticResults,
          accessibility: accessibilityResults
        },
        success: semanticResults.foundWelcome && semanticResults.foundCustomerLogin
      };
      
    } catch (error) {
      console.log(`❌ Test failed on ${browserName}:`, error.message);
      return {
        browser: browserName,
        error: error.message,
        success: false
      };
    } finally {
      await browser.close();
    }
  }

  // Run all tests
  async runAllTests() {
    console.log('🎯 Starting Semantic UI Test Suite for NCL App');
    console.log(`📍 Testing on: ${this.baseUrl}`);
    
    // Check if server is running
    const serverRunning = await this.checkServerStatus();
    if (!serverRunning) {
      console.log('❌ Server is not running. Please start the Flutter app first.');
      return;
    }
    
    console.log('✅ Server is running. Starting tests...\n');

    // Run tests on all browsers
    for (const browserName of this.browsers) {
      const result = await this.runBrowserTest(browserName);
      this.results.web[browserName] = result;
      
      // Add delay between browsers
      await new Promise(resolve => setTimeout(resolve, 2000));
    }

    // Generate report
    this.generateReport();
  }

  // Generate test report
  generateReport() {
    console.log('\n📊 SEMANTIC UI TEST RESULTS REPORT');
    console.log('==================================================\n');

    let totalTests = 0;
    let passedTests = 0;

    Object.entries(this.results.web).forEach(([browser, result]) => {
      totalTests++;
      console.log(`🌐 ${browser.toUpperCase()} RESULTS:`);
      
      if (result.error) {
        console.log(`❌ Overall: FAILED`);
        console.log(`  ❌ Error: ${result.error}`);
      } else if (result.success) {
        console.log(`✅ Overall: PASSED`);
        passedTests++;
      } else {
        console.log(`❌ Overall: FAILED`);
      }

      if (result.tests?.loginChooser) {
        const login = result.tests.loginChooser;
        console.log(`  📱 Login Chooser (Semantic):`);
        console.log(`    - Welcome text: ${login.foundWelcome ? '✅' : '❌'}`);
        console.log(`    - Customer login: ${login.foundCustomerLogin ? '✅' : '❌'}`);
        console.log(`    - Staff login: ${login.foundStaffLogin ? '✅' : '❌'}`);
        console.log(`    - Admin login: ${login.foundAdminLogin ? '✅' : '❌'}`);
        console.log(`    - Can interact: ${login.canInteract ? '✅' : '❌'}`);
        console.log(`    - Screenshots: ${login.screenshots.join(', ')}`);
      }

      if (result.tests?.accessibility) {
        const acc = result.tests.accessibility;
        console.log(`  📱 Accessibility Tree:`);
        console.log(`    - Semantic elements: ${acc.semanticElements?.length || 0}`);
        console.log(`    - Welcome found: ${acc.hasWelcome ? '✅' : '❌'}`);
        console.log(`    - Customer login found: ${acc.hasCustomerLogin ? '✅' : '❌'}`);
        console.log(`    - Staff access found: ${acc.hasStaffAccess ? '✅' : '❌'}`);
        console.log(`    - Admin portal found: ${acc.hasAdminPortal ? '✅' : '❌'}`);
      }

      console.log('');
    });

    console.log('📈 SUMMARY:');
    console.log(`Total browsers tested: ${totalTests}`);
    console.log(`Passed: ${passedTests}/${totalTests}`);
    console.log(`Success rate: ${Math.round((passedTests / totalTests) * 100)}%`);
    
    if (passedTests === totalTests) {
      console.log('🎉 ALL TESTS PASSED: Semantic UI working correctly!');
    } else if (passedTests > 0) {
      console.log('⚠️ PARTIAL SUCCESS: Some tests passed, review failures.');
    } else {
      console.log('❌ ALL TESTS FAILED: Semantic UI needs attention.');
    }

    console.log('\n📸 Screenshots saved in test-results/ directory');
  }
}

// Run the tests
const testSuite = new SemanticUITestSuite();
testSuite.runAllTests().catch(console.error);
