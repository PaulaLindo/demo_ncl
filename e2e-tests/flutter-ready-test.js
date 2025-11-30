// flutter-ready-test.js - Test that waits for Flutter app to fully load
const { chromium } = require('playwright');

class FlutterReadyTest {
  constructor() {
    this.browser = null;
    this.page = null;
  }

  async setup() {
    console.log('🚀 Setting up Flutter Ready Test...');
    this.browser = await chromium.launch({ 
      headless: false,
      slowMo: 1000 
    });
    this.page = await this.browser.newPage();
    await this.page.setViewportSize({ width: 1280, height: 720 });
    console.log('✅ Browser launched');
  }

  async waitForFlutterApp() {
    console.log('⏳ Waiting for Flutter app to load...');
    
    try {
      // Navigate to the app
      await this.page.goto('http://localhost:8080');
      
      // Wait for various indicators that Flutter has loaded
      const flutterIndicators = [
        () => this.page.waitForSelector('flt-glass-pane', { timeout: 30000 }),
        () => this.page.waitForSelector('flt-semantics-placeholder', { timeout: 30000 }),
        () => this.page.waitForFunction(() => {
          return document.querySelector('flt-glass-pane') || 
                 document.querySelector('[flt-renderer]') ||
                 document.body.innerText.length > 100;
        }, { timeout: 30000 })
      ];
      
      let flutterLoaded = false;
      for (const indicator of flutterIndicators) {
        try {
          await indicator();
          flutterLoaded = true;
          console.log('✅ Flutter app detected');
          break;
        } catch (e) {
          console.log('⏳ Still waiting for Flutter...');
        }
      }
      
      if (!flutterLoaded) {
        console.log('⚠️ Flutter indicators not found, waiting for content...');
        // Wait for any meaningful content
        await this.page.waitForFunction(() => {
          return document.body.innerText.trim().length > 50;
        }, { timeout: 30000 });
      }
      
      // Additional wait for Flutter to render
      await this.page.waitForTimeout(5000);
      
      // Take screenshot to see what's actually loaded
      await this.page.screenshot({ path: 'test-results/flutter_loaded.png', fullPage: true });
      
      // Get page content
      const content = await this.page.evaluate(() => {
        return {
          title: document.title,
          url: window.location.href,
          bodyText: document.body.innerText,
          bodyHTML: document.body.innerHTML.substring(0, 1000),
          allElements: document.querySelectorAll('*').length,
          buttons: document.querySelectorAll('button').length,
          inputs: document.querySelectorAll('input').length,
          fltElements: document.querySelectorAll('[flt-*], flt-*').length
        };
      });
      
      console.log('\n📊 Page Analysis:');
      console.log(`Title: ${content.title}`);
      console.log(`URL: ${content.url}`);
      console.log(`Total elements: ${content.allElements}`);
      console.log(`Buttons: ${content.buttons}`);
      console.log(`Inputs: ${content.inputs}`);
      console.log(`Flutter elements: ${content.fltElements}`);
      console.log(`Body text length: ${content.bodyText.length}`);
      
      if (content.bodyText.length > 0) {
        console.log('\n📄 Body text preview:');
        console.log(content.bodyText.substring(0, 500));
      }
      
      return content;
      
    } catch (error) {
      console.error('❌ Error waiting for Flutter app:', error);
      return null;
    }
  }

