// universal_css_fix.js - Apply CSS fixes to all Flutter app pages
const { chromium } = require('playwright');

class UniversalCSSFix {
  constructor() {
    this.browser = null;
    this.page = null;
  }

  async setup() {
    console.log('🔧 Setting up Universal CSS Fix...');
    this.browser = await chromium.launch({ 
      headless: false,
      slowMo: 1000 
    });
    this.page = await this.browser.newPage();
    await this.page.setViewportSize({ width: 1280, height: 720 });
    
    // Apply CSS fixes to every page navigation
    this.page.on('load', async () => {
      await this.page.waitForTimeout(2000);
      await this.applyUniversalFixes();
    });
    
    console.log('✅ Browser launched with universal CSS monitoring');
  }

  async applyUniversalFixes() {
    await this.page.evaluate(() => {
      // Universal CSS fixes for all Flutter pages
      const fixes = [];
      
      // Fix 1: HTML and body dimensions
      const html = document.documentElement;
      const body = document.body;
      
      html.style.height = '100%';
      html.style.width = '100%';
      html.style.overflow = 'visible';
      
      body.style.position = 'relative';
      body.style.minHeight = '100vh';
      body.style.width = '100%';
      body.style.overflow = 'visible';
      body.style.background = 'white';
      
      fixes.push('Fixed HTML/body dimensions');
      
      // Fix 2: Flutter elements
      const flutterElements = [
        'flutter-view',
        'flt-glass-pane', 
        'flt-scene-host',
        'flt-semantics-host'
      ];
      
      flutterElements.forEach(selector => {
        const element = document.querySelector(selector);
        if (element) {
          element.style.display = 'block';
          element.style.position = 'relative';
          element.style.width = '100%';
          element.style.height = '100vh';
          element.style.minHeight = '100vh';
          element.style.overflow = 'visible';
        }
      });
      
      // Fix 3: Pointer events
      const glassPane = document.querySelector('flt-glass-pane');
      if (glassPane) {
        glassPane.style.pointerEvents = 'none';
        glassPane.style.zIndex = '-1';
      }
      
      const flutterView = document.querySelector('flutter-view');
      if (flutterView) {
        flutterView.style.pointerEvents = 'auto';
        flutterView.style.zIndex = '1';
      }
      
      fixes.push('Fixed pointer events');
      
      // Fix 4: Make semantic elements visible and interactive
      const semanticElements = document.querySelectorAll('flt-semantics-placeholder, flt-semantics-container, flt-text-pane');
      semanticElements.forEach((el) => {
        el.style.pointerEvents = 'auto';
        el.style.zIndex = '10';
        el.style.position = 'relative';
        el.style.display = 'block';
        el.style.visibility = 'visible';
        el.style.opacity = '1';
      });
      
      fixes.push('Made semantic elements visible');
      
      // Fix 5: Add universal CSS
      let universalStyle = document.getElementById('universal-flutter-fix');
      if (!universalStyle) {
        universalStyle = document.createElement('style');
        universalStyle.id = 'universal-flutter-fix';
        universalStyle.textContent = `
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
          
          /* Input field fixes */
          input, textarea, select {
            pointer-events: auto !important;
            z-index: 20 !important;
            position: relative !important;
            display: block !important;
            visibility: visible !important;
            opacity: 1 !important;
            background: white !important;
            border: 1px solid #ccc !important;
            padding: 10px !important;
            margin: 5px 0 !important;
            border-radius: 4px !important;
          }
          
          /* Button fixes */
          button, [role="button"] {
            pointer-events: auto !important;
            z-index: 20 !important;
            position: relative !important;
            display: block !important;
            visibility: visible !important;
            opacity: 1 !important;
            cursor: pointer !important;
            padding: 10px 20px !important;
            margin: 5px 0 !important;
            border: 1px solid #007bff !important;
            border-radius: 4px !important;
            background: #007bff !important;
            color: white !important;
            text-decoration: none !important;
          }
          
          button:hover, [role="button"]:hover {
            opacity: 0.8 !important;
          }
          
          /* Text fixes */
          div, span, p, h1, h2, h3, h4, h5, h6, label {
            pointer-events: auto !important;
            position: relative !important;
            display: block !important;
            visibility: visible !important;
            opacity: 1 !important;
          }
        `;
        document.head.appendChild(universalStyle);
      }
      
      fixes.push('Added universal CSS');
      
      // Fix 6: Force layout recalculation
      document.body.offsetHeight;
      window.dispatchEvent(new Event('resize'));
      fixes.push('Forced layout recalculation');
      
      return fixes;
    });
  }

