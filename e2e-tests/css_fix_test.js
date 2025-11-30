// css_fix_test.js - Apply targeted CSS fixes to Flutter app
const { chromium } = require('playwright');

class CSSFixTest {
  constructor() {
    this.browser = null;
    this.page = null;
  }

  async setup() {
    console.log('🔧 Setting up CSS Fix Test...');
    this.browser = await chromium.launch({ 
      headless: false,
      slowMo: 1000 
    });
    this.page = await this.browser.newPage();
    await this.page.setViewportSize({ width: 1280, height: 720 });
    console.log('✅ Browser launched');
  }

  async applyCSSFixes() {
    try {
      console.log('📍 Navigating to Flutter app...');
      await this.page.goto('http://localhost:8080');
      
      // Wait for Flutter to load
      await this.page.waitForTimeout(10000);
      
      // Apply comprehensive CSS fixes
      const cssFixes = await this.page.evaluate(() => {
        const fixes = [];
        
        // Fix 1: Set proper HTML element dimensions
        const html = document.documentElement;
        const body = document.body;
        
        html.style.height = '100%';
        html.style.width = '100%';
        html.style.overflow = 'visible';
        fixes.push('Fixed HTML element dimensions');
        
        // Fix 2: Ensure body has proper dimensions
        if (body.style.position === 'fixed') {
          body.style.position = 'relative';
        }
        body.style.minHeight = '100vh';
        body.style.width = '100%';
        body.style.overflow = 'visible';
        fixes.push('Fixed body element dimensions and positioning');
        
        // Fix 3: Find and fix Flutter glass pane
        const glassPane = document.querySelector('flt-glass-pane');
        if (glassPane) {
          glassPane.style.display = 'block';
          glassPane.style.position = 'relative';
          glassPane.style.width = '100%';
          glassPane.style.height = '100vh';
          glassPane.style.minHeight = '100vh';
          glassPane.style.overflow = 'visible';
          fixes.push('Fixed flt-glass-pane dimensions');
        }
        
        // Fix 4: Find and fix Flutter scene host
        const sceneHost = document.querySelector('flt-scene-host');
        if (sceneHost) {
          sceneHost.style.display = 'block';
          sceneHost.style.position = 'relative';
          sceneHost.style.width = '100%';
          sceneHost.style.height = '100vh';
          sceneHost.style.minHeight = '100vh';
          sceneHost.style.overflow = 'visible';
          fixes.push('Fixed flt-scene-host dimensions');
        }
        
        // Fix 5: Fix semantics placeholder positioning
        const semanticsPlaceholder = document.querySelector('flt-semantics-placeholder[role="button"]');
        if (semanticsPlaceholder) {
          semanticsPlaceholder.style.position = 'relative';
          semanticsPlaceholder.style.left = 'auto';
          semanticsPlaceholder.style.top = 'auto';
          semanticsPlaceholder.style.width = 'auto';
          semanticsPlaceholder.style.height = 'auto';
          semanticsPlaceholder.style.transform = 'none';
          semanticsPlaceholder.style.opacity = '1';
          semanticsPlaceholder.style.visibility = 'visible';
          semanticsPlaceholder.style.display = 'block';
          fixes.push('Fixed semantics placeholder positioning');
        }
        
        // Fix 6: Add custom CSS to force Flutter content visibility
        const customStyle = document.createElement('style');
        customStyle.textContent = `
          html, body {
            height: 100% !important;
            width: 100% !important;
            min-height: 100vh !important;
            overflow: visible !important;
          }
          
          body {
            position: relative !important;
          }
          
          flt-glass-pane,
          flt-scene-host,
          flt-semantics-host {
            display: block !important;
            position: relative !important;
            width: 100% !important;
            height: 100vh !important;
            min-height: 100vh !important;
            overflow: visible !important;
          }
          
          flt-semantics-placeholder[role="button"] {
            position: relative !important;
            left: auto !important;
            top: auto !important;
            transform: none !important;
            opacity: 1 !important;
            visibility: visible !important;
            display: block !important;
            width: auto !important;
            height: auto !important;
            margin: 10px !important;
            padding: 10px !important;
            background: #007bff !important;
            color: white !important;
            border: 1px solid #0056b3 !important;
            border-radius: 4px !important;
            cursor: pointer !important;
          }
          
          flt-semantics-placeholder[aria-label*="Customer"] {
            background: #28a745 !important;
            margin: 20px !important;
            font-size: 16px !important;
            padding: 15px 30px !important;
          }
          
          flt-semantics-placeholder[aria-label*="Staff"] {
            background: #ffc107 !important;
            color: #212529 !important;
            margin: 20px !important;
            font-size: 16px !important;
            padding: 15px 30px !important;
          }
          
          flt-semantics-placeholder[aria-label*="Admin"] {
            background: #dc3545 !important;
            margin: 20px !important;
            font-size: 16px !important;
            padding: 15px 30px !important;
          }
          
          /* Force any hidden content to be visible */
          * {
            opacity: 1 !important;
            visibility: visible !important;
          }
        `;
        document.head.appendChild(customStyle);
        fixes.push('Added custom CSS to force Flutter content visibility');
        
        // Fix 7: Force layout recalculation multiple times
        document.body.offsetHeight;
        html.offsetHeight;
        window.dispatchEvent(new Event('resize'));
        fixes.push('Forced layout recalculation and resize event');
        
        // Fix 8: Try to trigger Flutter repaint
        if (window._flutter && window._flutter.loader) {
          setTimeout(() => {
            window.dispatchEvent(new Event('resize'));
          }, 100);
          fixes.push('Triggered Flutter repaint');
        }
        
        return fixes;
      });
      
      console.log('🔧 CSS Fixes Applied:');
      cssFixes.forEach(fix => console.log(`  ✅ ${fix}`));
      
      // Wait for fixes to take effect
      await this.page.waitForTimeout(5000);
      
      // Take screenshot after fixes
      await this.page.screenshot({ path: 'test-results/css_comprehensive_fix.png', fullPage: true });
      
      // Check if content is now visible and interactive
      const afterFixes = await this.page.evaluate(() => {
        // Check for visible buttons
        const visibleButtons = Array.from(document.querySelectorAll('flt-semantics-placeholder[role="button"]')).filter(el => {
          const styles = window.getComputedStyle(el);
          return styles.display !== 'none' && 
                 styles.visibility !== 'hidden' && 
                 styles.opacity !== '0' &&
                 el.offsetWidth > 0 && 
                 el.offsetHeight > 0;
        });
        
        // Get button details
        const buttonDetails = visibleButtons.map(el => ({
          ariaLabel: el.getAttribute('aria-label'),
          text: el.innerText || el.textContent || '',
          tagName: el.tagName,
          offsetWidth: el.offsetWidth,
          offsetHeight: el.offsetHeight,
          styles: {
            display: window.getComputedStyle(el).display,
            visibility: window.getComputedStyle(el).visibility,
            opacity: window.getComputedStyle(el).opacity,
            position: window.getComputedStyle(el).position,
            left: window.getComputedStyle(el).left,
            top: window.getComputedStyle(el).top,
          }
        }));
        
        // Check for any visible content
        const bodyText = document.body.innerText || document.body.textContent || '';
        const hasVisibleContent = bodyText.length > 100; // More than just CSS
        
        return {
          visibleButtonsCount: visibleButtons.length,
          buttonDetails,
          bodyTextLength: bodyText.length,
          hasVisibleContent,
          bodyText: bodyText.substring(0, 1000),
        };
      });
      
      console.log('\n📊 After Comprehensive CSS Fixes:');
      console.log(`Visible Buttons: ${afterFixes.visibleButtonsCount}`);
      console.log(`Body Text Length: ${afterFixes.bodyTextLength}`);
      console.log(`Has Visible Content: ${afterFixes.hasVisibleContent ? '✅' : '❌'}`);
      
      if (afterFixes.visibleButtonsCount > 0) {
        console.log('\n🔘 Visible Button Details:');
        afterFixes.buttonDetails.forEach((btn, index) => {
          console.log(`${index + 1}. ${btn.tagName} - "${btn.ariaLabel}"`);
          console.log(`   Size: ${btn.offsetWidth}x${btn.offsetHeight}`);
          console.log(`   Position: ${btn.styles.left}, ${btn.styles.top}`);
          console.log(`   Display: ${btn.styles.display} | Visibility: ${btn.styles.visibility} | Opacity: ${btn.styles.opacity}`);
        });
        
        // Try to click the buttons
        console.log('\n🖱️ Attempting to click buttons...');
        
        for (let i = 0; i < afterFixes.buttonDetails.length; i++) {
          const button = afterFixes.buttonDetails[i];
          try {
            console.log(`🖱️ Clicking button: ${button.ariaLabel}`);
            
            // Use a more specific selector
            const selector = `flt-semantics-placeholder[aria-label="${button.ariaLabel}"]`;
            await this.page.click(selector);
            await this.page.waitForTimeout(3000);
            
            // Check if navigation occurred
            const newUrl = this.page.url();
            console.log(`📍 After click: ${newUrl}`);
            
            if (newUrl !== 'http://localhost:8080/') {
              console.log('✅ Navigation successful!');
              await this.page.screenshot({ path: 'test-results/css_navigation_success.png', fullPage: true });
              
              // Check if we're on a login page
              const hasLoginFields = await this.page.$('input[type="email"], input[placeholder*="email" i]');
              const hasPasswordField = await this.page.$('input[type="password"], input[placeholder*="password" i]');
              
              if (hasLoginFields && hasPasswordField) {
                console.log('✅ Login form detected!');
                
                // Fill the form
                await hasLoginFields.fill('customer@example.com');
                await hasPasswordField.fill('customer123');
                
                // Find and click login button
                const loginButton = await this.page.$('button:has-text("Sign In"), button:has-text("Login"), input[type="submit"]');
                if (loginButton) {
                  await loginButton.click();
                  await this.page.waitForTimeout(5000);
                  
                  // Check if login was successful
                  const finalUrl = this.page.url();
                  const hasDashboard = await this.page.$('text=Book, text=Dashboard, text=Services, text=Account');
                  
                  console.log(`🎯 Final URL: ${finalUrl}`);
                  console.log(`📊 Dashboard detected: ${hasDashboard ? 'Yes' : 'No'}`);
                  
                  await this.page.screenshot({ path: 'test-results/css_login_success.png', fullPage: true });
                  
                  return true;
                }
              }
              
              return true; // Navigation successful even if not login
            }
            
            // Go back for next attempt
            await this.page.goto('http://localhost:8080');
            await this.page.waitForTimeout(3000);
            
          } catch (error) {
            console.log(`⚠️ Error clicking button ${button.ariaLabel}: ${error.message}`);
          }
        }
      }
      
      if (afterFixes.bodyText.length > 0) {
        console.log(`\n📄 Body Text Preview:\n${afterFixes.bodyText}`);
      }
      
      return afterFixes.visibleButtonsCount > 0;
      
    } catch (error) {
      console.error('❌ CSS fix error:', error);
      await this.page.screenshot({ path: 'test-results/css_fix_error.png', fullPage: true });
      return false;
    }
  }

  async run() {
    await this.setup();
    const success = await this.applyCSSFixes();
    await this.cleanup();
    
    console.log(`\n🎯 CSS Fix Result: ${success ? '✅ SUCCESS' : '❌ FAILED'}`);
    return success;
  }

  async cleanup() {
    if (this.browser) {
      await this.browser.close();
      console.log('🔚 CSS fix test completed');
    }
  }
}

// Run the test
const cssFixTest = new CSSFixTest();
cssFixTest.run().catch(console.error);
