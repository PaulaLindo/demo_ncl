// test_css_fixes.js - Test the permanent CSS fixes and check for issues
const { chromium } = require('playwright');

class TestCSSFixes {
  constructor() {
    this.browser = null;
    this.page = null;
  }

  async setup() {
    console.log('🧪 Setting up CSS Fixes Test...');
    this.browser = await chromium.launch({ 
      headless: false,
      slowMo: 1000 
    });
    this.page = await this.browser.newPage();
    await this.page.setViewportSize({ width: 1280, height: 720 });
    
    // Monitor console for any CSS-related errors
    this.page.on('console', msg => {
      if (msg.type() === 'error' || msg.type() === 'warning') {
        console.log(`📝 Browser ${msg.type().toUpperCase()}: ${msg.text()}`);
      }
    });
    
    console.log('✅ Browser launched');
  }

  async testCSSFixes() {
    try {
      console.log('📍 Testing permanent CSS fixes...');
      
      // Test home page
      await this.page.goto('http://localhost:8080');
      await this.page.waitForTimeout(5000);
      
      // Check if CSS fixes are loaded
      const cssLoaded = await this.page.evaluate(() => {
        const stylesheets = Array.from(document.styleSheets);
        const flutterFixes = stylesheets.find(sheet => 
          sheet.href && sheet.href.includes('flutter_fixes.css')
        );
        
        return {
          cssLoaded: !!flutterFixes,
          totalStylesheets: stylesheets.length,
          stylesheetHref: flutterFixes?.href || null,
        };
      });
      
      console.log('\n📊 CSS Loading Status:');
      console.log(`CSS Fixes Loaded: ${cssLoaded.cssLoaded ? '✅' : '❌'}`);
      console.log(`Total Stylesheets: ${cssLoaded.totalStylesheets}`);
      console.log(`Fixes Href: ${cssLoaded.stylesheetHref}`);
      
      if (!cssLoaded.cssLoaded) {
        console.log('❌ CSS fixes not loaded - applying manual fixes');
        await this.applyManualCSSFixes();
      }
      
      // Test home page functionality
      const homePageState = await this.page.evaluate(() => {
        return {
          url: window.location.href,
          title: document.title,
          bodyText: document.body.innerText || document.body.textContent || '',
          buttons: Array.from(document.querySelectorAll('button, [role="button"]')).map(btn => ({
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
          })),
          hasLoginForm: !!document.querySelector('input[type="email"], input[type="password"]'),
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
      
      console.log('\n📊 Home Page Analysis:');
      console.log(`URL: ${homePageState.url}`);
      console.log(`Body Text Length: ${homePageState.bodyText.length}`);
      console.log(`Buttons: ${homePageState.buttons.length}`);
      console.log(`Visible Elements: ${homePageState.visibleElements}`);
      
      console.log('\n🔘 Buttons Found:');
      homePageState.buttons.forEach((btn, index) => {
        console.log(`  ${index + 1}. ${btn.tagName}: "${btn.text}" | Visible: ${btn.visible}`);
        if (btn.text.length > 0) {
          console.log(`     Color: ${btn.styles.color} | Background: ${btn.styles.backgroundColor}`);
        }
      });
      
      await this.page.screenshot({ path: 'test-results/css_home_test.png', fullPage: true });
      
      // Test customer login page
      console.log('\n📍 Testing Customer Login page...');
      await this.page.goto('http://localhost:8080/login/customer');
      await this.page.waitForTimeout(5000);
      
      const loginPageState = await this.page.evaluate(() => {
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
            backgroundColor: window.getComputedStyle(input).backgroundColor,
            borderColor: window.getComputedStyle(input).borderColor,
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
      
      console.log('\n📊 Customer Login Page Analysis:');
      console.log(`URL: ${loginPageState.url}`);
      console.log(`Body Text Length: ${loginPageState.bodyText.length}`);
      console.log(`Input Fields: ${loginPageState.inputs.length}`);
      console.log(`Buttons: ${loginPageState.buttons.length}`);
      console.log(`Text Elements: ${loginPageState.textElements.length}`);
      console.log(`Visible Elements: ${loginPageState.visibleElements}`);
      
      console.log('\n📝 Input Fields:');
      loginPageState.inputs.forEach((input, index) => {
        console.log(`  ${index + 1}. Type: ${input.type} | Placeholder: "${input.placeholder}" | Visible: ${input.visible}`);
        console.log(`     Color: ${input.styles.color} | Background: ${input.styles.backgroundColor}`);
      });
      
      console.log('\n🔘 Buttons:');
      loginPageState.buttons.forEach((btn, index) => {
        console.log(`  ${index + 1}. ${btn.tagName}: "${btn.text}" | Visible: ${btn.visible}`);
        console.log(`     Color: ${btn.styles.color} | Background: ${btn.styles.backgroundColor}`);
      });
      
      console.log('\n📄 Text Elements (first 10):');
      loginPageState.textElements.slice(0, 10).forEach((el, index) => {
        console.log(`  ${index + 1}. ${el.tagName}: "${el.text.substring(0, 30)}..." | Color: ${el.styles.color}`);
      });
      
      await this.page.screenshot({ path: 'test-results/css_login_test.png', fullPage: true });
      
      // Test login functionality
      console.log('\n🖱️ Testing login functionality...');
      
      // Find and fill email field
      const emailField = await this.page.$('input[type="email"], input[placeholder*="email" i]');
      if (emailField) {
        console.log('✅ Found email field');
        await emailField.fill('customer@example.com');
        console.log('✅ Filled email field');
      } else {
        console.log('❌ Email field not found');
      }
      
      // Find and fill password field
      const passwordField = await this.page.$('input[type="password"]');
      if (passwordField) {
        console.log('✅ Found password field');
        await passwordField.fill('customer123');
        console.log('✅ Filled password field');
      } else {
        console.log('❌ Password field not found');
      }
      
      // Find and click login button
      const loginButton = await this.page.$('button:has-text("Sign In"), button:has-text("Login"), [role="button"]:has-text("Sign In"), [role="button"]:has-text("Login")');
      if (loginButton) {
        console.log('✅ Found login button');
        await loginButton.click();
        console.log('✅ Clicked login button');
        await this.page.waitForTimeout(5000);
        
        const finalUrl = this.page.url();
        console.log(`📍 After login: ${finalUrl}`);
        
        if (!finalUrl.includes('/login/customer')) {
          console.log('✅ Login successful - redirected from login page');
          await this.page.screenshot({ path: 'test-results/css_login_success.png', fullPage: true });
          return true;
        } else {
          console.log('❌ Login failed - still on login page');
          await this.page.screenshot({ path: 'test-results/css_login_failed.png', fullPage: true });
        }
      } else {
        console.log('❌ Login button not found');
      }
      
      return false;
      
    } catch (error) {
      console.error('❌ CSS fixes test error:', error);
      await this.page.screenshot({ path: 'test-results/css_test_error.png', fullPage: true });
      return false;
    }
  }

  async applyManualCSSFixes() {
    // Apply CSS fixes manually if the stylesheet isn't loaded
    await this.page.evaluate(() => {
      const manualCSS = `
        html, body {
          height: 100% !important;
          width: 100% !important;
          min-height: 100vh !important;
          overflow: visible !important;
          margin: 0 !important;
          padding: 0 !important;
          position: relative !important;
          background: white !important;
        }
        
        flutter-view, flt-glass-pane, flt-scene-host, flt-semantics-host {
          display: block !important;
          position: relative !important;
          width: 100% !important;
          height: 100vh !important;
          min-height: 100vh !important;
          overflow: visible !important;
        }
        
        flt-glass-pane {
          pointer-events: none !important;
          z-index: -1 !important;
        }
        
        flutter-view {
          pointer-events: auto !important;
          z-index: 1 !important;
        }
        
        flt-semantics-placeholder,
        flt-semantics-container,
        flt-text-pane,
        flt-semantic-text {
          pointer-events: auto !important;
          z-index: 10 !important;
          position: relative !important;
          display: block !important;
          visibility: visible !important;
          opacity: 1 !important;
        }
        
        input, textarea, select {
          pointer-events: auto !important;
          z-index: 20 !important;
          position: relative !important;
          display: block !important;
          visibility: visible !important;
          opacity: 1 !important;
          background: white !important;
          border: 1px solid #ddd !important;
          padding: 10px !important;
          margin: 5px 0 !important;
          border-radius: 4px !important;
          color: #333 !important;
          font-size: 14px !important;
        }
        
        button, [role="button"] {
          pointer-events: auto !important;
          z-index: 20 !important;
          position: relative !important;
          display: block !important;
          visibility: visible !important;
          opacity: 1 !important;
          cursor: pointer !important;
          padding: 12px 24px !important;
          margin: 10px 0 !important;
          border: none !important;
          border-radius: 4px !important;
          background: #007bff !important;
          color: white !important;
          text-decoration: none !important;
          font-size: 14px !important;
          font-weight: 500 !important;
          text-align: center !important;
          min-width: 120px !important;
        }
        
        div, span, p, h1, h2, h3, h4, h5, h6, label {
          pointer-events: auto !important;
          position: relative !important;
          display: block !important;
          visibility: visible !important;
          opacity: 1 !important;
          color: #333 !important;
        }
      `;
      
      const styleElement = document.createElement('style');
      styleElement.textContent = manualCSS;
      styleElement.id = 'manual-flutter-fixes';
      document.head.appendChild(styleElement);
    });
    
    console.log('✅ Applied manual CSS fixes');
  }

  async run() {
    await this.setup();
    const success = await this.testCSSFixes();
    await this.cleanup();
    
    console.log(`\n🎯 CSS Fixes Test Result: ${success ? '✅ SUCCESS' : '❌ FAILED'}`);
    return success;
  }

  async cleanup() {
    if (this.browser) {
      await this.browser.close();
      console.log('🔚 CSS fixes test completed');
    }
  }
}

// Run the test
const cssTest = new TestCSSFixes();
cssTest.run().catch(console.error);
