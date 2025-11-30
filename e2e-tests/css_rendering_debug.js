// css_rendering_debug.js - Debug CSS rendering issues in Flutter app
const { chromium } = require('playwright');

class CSSRenderingDebugger {
  constructor() {
    this.browser = null;
    this.page = null;
  }

  async setup() {
    console.log('🔍 Setting up CSS Rendering Debugger...');
    this.browser = await chromium.launch({ 
      headless: false,
      slowMo: 1000 
    });
    this.page = await this.browser.newPage();
    
    // Set up console logging for CSS issues
    this.page.on('console', msg => {
      if (msg.type() === 'error' || msg.type() === 'warning') {
        console.log(`📝 Browser ${msg.type().toUpperCase()}: ${msg.text()}`);
      }
    });
    
    await this.page.setViewportSize({ width: 1280, height: 720 });
    console.log('✅ Browser launched with CSS monitoring');
  }

  async debugCSSRendering() {
    try {
      console.log('📍 Navigating to Flutter app...');
      await this.page.goto('http://localhost:8080');
      
      // Wait for Flutter to load
      await this.page.waitForTimeout(10000);
      
      // Analyze the complete HTML structure
      const htmlAnalysis = await this.page.evaluate(() => {
        // Get the complete HTML
        const htmlContent = document.documentElement.outerHTML;
        
        // Get all computed styles for the body
        const bodyStyles = window.getComputedStyle(document.body);
        
        // Get all stylesheets
        const styleSheets = Array.from(document.styleSheets).map(sheet => {
          try {
            return {
              href: sheet.href,
              rules: sheet.cssRules ? sheet.cssRules.length : 0,
              disabled: sheet.disabled,
            };
          } catch (e) {
            return { href: sheet.href, error: e.message, disabled: sheet.disabled };
          }
        });
        
        // Get all style elements
        const styleElements = Array.from(document.querySelectorAll('style')).map(style => ({
          content: style.textContent.substring(0, 500),
          sheet: style.sheet ? { rules: style.sheet.cssRules.length } : null,
        }));
        
        // Analyze Flutter elements specifically
        const flutterElements = Array.from(document.querySelectorAll('*')).filter(el => 
          el.tagName.toLowerCase().includes('flt') || 
          el.getAttribute('flt-renderer') !== null ||
          el.className && el.className.includes('flt')
        );
        
        const flutterElementDetails = flutterElements.map(el => {
          const styles = window.getComputedStyle(el);
          return {
            tagName: el.tagName,
            className: el.className,
            id: el.id,
            display: styles.display,
            visibility: styles.visibility,
            opacity: styles.opacity,
            zIndex: styles.zIndex,
            position: styles.position,
            width: styles.width,
            height: styles.height,
            top: styles.top,
            left: styles.left,
            transform: styles.transform,
            offsetParent: el.offsetParent ? el.offsetParent.tagName : null,
            offsetWidth: el.offsetWidth,
            offsetHeight: el.offsetHeight,
            clientWidth: el.clientWidth,
            clientHeight: el.clientHeight,
            scrollWidth: el.scrollWidth,
            scrollHeight: el.scrollHeight,
          };
        });
        
        // Check for any visible elements
        const allVisibleElements = Array.from(document.querySelectorAll('*')).filter(el => {
          const styles = window.getComputedStyle(el);
          return styles.display !== 'none' && 
                 styles.visibility !== 'hidden' && 
                 styles.opacity !== '0' &&
                 el.offsetWidth > 0 && 
                 el.offsetHeight > 0;
        });
        
        // Get computed styles for key containers
        const containerStyles = {};
        ['body', 'html', 'flt-glass-pane', 'flt-scene-host'].forEach(selector => {
          const element = document.querySelector(selector);
          if (element) {
            const styles = window.getComputedStyle(element);
            containerStyles[selector] = {
              display: styles.display,
              visibility: styles.visibility,
              opacity: styles.opacity,
              position: styles.position,
              width: styles.width,
              height: styles.height,
              overflow: styles.overflow,
              transform: styles.transform,
            };
          }
        });
        
        return {
          htmlLength: htmlContent.length,
          bodyStyles: {
            display: bodyStyles.display,
            visibility: bodyStyles.visibility,
            opacity: bodyStyles.opacity,
            position: bodyStyles.position,
            width: bodyStyles.width,
            height: bodyStyles.height,
            margin: bodyStyles.margin,
            padding: bodyStyles.padding,
            overflow: bodyStyles.overflow,
          },
          styleSheets,
          styleElements: styleElements.length,
          flutterElementsCount: flutterElements.length,
          flutterElementDetails,
          visibleElementsCount: allVisibleElements.length,
          containerStyles,
          bodyHTML: document.body.innerHTML.substring(0, 2000),
        };
      });
      
      console.log('\n📊 CSS Rendering Analysis:');
      console.log(`HTML Length: ${htmlAnalysis.htmlLength} chars`);
      console.log(`Style Sheets: ${htmlAnalysis.styleSheets.length}`);
      console.log(`Style Elements: ${htmlAnalysis.styleElements}`);
      console.log(`Flutter Elements: ${htmlAnalysis.flutterElementsCount}`);
      console.log(`Visible Elements: ${htmlAnalysis.visibleElementsCount}`);
      
      console.log('\n🎨 Body Styles:');
      Object.entries(htmlAnalysis.bodyStyles).forEach(([key, value]) => {
        console.log(`  ${key}: ${value}`);
      });
      
      console.log('\n🏗️ Container Styles:');
      Object.entries(htmlAnalysis.containerStyles).forEach(([selector, styles]) => {
        console.log(`\n${selector}:`);
        Object.entries(styles).forEach(([prop, value]) => {
          console.log(`  ${prop}: ${value}`);
        });
      });
      
      console.log('\n🔧 Flutter Element Details:');
      htmlAnalysis.flutterElementDetails.forEach((el, index) => {
        console.log(`\n${index + 1}. ${el.tagName} (${el.className || el.id || 'no class/id'})`);
        console.log(`  Display: ${el.display} | Visibility: ${el.visibility} | Opacity: ${el.opacity}`);
        console.log(`  Position: ${el.position} | Z-Index: ${el.zIndex}`);
        console.log(`  Size: ${el.offsetWidth}x${el.offsetHeight} (client: ${el.clientWidth}x${el.clientHeight})`);
        console.log(`  Location: ${el.left}, ${el.top}`);
        console.log(`  Transform: ${el.transform}`);
        console.log(`  Offset Parent: ${el.offsetParent}`);
      });
      
      // Check for potential CSS issues
      console.log('\n🚨 Potential CSS Issues:');
      
      if (htmlAnalysis.bodyStyles.height === '0px' || htmlAnalysis.bodyStyles.height === 'auto') {
        console.log('❌ Body height is 0px or auto - content may not be visible');
      }
      
      if (htmlAnalysis.bodyStyles.width === '0px') {
        console.log('❌ Body width is 0px - content may not be visible');
      }
      
      if (htmlAnalysis.bodyStyles.display === 'none') {
        console.log('❌ Body display is none - content is hidden');
      }
      
      if (htmlAnalysis.bodyStyles.visibility === 'hidden') {
        console.log('❌ Body visibility is hidden - content is hidden');
      }
      
      if (htmlAnalysis.flutterElementDetails.some(el => el.display === 'none')) {
        console.log('❌ Some Flutter elements have display: none');
      }
      
      if (htmlAnalysis.flutterElementDetails.some(el => el.opacity === '0')) {
        console.log('❌ Some Flutter elements have opacity: 0');
      }
      
      if (htmlAnalysis.flutterElementDetails.some(el => el.offsetWidth === 0 || el.offsetHeight === 0)) {
        console.log('❌ Some Flutter elements have zero dimensions');
      }
      
      // Try to fix common CSS issues
      console.log('\n🔧 Attempting to fix CSS issues...');
      
      const fixAttempts = await this.page.evaluate(() => {
        const fixes = [];
        
        // Try to ensure body has proper dimensions
        const body = document.body;
        const html = document.documentElement;
        
        if (window.getComputedStyle(body).height === '0px' || window.getComputedStyle(body).height === 'auto') {
          body.style.minHeight = '100vh';
          html.style.height = '100%';
          fixes.push('Set body min-height to 100vh and html height to 100%');
        }
        
        // Try to ensure Flutter glass pane is visible
        const glassPane = document.querySelector('flt-glass-pane');
        if (glassPane) {
          const styles = window.getComputedStyle(glassPane);
          if (styles.display === 'none') {
            glassPane.style.display = 'block';
            fixes.push('Set flt-glass-pane display to block');
          }
          if (styles.visibility === 'hidden') {
            glassPane.style.visibility = 'visible';
            fixes.push('Set flt-glass-pane visibility to visible');
          }
        }
        
        // Try to force layout recalculation
        document.body.offsetHeight;
        fixes.push('Forced layout recalculation');
        
        return fixes;
      });
      
      console.log('🔧 CSS Fixes Applied:');
      fixAttempts.forEach(fix => console.log(`  ✅ ${fix}`));
      
      // Wait a moment for changes to take effect
      await this.page.waitForTimeout(3000);
      
      // Take screenshot after fixes
      await this.page.screenshot({ path: 'test-results/css_after_fixes.png', fullPage: true });
      
      // Check if content is now visible
      const afterFixes = await this.page.evaluate(() => {
        const visibleElements = Array.from(document.querySelectorAll('*')).filter(el => {
          const styles = window.getComputedStyle(el);
          return styles.display !== 'none' && 
                 styles.visibility !== 'hidden' && 
                 styles.opacity !== '0' &&
                 el.offsetWidth > 0 && 
                 el.offsetHeight > 0;
        });
        
        const bodyText = document.body.innerText || document.body.textContent || '';
        
        return {
          visibleElementsCount: visibleElements.length,
          bodyTextLength: bodyText.length,
          bodyText: bodyText.substring(0, 500),
          hasButtons: visibleElements.some(el => el.tagName === 'BUTTON'),
          hasText: visibleElements.some(el => (el.innerText || el.textContent || '').length > 10),
        };
      });
      
      console.log('\n📊 After CSS Fixes:');
      console.log(`Visible Elements: ${afterFixes.visibleElementsCount}`);
      console.log(`Body Text Length: ${afterFixes.bodyTextLength}`);
      console.log(`Has Buttons: ${afterFixes.hasButtons ? '✅' : '❌'}`);
      console.log(`Has Text: ${afterFixes.hasText ? '✅' : '❌'}`);
      
      if (afterFixes.bodyTextLength > 0) {
        console.log(`\n📄 Body Text Preview:\n${afterFixes.bodyText}`);
      }
      
      // Try to find and click any interactive elements
      if (afterFixes.hasButtons || afterFixes.hasText) {
        console.log('\n🖱️ Attempting to interact with elements...');
        
        try {
          // Look for any clickable elements
          const clickableSelectors = [
            'button',
            '[role="button"]',
            'flt-semantics-placeholder[role="button"]',
            '*:has-text("Customer")',
            '*:has-text("Staff")',
            '*:has-text("Admin")',
            '*:has-text("Login")'
          ];
          
          for (const selector of clickableSelectors) {
            try {
              const element = await this.page.$(selector);
              if (element) {
                console.log(`✅ Found clickable element: ${selector}`);
                await element.click();
                await this.page.waitForTimeout(3000);
                
                // Check if navigation occurred
                const newUrl = this.page.url();
                console.log(`📍 After click: ${newUrl}`);
                
                if (newUrl !== 'http://localhost:8080/') {
                  console.log('✅ Navigation successful!');
                  await this.page.screenshot({ path: 'test-results/css_navigation_success.png', fullPage: true });
                  return true;
                }
                
                // Go back for next attempt
                await this.page.goto('http://localhost:8080');
                await this.page.waitForTimeout(3000);
              }
            } catch (e) {
              console.log(`⚠️ Error with selector ${selector}: ${e.message}`);
            }
          }
        } catch (error) {
          console.log(`❌ Interaction error: ${error.message}`);
        }
      }
      
    } catch (error) {
      console.error('❌ CSS debugging error:', error);
      await this.page.screenshot({ path: 'test-results/css_debug_error.png', fullPage: true });
    }
  }

  async run() {
    await this.setup();
    await this.debugCSSRendering();
    await this.cleanup();
  }

  async cleanup() {
    if (this.browser) {
      await this.browser.close();
      console.log('🔚 CSS rendering debugging completed');
    }
  }
}

// Run the debugger
const cssDebugger = new CSSRenderingDebugger();
cssDebugger.run().catch(console.error);
