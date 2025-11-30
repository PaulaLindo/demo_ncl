// simple_login_test.js - Simple test to verify basic login functionality
const { chromium } = require('playwright');

class SimpleLoginTest {
  constructor() {
    this.browser = null;
    this.page = null;
  }

  async setup() {
    console.log('🚀 Setting up Simple Login Test...');
    this.browser = await chromium.launch({ 
      headless: false,
      slowMo: 2000 
    });
    this.page = await this.browser.newPage();
    await this.page.setViewportSize({ width: 1280, height: 720 });
    console.log('✅ Browser launched');
  }

  async testBasicLogin() {
    try {
      console.log('📍 Navigating to app...');
      await this.page.goto('http://localhost:8080');
      
      // Wait for page to load
      await this.page.waitForTimeout(10000);
      
      // Take screenshot to see what's loaded
      await this.page.screenshot({ path: 'test-results/simple_test_initial.png', fullPage: true });
      
      // Try to find any text content
      const pageContent = await this.page.evaluate(() => {
        return {
          title: document.title,
          bodyText: document.body.innerText,
          allButtons: Array.from(document.querySelectorAll('button')).map(btn => btn.innerText),
          allText: document.body.innerText.toLowerCase(),
        };
      });
      
      console.log('📄 Page Analysis:');
      console.log(`Title: ${pageContent.title}`);
      console.log(`Body text length: ${pageContent.bodyText.length}`);
      console.log(`Buttons found: ${pageContent.allButtons.length}`);
      console.log(`Buttons: ${pageContent.allButtons.join(', ')}`);
      
      // Look for login-related text
      const hasLoginText = pageContent.allText.includes('login') || 
                          pageContent.allText.includes('sign in') ||
                          pageContent.allText.includes('customer') ||
                          pageContent.allText.includes('staff') ||
                          pageContent.allText.includes('admin');
      
      console.log(`Has login-related text: ${hasLoginText}`);
      
      if (hasLoginText) {
        console.log('✅ Login elements detected!');
        
        // Try to click on customer-related elements
        if (pageContent.allText.includes('customer')) {
          console.log('🖱️ Trying to click customer login...');
          
          // Try multiple approaches to find customer login
          const customerSelectors = [
            'text=Customer',
            'text=customer',
            'button:has-text("Customer")',
            '*:has-text("Customer")',
            '[role="button"]:has-text("Customer")'
          ];
          
          for (const selector of customerSelectors) {
            try {
              const element = await this.page.$(selector);
              if (element) {
                console.log(`✅ Found customer element with selector: ${selector}`);
                await element.click();
                await this.page.waitForTimeout(3000);
                
                // Check if we're on a login page
                const hasEmailField = await this.page.$('input[type="email"], input[placeholder*="email" i]');
                const hasPasswordField = await this.page.$('input[type="password"], input[placeholder*="password" i]');
                
                if (hasEmailField && hasPasswordField) {
                  console.log('✅ Login form detected!');
                  
                  // Fill the form
                  await hasEmailField.fill('customer@example.com');
                  await hasPasswordField.fill('customer123');
                  
                  // Find and click login button
                  const loginButton = await this.page.$('button:has-text("Sign In"), button:has-text("Login"), input[type="submit"]');
                  if (loginButton) {
                    await loginButton.click();
                    await this.page.waitForTimeout(5000);
                    
                    // Check if login was successful
                    const currentUrl = this.page.url();
                    const hasDashboard = await this.page.$('text=Book, text=Dashboard, text=Services, text=Account');
                    
                    console.log(`📍 After login: ${currentUrl}`);
                    console.log(`📊 Dashboard detected: ${hasDashboard ? 'Yes' : 'No'}`);
                    
                    await this.page.screenshot({ path: 'test-results/simple_test_login_success.png', fullPage: true });
                    
                    return true;
                  }
                }
                
                await this.page.screenshot({ path: 'test-results/simple_test_after_customer_click.png', fullPage: true });
                break;
              }
            } catch (e) {
              console.log(`⚠️ Error with selector ${selector}: ${e.message}`);
            }
          }
        }
      } else {
        console.log('❌ No login elements found');
        
        // Wait longer and try again
        console.log('⏳ Waiting longer for app to load...');
        await this.page.waitForTimeout(10000);
        
        // Check again
        const newContent = await this.page.evaluate(() => {
          return {
            bodyText: document.body.innerText,
            allButtons: Array.from(document.querySelectorAll('button')).map(btn => btn.innerText),
          };
        });
        
        console.log(`After waiting - Buttons: ${newContent.allButtons.join(', ')}`);
        await this.page.screenshot({ path: 'test-results/simple_test_after_wait.png', fullPage: true });
      }
      
      return false;
      
    } catch (error) {
      console.error('❌ Test error:', error);
      await this.page.screenshot({ path: 'test-results/simple_test_error.png', fullPage: true });
      return false;
    }
  }

  async run() {
    await this.setup();
    const success = await this.testBasicLogin();
    await this.cleanup();
    
    console.log(`\n🎯 Test Result: ${success ? '✅ SUCCESS' : '❌ FAILED'}`);
    return success;
  }

  async cleanup() {
    if (this.browser) {
      await this.browser.close();
      console.log('🔚 Simple login test completed');
    }
  }
}

// Run the test
const simpleTest = new SimpleLoginTest();
simpleTest.run().catch(console.error);