  async findLoginButtons(content) {
    console.log('\n🔍 Searching for login buttons...');
    
    if (!content) {
      console.log('❌ No content to search');
      return false;
    }
    
    // Try multiple approaches to find login buttons
    
    // 1. Look for buttons with specific text
    const buttonTexts = ['Customer Login', 'Staff Login', 'Admin Login', 'Customer', 'Staff', 'Admin'];
    
    for (const text of buttonTexts) {
      try {
        // Try different selector strategies
        const selectors = [
          `button:has-text("${text}")`,
          `text=${text}`,
          `[role="button"]:has-text("${text}")`,
          `.btn:has-text("${text}")`,
          `*:has-text("${text}")`
        ];
        
        for (const selector of selectors) {
          const element = await this.page.$(selector);
          if (element) {
            console.log(`✅ Found element with text "${text}" using selector: ${selector}`);
            
            // Try to get more details
            const details = await element.evaluate(el => ({
              tagName: el.tagName,
              text: el.innerText,
              className: el.className,
              id: el.id,
              visible: el.offsetParent !== null
            }));
            
            console.log(`   Details: ${details.tagName} | "${details.text}" | Visible: ${details.visible}`);
            
            // Try clicking it
            await element.click();
            await this.page.waitForTimeout(3000);
            
            const newUrl = this.page.url();
            console.log(`   📍 After click: ${newUrl}`);
            
            // Check if we're on a login page
            const hasLoginFields = await this.page.$('input[type="email"], input[type="password"]');
            if (hasLoginFields) {
              console.log(`   ✅ Login form detected!`);
              await this.page.screenshot({ path: `test-results/login_page_${text.toLowerCase().replace(' ', '_')}.png`, fullPage: true });
              return true;
            }
            
            // Go back for next attempt
            await this.page.goto('http://localhost:8080');
            await this.page.waitForTimeout(2000);
          }
        }
      } catch (error) {
        console.log(`⚠️ Error searching for "${text}": ${error.message}`);
      }
    }
    
    // 2. Look for any clickable elements
    console.log('\n🔍 Checking all clickable elements...');
    try {
      const clickables = await this.page.evaluate(() => {
        const elements = Array.from(document.querySelectorAll('*'));
        return elements
          .filter(el => {
            const text = el.innerText?.trim() || '';
            const style = window.getComputedStyle(el);
            return (
              text.length > 0 &&
              style.cursor !== 'default' &&
              (style.pointerEvents !== 'none' || el.onclick || el.getAttribute('onclick'))
            );
          })
          .map(el => ({
            tagName: el.tagName,
            text: el.innerText?.trim().substring(0, 50),
            className: el.className,
            id: el.id,
            clickable: el.onclick || el.getAttribute('onclick') !== null
          }))
          .slice(0, 20); // Limit to first 20
      });
      
      console.log(`Found ${clickables.length} clickable elements:`);
      clickables.forEach((el, index) => {
        console.log(`${index + 1}. ${el.tagName}: "${el.text}" | Clickable: ${el.clickable}`);
      });
      
      // Try clicking the most promising ones
      for (const element of clickables) {
        if (element.text && (
          element.text.toLowerCase().includes('customer') ||
          element.text.toLowerCase().includes('staff') ||
          element.text.toLowerCase().includes('admin') ||
          element.text.toLowerCase().includes('login')
        )) {
          try {
            console.log(`🖱️ Trying to click: ${element.text}`);
            await this.page.click(`*:has-text("${element.text}")`);
            await this.page.waitForTimeout(3000);
            
            const hasLoginFields = await this.page.$('input[type="email"], input[type="password"]');
            if (hasLoginFields) {
              console.log(`✅ Login form found after clicking ${element.text}`);
              await this.page.screenshot({ path: 'test-results/login_form_found.png', fullPage: true });
              return true;
            }
            
            await this.page.goto('http://localhost:8080');
            await this.page.waitForTimeout(2000);
          } catch (error) {
            console.log(`❌ Error clicking ${element.text}: ${error.message}`);
          }
        }
      }
      
    } catch (error) {
      console.log('❌ Error analyzing clickable elements:', error.message);
    }
    
    return false;
  }

  async testLoginForm() {
    console.log('\n🧪 Testing login form functionality...');
    
    try {
      // Look for email and password fields
      const emailField = await this.page.$('input[type="email"], input[placeholder*="email" i]');
      const passwordField = await this.page.$('input[type="password"], input[placeholder*="password" i]');
      const loginButton = await this.page.$('button:has-text("Sign In"), button:has-text("Login"), input[type="submit"]');
      
      console.log(`📋 Form elements found:`);
      console.log(`   Email field: ${emailField ? '✅' : '❌'}`);
      console.log(`   Password field: ${passwordField ? '✅' : '❌'}`);
      console.log(`   Login button: ${loginButton ? '✅' : '❌'}`);
      
      if (emailField && passwordField && loginButton) {
        // Try filling the form
        await emailField.fill('customer@example.com');
        await passwordField.fill('customer123');
        await this.page.waitForTimeout(1000);
        
        await loginButton.click();
        await this.page.waitForTimeout(5000);
        
        // Check if login was successful
        const currentUrl = this.page.url();
        const dashboardIndicators = await this.page.$$('text=Book, text=Dashboard, text=Overview, text=Schedule');
        
        console.log(`📍 After login: ${currentUrl}`);
        console.log(`📊 Dashboard indicators found: ${dashboardIndicators.length}`);
        
        await this.page.screenshot({ path: 'test-results/login_result.png', fullPage: true });
        
        return dashboardIndicators.length > 0;
      }
      
    } catch (error) {
      console.log('❌ Error testing login form:', error.message);
    }
    
    return false;
  }

  async run() {
    await this.setup();
    
    try {
      const content = await this.waitForFlutterApp();
      const loginFound = await this.findLoginButtons(content);
      
      if (loginFound) {
        const loginSuccess = await this.testLoginForm();
        console.log(`\n🎯 Final Result: ${loginSuccess ? '✅ Login Successful' : '❌ Login Failed'}`);
      } else {
        console.log('\n❌ No login buttons or forms found');
      }
      
    } catch (error) {
      console.error('❌ Test error:', error);
    }
    
    await this.cleanup();
  }

  async cleanup() {
    if (this.browser) {
      await this.browser.close();
      console.log('\n🔚 Flutter Ready test completed');
    }
  }
}

// Run the test
const flutterTest = new FlutterReadyTest();
flutterTest.run().catch(console.error);
