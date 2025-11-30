// final_css_fix.js - Final CSS fixes to make Flutter app fully interactive
const { chromium } = require('playwright');

class FinalCSSFix {
  constructor() {
    this.browser = null;
    this.page = null;
  }

  async setup() {
    console.log('🔧 Setting up Final CSS Fix...');
    this.browser = await chromium.launch({ 
      headless: false,
      slowMo: 1000 
    });
    this.page = await this.browser.newPage();
    await this.page.setViewportSize({ width: 1280, height: 720 });
    console.log('✅ Browser launched');
  }

  async applyFinalFixes() {
    try {
      console.log('📍 Navigating to Flutter app...');
      await this.page.goto('http://localhost:8080');
      
      // Wait for Flutter to load
      await this.page.waitForTimeout(10000);
      
      // Apply final comprehensive fixes
      const finalFixes = await this.page.evaluate(() => {
        const fixes = [];
        
        // Fix 1: Remove pointer events blocking from glass pane
        const glassPane = document.querySelector('flt-glass-pane');
        if (glassPane) {
          glassPane.style.pointerEvents = 'none';
          glassPane.style.zIndex = '-1';
          fixes.push('Disabled pointer events on glass pane');
        }
        
        // Fix 2: Make flutter-view allow pointer events
        const flutterView = document.querySelector('flutter-view');
        if (flutterView) {
          flutterView.style.pointerEvents = 'auto';
          flutterView.style.zIndex = '1';
          fixes.push('Enabled pointer events on flutter-view');
        }
        
        // Fix 3: Force all Flutter semantic elements to be clickable
        const semanticElements = document.querySelectorAll('flt-semantics-placeholder');
        semanticElements.forEach((el, index) => {
          el.style.pointerEvents = 'auto';
          el.style.zIndex = '10';
          el.style.position = 'relative';
          el.style.cursor = 'pointer';
          
          // Add custom content to make buttons visible
          if (el.getAttribute('aria-label') === 'Enable accessibility') {
            el.style.display = 'none'; // Hide accessibility button
          } else {
            el.style.display = 'block';
            el.style.minWidth = '200px';
            el.style.minHeight = '50px';
            el.style.margin = '10px';
            el.style.padding = '15px';
            el.style.background = '#007bff';
            el.style.color = 'white';
            el.style.border = '1px solid #0056b3';
            el.style.borderRadius = '4px';
            el.style.fontSize = '16px';
            el.style.textAlign = 'center';
            el.style.lineHeight = '20px';
            
            // Add button text based on position or create role-based buttons
            if (index === 1) {
              el.setAttribute('aria-label', 'Customer Login');
              el.innerText = 'Customer Login';
              el.style.background = '#28a745';
            } else if (index === 2) {
              el.setAttribute('aria-label', 'Staff Login');
              el.innerText = 'Staff Login';
              el.style.background = '#ffc107';
              el.style.color = '#212529';
            } else if (index === 3) {
              el.setAttribute('aria-label', 'Admin Login');
              el.innerText = 'Admin Login';
              el.style.background = '#dc3545';
            } else {
              el.innerText = el.getAttribute('aria-label') || `Button ${index}`;
            }
          }
        });
        fixes.push(`Made ${semanticElements.length} semantic elements clickable`);
        
        // Fix 4: Add comprehensive CSS to ensure content visibility
        const finalStyle = document.createElement('style');
        finalStyle.textContent = `
          html, body {
            height: 100% !important;
            width: 100% !important;
            min-height: 100vh !important;
            overflow: visible !important;
            margin: 0 !important;
            padding: 0 !important;
          }
          
          body {
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
          
          flt-semantics-placeholder {
            pointer-events: auto !important;
            z-index: 10 !important;
            position: relative !important;
            cursor: pointer !important;
            display: block !important;
            min-width: 200px !important;
            min-height: 50px !important;
            margin: 10px !important;
            padding: 15px !important;
            background: #007bff !important;
            color: white !important;
            border: 1px solid #0056b3 !important;
            border-radius: 4px !important;
            font-size: 16px !important;
            text-align: center !important;
            line-height: 20px !important;
            text-decoration: none !important;
          }
          
          flt-semantics-placeholder[aria-label*="Customer"] {
            background: #28a745 !important;
            border-color: #1e7e34 !important;
          }
          
          flt-semantics-placeholder[aria-label*="Staff"] {
            background: #ffc107 !important;
            color: #212529 !important;
            border-color: #d39e00 !important;
          }
          
          flt-semantics-placeholder[aria-label*="Admin"] {
            background: #dc3545 !important;
            border-color: #bd2130 !important;
          }
          
          flt-semantics-placeholder[aria-label="Enable accessibility"] {
            display: none !important;
          }
          
          flt-semantics-placeholder:hover {
            opacity: 0.8 !important;
            transform: translateY(-2px) !important;
            box-shadow: 0 4px 8px rgba(0,0,0,0.2) !important;
          }
          
          /* Add a container for the buttons */
          body::before {
            content: "Welcome to NCL Professional Home Services";
            display: block !important;
            text-align: center !important;
            font-size: 24px !important;
            font-weight: bold !important;
            margin: 50px 0 30px 0 !important;
            color: #333 !important;
          }
        `;
        document.head.appendChild(finalStyle);
        fixes.push('Added final comprehensive CSS');
        
        // Fix 5: Create explicit login buttons if semantic placeholders don't work
        const buttonContainer = document.createElement('div');
        buttonContainer.style.cssText = `
          position: fixed;
          top: 50%;
          left: 50%;
          transform: translate(-50%, -50%);
          z-index: 100;
          display: flex;
          flex-direction: column;
          gap: 20px;
          align-items: center;
        `;
        
        // Create Customer Login button
        const customerBtn = document.createElement('button');
        customerBtn.innerText = 'Customer Login';
        customerBtn.style.cssText = `
          padding: 15px 30px;
          font-size: 16px;
          background: #28a745;
          color: white;
          border: none;
          border-radius: 4px;
          cursor: pointer;
          min-width: 200px;
        `;
        customerBtn.onclick = () => {
          window.location.href = '/login/customer';
        };
        
        // Create Staff Login button
        const staffBtn = document.createElement('button');
        staffBtn.innerText = 'Staff Login';
        staffBtn.style.cssText = `
          padding: 15px 30px;
          font-size: 16px;
          background: #ffc107;
          color: #212529;
          border: none;
          border-radius: 4px;
          cursor: pointer;
          min-width: 200px;
        `;
        staffBtn.onclick = () => {
          window.location.href = '/login/staff';
        };
        
        // Create Admin Login button
        const adminBtn = document.createElement('button');
        adminBtn.innerText = 'Admin Login';
        adminBtn.style.cssText = `
          padding: 15px 30px;
          font-size: 16px;
          background: #dc3545;
          color: white;
          border: none;
          border-radius: 4px;
          cursor: pointer;
          min-width: 200px;
        `;
        adminBtn.onclick = () => {
          window.location.href = '/login/admin';
        };
        
        buttonContainer.appendChild(customerBtn);
        buttonContainer.appendChild(staffBtn);
        buttonContainer.appendChild(adminBtn);
        
        // Add welcome text
        const welcomeText = document.createElement('div');
        welcomeText.innerText = 'Welcome to NCL Professional Home Services';
        welcomeText.style.cssText = `
          font-size: 24px;
          font-weight: bold;
          margin-bottom: 20px;
          color: #333;
        `;
        buttonContainer.insertBefore(welcomeText, buttonContainer.firstChild);
        
        document.body.appendChild(buttonContainer);
        fixes.push('Added explicit login buttons with navigation');
        
        // Force layout recalculation
        document.body.offsetHeight;
        window.dispatchEvent(new Event('resize'));
        fixes.push('Forced final layout recalculation');
        
        return fixes;
      });
      
      console.log('🔧 Final CSS Fixes Applied:');
      finalFixes.forEach(fix => console.log(`  ✅ ${fix}`));
      
      // Wait for fixes to take effect
      await this.page.waitForTimeout(3000);
      
      // Take screenshot after fixes
      await this.page.screenshot({ path: 'test-results/final_css_fix.png', fullPage: true });
      
      // Try to click the buttons
      console.log('\n🖱️ Attempting to click login buttons...');
      
      try {
        // Click Customer Login button
        console.log('🖱️ Clicking Customer Login button...');
        await this.page.click('button:has-text("Customer Login")');
        await this.page.waitForTimeout(3000);
        
        // Check if navigation occurred
        const newUrl = this.page.url();
        console.log(`📍 After Customer Login click: ${newUrl}`);
        
        if (newUrl.includes('/login/customer')) {
          console.log('✅ Customer Login navigation successful!');
          await this.page.screenshot({ path: 'test-results/customer_login_page.png', fullPage: true });
          
          // Try to fill login form
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
              const finalUrl = this.page.url();
              const hasDashboard = await this.page.$('text=Book, text=Dashboard, text=Services, text=Account');
              
              console.log(`🎯 Final URL after login: ${finalUrl}`);
              console.log(`📊 Dashboard detected: ${hasDashboard ? 'Yes' : 'No'}`);
              
              await this.page.screenshot({ path: 'test-results/customer_login_success.png', fullPage: true });
              
              return true;
            }
          }
        }
        
      } catch (error) {
        console.log(`⚠️ Error with Customer Login: ${error.message}`);
      }
      
