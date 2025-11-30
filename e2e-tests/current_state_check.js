// current_state_check.js - Check the current state of login pages
const { chromium } = require('playwright');

class CurrentStateCheck {
  constructor() {
    this.browser = null;
    this.page = null;
  }

  async setup() {
    console.log('🔍 Setting up Current State Check...');
    this.browser = await chromium.launch({ 
      headless: false,
      slowMo: 1000 
    });
    this.page = await this.browser.newPage();
    await this.page.setViewportSize({ width: 1280, height: 720 });
    console.log('✅ Browser launched');
  }

  async checkCurrentState() {
    try {
      console.log('📍 Checking current state of Flutter app...');
      
      // Check home page
      await this.page.goto('http://localhost:8080');
      await this.page.waitForTimeout(5000);
      
      const homeState = await this.page.evaluate(() => {
        return {
          url: window.location.href,
          title: document.title,
          bodyText: document.body.innerText || document.body.textContent || '',
          buttons: Array.from(document.querySelectorAll('button, [role="button"]')).map(btn => ({
            text: btn.innerText || btn.textContent || '',
            visible: btn.offsetParent !== null,
            tagName: btn.tagName,
          })),
          hasLoginForm: !!document.querySelector('input[type="email"], input[type="password"]'),
        };
      });
      
      console.log('\n📊 Home Page State:');
      console.log(`URL: ${homeState.url}`);
      console.log(`Body Text Length: ${homeState.bodyText.length}`);
      console.log(`Buttons: ${homeState.buttons.length}`);
      console.log(`Has Login Form: ${homeState.hasLoginForm}`);
      
      homeState.buttons.forEach((btn, index) => {
        console.log(`  ${index + 1}. ${btn.tagName}: "${btn.text}" | Visible: ${btn.visible}`);
      });
      
      if (homeState.bodyText.length > 0) {
        console.log(`\n📄 Body Text Preview:\n${homeState.bodyText.substring(0, 300)}`);
      }
      
      await this.page.screenshot({ path: 'test-results/current_home_state.png', fullPage: true });
      
      // Check customer login page
      console.log('\n📍 Checking Customer Login page...');
      await this.page.goto('http://localhost:8080/login/customer');
      await this.page.waitForTimeout(5000);
      
      const loginState = await this.page.evaluate(() => {
        const inputs = Array.from(document.querySelectorAll('input')).map(input => ({
          type: input.type,
          placeholder: input.placeholder || '',
          value: input.value || '',
          visible: input.offsetParent !== null,
          styles: {
            display: window.getComputedStyle(input).display,
            visibility: window.getComputedStyle(input).visibility,
            opacity: window.getComputedStyle(input).opacity,
            color: window.getComputedStyle(input).color,
          }
        }));
        
        const buttons = Array.from(document.querySelectorAll('button, [role="button"]')).map(btn => ({
          text: btn.innerText || btn.textContent || '',
          visible: btn.offsetParent !== null,
          tagName: btn.tagName,
          styles: {
            display: window.getComputedStyle(btn).display,
            visibility: window.getComputedStyle(btn).visibility,
            opacity: window.getComputedStyle(btn).opacity,
            color: window.getComputedStyle(btn).color,
            backgroundColor: window.getComputedStyle(btn).backgroundColor,
          }
        }));
        
        const textElements = Array.from(document.querySelectorAll('div, span, p, label, h1, h2, h3, h4, h5, h6')).map(el => ({
          text: el.innerText || el.textContent || '',
          tagName: el.tagName,
          visible: el.offsetParent !== null,
          styles: {
            color: window.getComputedStyle(el).color,
            fontSize: window.getComputedStyle(el).fontSize,
          }
        })).filter(el => el.text.length > 0);
        
        return {
          url: window.location.href,
          bodyText: document.body.innerText || document.body.textContent || '',
          inputs,
          buttons,
          textElements,
          visibleElements: Array.from(document.querySelectorAll('*')).filter(el => {
            const styles = window.getComputedStyle(el);
            return styles.display !== 'none' && 
                   styles.visibility !== 'hidden' && 
                   styles.opacity !== '0' &&
                   el.offsetWidth > 0 && 
                   el.offsetHeight > 0;
          }).length,
        };
      });
      
      console.log('\n📊 Customer Login Page State:');
      console.log(`URL: ${loginState.url}`);
      console.log(`Body Text Length: ${loginState.bodyText.length}`);
      console.log(`Input Fields: ${loginState.inputs.length}`);
      console.log(`Buttons: ${loginState.buttons.length}`);
      console.log(`Text Elements: ${loginState.textElements.length}`);
      console.log(`Visible Elements: ${loginState.visibleElements}`);
      
      console.log('\n📝 Input Fields:');
      loginState.inputs.forEach((input, index) => {
        console.log(`  ${index + 1}. Type: ${input.type} | Placeholder: "${input.placeholder}" | Visible: ${input.visible}`);
        console.log(`     Color: ${input.styles.color} | Display: ${input.styles.display}`);
      });
      
      console.log('\n🔘 Buttons:');
      loginState.buttons.forEach((btn, index) => {
        console.log(`  ${index + 1}. ${btn.tagName}: "${btn.text}" | Visible: ${btn.visible}`);
        console.log(`     Color: ${btn.styles.color} | Background: ${btn.styles.backgroundColor}`);
      });
      
      console.log('\n📄 Text Elements:');
      loginState.textElements.slice(0, 10).forEach((el, index) => {
        console.log(`  ${index + 1}. ${el.tagName}: "${el.text.substring(0, 30)}..." | Color: ${el.styles.color}`);
      });
      
      if (loginState.bodyText.length > 0) {
        console.log(`\n📄 Body Text Preview:\n${loginState.bodyText.substring(0, 500)}`);
      }
      
      await this.page.screenshot({ path: 'test-results/current_login_state.png', fullPage: true });
      
      // Check if we can find and interact with elements
      console.log('\n🖱️ Testing element interaction...');
      
      // Try to find and fill email field
      const emailField = await this.page.$('input[type="email"], input[placeholder*="email" i]');
      if (emailField) {
        console.log('✅ Found email field');
        await emailField.fill('customer@example.com');
        console.log('✅ Filled email field');
      } else {
        console.log('❌ Email field not found');
      }
      
      // Try to find and fill password field
      const passwordField = await this.page.$('input[type="password"]');
      if (passwordField) {
        console.log('✅ Found password field');
        await passwordField.fill('customer123');
        console.log('✅ Filled password field');
      } else {
        console.log('❌ Password field not found');
      }
      
      // Try to find and click login button
      const loginButton = await this.page.$('button:has-text("Login"), button:has-text("Sign In"), [role="button"]:has-text("Login"), [role="button"]:has-text("Sign In")');
      if (loginButton) {
        console.log('✅ Found login button');
        await loginButton.click();
        console.log('✅ Clicked login button');
        await this.page.waitForTimeout(3000);
        
        const finalUrl = this.page.url();
        console.log(`📍 After login attempt: ${finalUrl}`);
        
        if (!finalUrl.includes('/login/customer')) {
          console.log('✅ Login appears successful - redirected');
          await this.page.screenshot({ path: 'test-results/login_success.png', fullPage: true });
        } else {
          console.log('❌ Login failed - still on login page');
          await this.page.screenshot({ path: 'test-results/login_failed.png', fullPage: true });
        }
      } else {
        console.log('❌ Login button not found');
      }
      
    } catch (error) {
      console.error('❌ State check error:', error);
      await this.page.screenshot({ path: 'test-results/state_check_error.png', fullPage: true });
    }
  }

  async run() {
    await this.setup();
    await this.checkCurrentState();
    await this.cleanup();
  }

  async cleanup() {
    if (this.browser) {
      await this.browser.close();
      console.log('🔚 Current state check completed');
    }
  }
}

// Run the check
const stateCheck = new CurrentStateCheck();
stateCheck.run().catch(console.error);