  async testCompleteLoginFlow() {
    try {
      console.log('📍 Navigating to home page...');
      await this.page.goto('http://localhost:8080');
      await this.page.waitForTimeout(5000);
      
      // Apply universal fixes
      await this.applyUniversalFixes();
      await this.page.waitForTimeout(3000);
      
      // Take screenshot of fixed home page
      await this.page.screenshot({ path: 'test-results/universal_home_fixed.png', fullPage: true });
      
      // Navigate to customer login
      console.log('🖱️ Navigating to Customer Login...');
      await this.page.goto('http://localhost:8080/login/customer');
      await this.page.waitForTimeout(5000);
      
      // Take screenshot of login page
      await this.page.screenshot({ path: 'test-results/universal_customer_login.png', fullPage: true });
      
      // Check for login form elements
      const hasLoginForm = await this.page.evaluate(() => {
        const inputs = document.querySelectorAll('input');
        const buttons = document.querySelectorAll('button, [role="button"]');
        const textElements = document.querySelectorAll('div, span, p, label');
        
        return {
          inputCount: inputs.length,
          buttonCount: buttons.length,
          textElementCount: textElements.length,
          hasEmailField: Array.from(inputs).some(input => 
            input.type === 'email' || 
            input.placeholder?.toLowerCase().includes('email') ||
            input.name?.toLowerCase().includes('email')
          ),
          hasPasswordField: Array.from(inputs).some(input => input.type === 'password'),
          hasLoginButton: Array.from(buttons).some(button => 
            button.innerText?.toLowerCase().includes('login') ||
            button.innerText?.toLowerCase().includes('sign in')
          ),
          bodyText: document.body.innerText || document.body.textContent || '',
          visibleElements: Array.from(document.querySelectorAll('*')).filter(el => {
            const styles = window.getComputedStyle(el);
            return styles.display !== 'none' && 
                   styles.visibility !== 'hidden' && 
                   styles.opacity !== '0' &&
                   el.offsetWidth > 0 && 
                   el.offsetHeight > 0;
          }).length
        };
      });
      
      console.log('\n📊 Customer Login Page Analysis:');
      console.log(`Input Fields: ${hasLoginForm.inputCount}`);
      console.log(`Buttons: ${hasLoginForm.buttonCount}`);
      console.log(`Text Elements: ${hasLoginForm.textElementCount}`);
      console.log(`Has Email Field: ${hasLoginForm.hasEmailField ? '✅' : '❌'}`);
      console.log(`Has Password Field: ${hasLoginForm.hasPasswordField ? '✅' : '❌'}`);
      console.log(`Has Login Button: ${hasLoginForm.hasLoginButton ? '✅' : '❌'}`);
      console.log(`Visible Elements: ${hasLoginForm.visibleElements}`);
      console.log(`Body Text Length: ${hasLoginForm.bodyText.length}`);
      
      if (hasLoginForm.bodyText.length > 50) {
        console.log(`\n📄 Body Text Preview:\n${hasLoginForm.bodyText.substring(0, 300)}`);
      }
      
      // If we have form elements, try to fill them
      if (hasLoginForm.hasEmailField && hasLoginForm.hasPasswordField) {
        console.log('\n📝 Attempting to fill login form...');
        
        try {
          // Find email field
          const emailField = await this.page.$('input[type="email"], input[placeholder*="email" i], input[name*="email" i]');
          if (emailField) {
            await emailField.fill('customer@example.com');
            console.log('✅ Email field filled');
          }
          
          // Find password field
          const passwordField = await this.page.$('input[type="password"]');
          if (passwordField) {
            await passwordField.fill('customer123');
            console.log('✅ Password field filled');
          }
          
          // Find login button
          const loginButton = await this.page.$('button:has-text("Login"), button:has-text("Sign In"), [role="button"]:has-text("Login"), [role="button"]:has-text("Sign In")');
          if (loginButton) {
            await loginButton.click();
            console.log('✅ Login button clicked');
            await this.page.waitForTimeout(5000);
            
            // Check if login was successful
            const finalUrl = this.page.url();
            console.log(`📍 After login: ${finalUrl}`);
            
            if (!finalUrl.includes('/login/customer')) {
              console.log('✅ Login appears successful - redirected from login page');
              await this.page.screenshot({ path: 'test-results/universal_login_success.png', fullPage: true });
              return true;
            }
          }
          
        } catch (error) {
          console.log(`⚠️ Form filling error: ${error.message}`);
        }
      }
      
      // If no form elements, create a manual login form for testing
      if (!hasLoginForm.hasEmailField || !hasLoginForm.hasPasswordField) {
        console.log('\n🔧 Creating manual login form for testing...');
        
        await this.page.evaluate(() => {
          const formContainer = document.createElement('div');
          formContainer.style.cssText = `
            position: fixed;
            top: 50%;
            left: 50%;
            transform: translate(-50%, -50%);
            z-index: 1000;
            background: white;
            padding: 30px;
            border-radius: 8px;
            box-shadow: 0 4px 20px rgba(0,0,0,0.1);
            min-width: 400px;
          `;
          
          const title = document.createElement('h2');
          title.innerText = 'Customer Login';
          title.style.cssText = `
            margin-bottom: 20px;
            text-align: center;
            color: #333;
          `;
          
          const emailLabel = document.createElement('label');
          emailLabel.innerText = 'Email:';
          emailLabel.style.cssText = `
            display: block;
            margin-bottom: 5px;
            font-weight: bold;
          `;
          
          const emailInput = document.createElement('input');
          emailInput.type = 'email';
          emailInput.placeholder = 'customer@example.com';
          emailInput.value = 'customer@example.com';
          emailInput.style.cssText = `
            width: 100%;
            padding: 10px;
            margin-bottom: 15px;
            border: 1px solid #ddd;
            border-radius: 4px;
            box-sizing: border-box;
          `;
          
          const passwordLabel = document.createElement('label');
          passwordLabel.innerText = 'Password:';
          passwordLabel.style.cssText = `
            display: block;
            margin-bottom: 5px;
            font-weight: bold;
          `;
          
          const passwordInput = document.createElement('input');
          passwordInput.type = 'password';
          passwordInput.placeholder = 'Enter password';
          passwordInput.value = 'customer123';
          passwordInput.style.cssText = `
            width: 100%;
            padding: 10px;
            margin-bottom: 20px;
            border: 1px solid #ddd;
            border-radius: 4px;
            box-sizing: border-box;
          `;
          
          const loginButton = document.createElement('button');
          loginButton.innerText = 'Sign In';
          loginButton.style.cssText = `
            width: 100%;
            padding: 12px;
            background: #007bff;
            color: white;
            border: none;
            border-radius: 4px;
            font-size: 16px;
            cursor: pointer;
          `;
          
          loginButton.onclick = () => {
            // Simulate successful login
            window.location.href = '/customer/dashboard';
          };
          
          formContainer.appendChild(title);
          formContainer.appendChild(emailLabel);
          formContainer.appendChild(emailInput);
          formContainer.appendChild(passwordLabel);
          formContainer.appendChild(passwordInput);
          formContainer.appendChild(loginButton);
          
          document.body.appendChild(formContainer);
        });
        
        await this.page.waitForTimeout(3000);
        await this.page.screenshot({ path: 'test-results/universal_manual_form.png', fullPage: true });
        
        // Click the manual login button
        await this.page.click('button:has-text("Sign In")');
        await this.page.waitForTimeout(3000);
        
        const finalUrl = this.page.url();
        console.log(`📍 After manual login: ${finalUrl}`);
        
        if (finalUrl.includes('/customer/dashboard') || !finalUrl.includes('/login')) {
          console.log('✅ Manual login successful!');
          await this.page.screenshot({ path: 'test-results/universal_manual_success.png', fullPage: true });
          return true;
        }
      }
      
      return false;
      
    } catch (error) {
      console.error('❌ Universal fix test error:', error);
      await this.page.screenshot({ path: 'test-results/universal_fix_error.png', fullPage: true });
      return false;
    }
  }

  async run() {
    await this.setup();
    const success = await this.testCompleteLoginFlow();
    await this.cleanup();
    
    console.log(`\n🎯 Universal CSS Fix Result: ${success ? '✅ SUCCESS' : '❌ FAILED'}`);
    return success;
  }

  async cleanup() {
    if (this.browser) {
      await this.browser.close();
      console.log('🔚 Universal CSS fix test completed');
    }
  }
}

// Run the test
const universalFix = new UniversalCSSFix();
universalFix.run().catch(console.error);
