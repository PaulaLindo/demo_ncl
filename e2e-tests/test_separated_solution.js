// test_separated_solution.js - Test the separated CSS + JavaScript solution
const { chromium } = require('playwright');

class TestSeparatedSolution {
  constructor() {
    this.browser = null;
    this.page = null;
  }

  async setup() {
    console.log('🧪 Setting up Separated Solution Test...');
    this.browser = await chromium.launch({ 
      headless: false,
      slowMo: 1000 
    });
    this.page = await this.browser.newPage();
    await this.page.setViewportSize({ width: 1280, height: 720 });
    
    // Monitor console for any errors
    this.page.on('console', msg => {
      if (msg.type() === 'error' || msg.type() === 'warning') {
        console.log(`📝 Browser ${msg.type().toUpperCase()}: ${msg.text()}`);
      }
    });
    
    console.log('✅ Browser launched');
  }

  async testSeparatedSolution() {
    try {
      console.log('📍 Testing separated CSS + JavaScript solution...');
      
      // Test home page
      await this.page.goto('http://localhost:8080');
      await this.page.waitForTimeout(5000);
      
      // Check if both CSS and JS are loaded
      const resourcesLoaded = await this.page.evaluate(() => {
        const stylesheets = Array.from(document.styleSheets);
        const scripts = Array.from(document.scripts);
        
        const minimalCSS = stylesheets.find(sheet => 
          sheet.href && sheet.href.includes('flutter_fixes_minimal.css')
        );
        
        const uiHelperJS = scripts.find(script => 
          script.src && script.src.includes('flutter_ui_helper.js')
        );
        
        const overlayElement = document.getElementById('flutter-ui-helper');
        
        return {
          minimalCSSLoaded: !!minimalCSS,
          uiHelperJSLoaded: !!uiHelperJS,
          overlayCreated: !!overlayElement,
          totalStylesheets: stylesheets.length,
          totalScripts: scripts.length,
        };
      });
      
      console.log('\n📊 Resources Loading Status:');
      console.log(`Minimal CSS Loaded: ${resourcesLoaded.minimalCSSLoaded ? '✅' : '❌'}`);
      console.log(`UI Helper JS Loaded: ${resourcesLoaded.uiHelperJSLoaded ? '✅' : '❌'}`);
      console.log(`Overlay Created: ${resourcesLoaded.overlayCreated ? '✅' : '❌'}`);
      console.log(`Total Stylesheets: ${resourcesLoaded.totalStylesheets}`);
      console.log(`Total Scripts: ${resourcesLoaded.totalScripts}`);
      
      // Wait for UI helper to initialize
      await this.page.waitForTimeout(3000);
      
      // Check for overlay buttons
      const overlayButtons = await this.page.evaluate(() => {
        const overlay = document.getElementById('flutter-ui-helper');
        if (!overlay) return { buttons: [], visible: false };
        
        const buttons = Array.from(overlay.querySelectorAll('button')).map(btn => ({
          text: btn.innerText || btn.textContent || '',
          visible: btn.offsetParent !== null,
          tagName: btn.tagName,
        }));
        
        return {
          buttons,
          visible: buttons.some(btn => btn.visible),
          overlayHTML: overlay.innerHTML.substring(0, 500),
        };
      });
      
      console.log('\n📊 Overlay Analysis:');
      console.log(`Overlay Buttons: ${overlayButtons.buttons.length}`);
      console.log(`Buttons Visible: ${overlayButtons.visible ? '✅' : '❌'}`);
      
      console.log('\n🔘 Overlay Buttons:');
      overlayButtons.buttons.forEach((btn, index) => {
        console.log(`  ${index + 1}. ${btn.tagName}: "${btn.text}" | Visible: ${btn.visible}`);
      });
      
      await this.page.screenshot({ path: 'test-results/separated_home_test.png', fullPage: true });
      
      // Test clicking Customer Login button
      if (overlayButtons.buttons.length > 0) {
        console.log('\n🖱️ Testing Customer Login button...');
        
        try {
          await this.page.click('button:has-text("Customer Login")');
          await this.page.waitForTimeout(3000);
          
          const loginUrl = this.page.url();
          console.log(`📍 After Customer Login click: ${loginUrl}`);
          
          if (loginUrl.includes('/login/customer')) {
            console.log('✅ Customer Login navigation successful!');
            await this.page.screenshot({ path: 'test-results/separated_customer_login.png', fullPage: true });
            
            // Check for demo credentials helper
            const credentialsHelper = await this.page.evaluate(() => {
              const overlay = document.getElementById('flutter-ui-helper');
              if (!overlay) return { found: false };
              
              const helperText = overlay.innerText || overlay.textContent || '';
              const hasDemoCredentials = helperText.includes('Demo Credentials');
              const hasEmail = helperText.includes('customer@example.com');
              const hasPassword = helperText.includes('customer123');
              
              return {
                found: true,
                hasDemoCredentials,
                hasEmail,
                hasPassword,
                helperText: helperText.substring(0, 200),
              };
            });
            
            console.log('\n📊 Credentials Helper Analysis:');
            console.log(`Helper Found: ${credentialsHelper.found ? '✅' : '❌'}`);
            console.log(`Has Demo Credentials: ${credentialsHelper.hasDemoCredentials ? '✅' : '❌'}`);
            console.log(`Has Email: ${credentialsHelper.hasEmail ? '✅' : '❌'}`);
            console.log(`Has Password: ${credentialsHelper.hasPassword ? '✅' : '❌'}`);
            
            if (credentialsHelper.helperText.length > 0) {
              console.log(`\n📄 Helper Text Preview:\n${credentialsHelper.helperText}`);
            }
            
            // Test auto-fill functionality
            if (credentialsHelper.hasDemoCredentials) {
              console.log('\n🖱️ Testing demo credentials auto-fill...');
              
              // Try to click on email credential
              try {
                await this.page.click('div:has-text("customer@example.com")');
                await this.page.waitForTimeout(1000);
                console.log('✅ Clicked email credential');
                
                // Check if email field was filled
                const emailFilled = await this.page.evaluate(() => {
                  const emailField = document.querySelector('input[type="email"], input[placeholder*="email" i]');
                  return emailField ? emailField.value : '';
                });
                
                console.log(`Email field value: "${emailFilled}"`);
                
                // Try to click on password credential
                await this.page.click('div:has-text("customer123")');
                await this.page.waitForTimeout(1000);
                console.log('✅ Clicked password credential');
                
                // Check if password field was filled
                const passwordFilled = await this.page.evaluate(() => {
                  const passwordField = document.querySelector('input[type="password"]');
                  return passwordField ? passwordField.value : '';
                });
                
                console.log(`Password field value: "${passwordFilled}"`);
                
                if (emailFilled && passwordFilled) {
                  console.log('✅ Demo credentials auto-fill working!');
                  
                  // Try to find and click login button
                  await this.page.waitForTimeout(2000);
                  const loginButton = await this.page.$('button:has-text("Sign In"), button:has-text("Login"), [role="button"]:has-text("Sign In"), [role="button"]:has-text("Login")');
                  
                  if (loginButton) {
                    console.log('✅ Found login button');
                    await loginButton.click();
                    await this.page.waitForTimeout(5000);
                    
                    const finalUrl = this.page.url();
                    console.log(`📍 After login: ${finalUrl}`);
                    
                    if (!finalUrl.includes('/login/customer')) {
                      console.log('✅ Login successful - redirected from login page');
                      await this.page.screenshot({ path: 'test-results/separated_login_success.png', fullPage: true });
                      return true;
                    }
                  } else {
                    console.log('❌ Login button not found');
                  }
                }
                
              } catch (error) {
                console.log(`⚠️ Auto-fill error: ${error.message}`);
              }
            }
            
          } else {
            console.log('❌ Customer Login navigation failed');
          }
          
        } catch (error) {
          console.log(`⚠️ Button click error: ${error.message}`);
        }
      }
      
      return false;
      
    } catch (error) {
      console.error('❌ Separated solution test error:', error);
      await this.page.screenshot({ path: 'test-results/separated_test_error.png', fullPage: true });
      return false;
    }
  }

  async run() {
    await this.setup();
    const success = await this.testSeparatedSolution();
    await this.cleanup();
    
    console.log(`\n🎯 Separated Solution Test Result: ${success ? '✅ SUCCESS' : '❌ FAILED'}`);
    return success;
  }

  async cleanup() {
    if (this.browser) {
      await this.browser.close();
      console.log('🔚 Separated solution test completed');
    }
  }
}

// Run the test
const separatedTest = new TestSeparatedSolution();
separatedTest.run().catch(console.error);