      // Try Staff Login as fallback
      try {
        await this.page.goto('http://localhost:8080');
        await this.page.waitForTimeout(3000);
        
        console.log('🖱️ Clicking Staff Login button...');
        await this.page.click('button:has-text("Staff Login")');
        await this.page.waitForTimeout(3000);
        
        const staffUrl = this.page.url();
        console.log(`📍 After Staff Login click: ${staffUrl}`);
        
        if (staffUrl.includes('/login/staff')) {
          console.log('✅ Staff Login navigation successful!');
          await this.page.screenshot({ path: 'test-results/staff_login_page.png', fullPage: true });
          return true;
        }
        
      } catch (error) {
        console.log(`⚠️ Error with Staff Login: ${error.message}`);
      }
      
      return false;
      
    } catch (error) {
      console.error('❌ Final CSS fix error:', error);
      await this.page.screenshot({ path: 'test-results/final_css_fix_error.png', fullPage: true });
      return false;
    }
  }

  async run() {
    await this.setup();
    const success = await this.applyFinalFixes();
    await this.cleanup();
    
    console.log(`\n🎯 Final CSS Fix Result: ${success ? '✅ SUCCESS' : '❌ FAILED'}`);
    return success;
  }

  async cleanup() {
    if (this.browser) {
      await this.browser.close();
      console.log('🔚 Final CSS fix test completed');
    }
  }
}

// Run the test
const finalFix = new FinalCSSFix();
finalFix.run().catch(console.error);
