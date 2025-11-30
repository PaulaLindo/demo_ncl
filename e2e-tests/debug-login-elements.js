// debug-login-elements.js - Debug script to identify actual login elements
const { chromium } = require('playwright');

class LoginElementDebugger {
  constructor() {
    this.browser = null;
    this.page = null;
  }

  async setup() {
    console.log('🔍 Setting up Login Element Debugger...');
    this.browser = await chromium.launch({ 
      headless: false,
      slowMo: 1000 
    });
    this.page = await this.browser.newPage();
    await this.page.setViewportSize({ width: 1280, height: 720 });
    console.log('✅ Browser launched');
  }

  async debugPageElements() {
    try {
      await this.page.goto('http://localhost:8080');
      await this.page.waitForTimeout(5000);
      
      console.log('\n🔍 Analyzing page elements...');
      
      // Take a screenshot first
      await this.page.screenshot({ path: 'test-results/debug_initial_page.png', fullPage: true });
      
      // Get all text content
      const allText = await this.page.evaluate(() => {
        return document.body.innerText;
      });
      
      console.log('\n📄 All text content:');
      console.log(allText);
      
      // Get all buttons
      const buttons = await this.page.evaluate(() => {
        const buttons = Array.from(document.querySelectorAll('button'));
        return buttons.map(btn => ({
          text: btn.innerText?.trim(),
          className: btn.className,
          id: btn.id,
          type: btn.type,
          disabled: btn.disabled
        }));
      });
      
      console.log('\n🔘 All buttons found:');
      buttons.forEach((btn, index) => {
        console.log(`${index + 1}. Text: "${btn.text}" | Class: ${btn.className} | ID: ${btn.id} | Type: ${btn.type}`);
      });
      
      // Get all clickable elements
      const clickables = await this.page.evaluate(() => {
        const elements = Array.from(document.querySelectorAll('button, [role="button"], .btn, [onclick]'));
        return elements.map(el => ({
          tagName: el.tagName,
          text: el.innerText?.trim(),
          className: el.className,
          id: el.id,
          role: el.getAttribute('role'),
          clickable: el.onclick || el.getAttribute('onclick') !== null
        }));
      });
      
      console.log('\n👆 All clickable elements:');
      clickables.forEach((el, index) => {
        console.log(`${index + 1}. ${el.tagName}: "${el.text}" | Role: ${el.role} | Class: ${el.className}`);
      });
      
      // Look for specific text patterns
      const textPatterns = ['Customer', 'Staff', 'Admin', 'Login', 'Sign In', 'Welcome'];
      console.log('\n🔍 Searching for specific text patterns:');
      
      for (const pattern of textPatterns) {
        const elements = await this.page.evaluate((searchText) => {
          const elements = Array.from(document.querySelectorAll('*'));
          return elements
            .filter(el => el.innerText && el.innerText.toLowerCase().includes(searchText.toLowerCase()))
            .map(el => ({
              tagName: el.tagName,
              text: el.innerText?.trim(),
              className: el.className,
              id: el.id
            }));
        }, pattern);
        
        if (elements.length > 0) {
          console.log(`✅ Found "${pattern}" in ${elements.length} elements:`);
          elements.forEach((el, index) => {
            console.log(`  ${index + 1}. ${el.tagName}: "${el.text.substring(0, 50)}..."`);
          });
        } else {
          console.log(`❌ No elements found containing "${pattern}"`);
        }
      }
      
      // Try to click on any element that might be a login button
      console.log('\n🖱️ Attempting to identify login buttons by clicking...');
      
      const potentialButtons = buttons.filter(btn => 
        btn.text && (
          btn.text.toLowerCase().includes('customer') ||
          btn.text.toLowerCase().includes('staff') ||
          btn.text.toLowerCase().includes('admin') ||
          btn.text.toLowerCase().includes('login') ||
          btn.text.toLowerCase().includes('sign in')
        )
      );
      
      console.log(`\n🎯 Found ${potentialButtons.length} potential login buttons:`);
      
      for (let i = 0; i < potentialButtons.length; i++) {
        const btn = potentialButtons[i];
        console.log(`${i + 1}. "${btn.text}" - attempting to click...`);
        
        try {
          // Go back to initial page first
          await this.page.goto('http://localhost:8080');
          await this.page.waitForTimeout(2000);
          
          // Try to find and click this button
          const buttonSelector = `button:has-text("${btn.text}")`;
          const button = await this.page.$(buttonSelector);
          
          if (button) {
            await button.click();
            await this.page.waitForTimeout(3000);
            
            // Check if we navigated to a login page
            const currentUrl = this.page.url();
            const hasLoginForm = await this.page.$('input[type="email"], input[type="password"]');
            
            console.log(`   ✅ Clicked! Current URL: ${currentUrl}`);
            console.log(`   📝 Has login form: ${hasLoginForm ? 'Yes' : 'No'}`);
            
            if (hasLoginForm) {
              await this.page.screenshot({ path: `test-results/debug_login_page_${i}.png`, fullPage: true });
              
              // Get form elements
              const formElements = await this.page.evaluate(() => {
                const inputs = Array.from(document.querySelectorAll('input'));
                return inputs.map(input => ({
                  type: input.type,
                  placeholder: input.placeholder,
                  id: input.id,
                  className: input.className,
                  key: input.getAttribute('key')
                }));
              });
              
              console.log(`   📋 Form elements found:`);
              formElements.forEach((el, index) => {
                console.log(`     ${index + 1}. Type: ${el.type} | Placeholder: ${el.placeholder} | Key: ${el.key}`);
              });
            }
          }
        } catch (error) {
          console.log(`   ❌ Error clicking: ${error.message}`);
        }
      }
      
    } catch (error) {
      console.error('❌ Debug error:', error);
    }
  }

  async cleanup() {
    if (this.browser) {
      await this.browser.close();
      console.log('\n🔚 Debug session completed');
    }
  }

  async run() {
    await this.setup();
    await this.debugPageElements();
    await this.cleanup();
  }
}

// Run the debugger
const loginDebugger = new LoginElementDebugger();
loginDebugger.run().catch(console.error);
