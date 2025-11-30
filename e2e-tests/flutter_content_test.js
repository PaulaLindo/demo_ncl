// flutter_content_test.js - Test to check if Flutter app renders any content
const { chromium } = require('playwright');

class FlutterContentTest {
  constructor() {
    this.browser = null;
    this.page = null;
  }

  async setup() {
    console.log('🔍 Setting up Flutter Content Test...');
    this.browser = await chromium.launch({ 
      headless: false,
      slowMo: 1000 
    });
    this.page = await this.browser.newPage();
    await this.page.setViewportSize({ width: 1280, height: 720 });
    console.log('✅ Browser launched');
  }

  async testFlutterContent() {
    try {
      console.log('📍 Navigating to Flutter app...');
      await this.page.goto('http://localhost:8080');
      
      // Wait for Flutter to load
      await this.page.waitForTimeout(10000);
      
      // Try to find Flutter elements and their content
      const flutterAnalysis = await this.page.evaluate(() => {
        // Find all Flutter elements
        const flutterElements = Array.from(document.querySelectorAll('*')).filter(el => 
          el.tagName.toLowerCase().includes('flt') || 
          el.getAttribute('flt-renderer') !== null ||
          el.className && el.className.includes('flt')
        );
        
        // Try to get text from various selectors
        const getTextFromSelectors = (selectors) => {
          return selectors.map(selector => {
            const elements = Array.from(document.querySelectorAll(selector));
            return elements.map(el => ({
              selector: selector,
              text: el.innerText || el.textContent || '',
              visible: el.offsetParent !== null,
              tagName: el.tagName,
            }));
          }).flat();
        };
        
        // Common selectors for content
        const contentSelectors = [
          'div', 'span', 'p', 'h1', 'h2', 'h3', 'h4', 'h5', 'h6',
          'button', 'text', '.text', '*[role="button"]',
          'flt-text-pane', 'flt-semantic-text', 'flt-semantics-container'
        ];
        
        const allContent = getTextFromSelectors(contentSelectors);
        
        // Check for any rendered text
        const allText = document.body.innerText || document.body.textContent || '';
        
        return {
          flutterElementsCount: flutterElements.length,
          flutterElements: flutterElements.map(el => ({
            tagName: el.tagName,
            className: el.className,
            id: el.id,
            visible: el.offsetParent !== null,
            text: el.innerText || el.textContent || '',
          })),
          allContent: allContent.filter(item => item.text.length > 0),
          bodyText: allText,
          bodyHTML: document.body.innerHTML.substring(0, 2000),
          hasAnyText: allText.length > 0,
          hasVisibleContent: allContent.some(item => item.visible && item.text.length > 0),
        };
      });
      
      console.log('\n📊 Flutter Content Analysis:');
      console.log(`Flutter Elements: ${flutterAnalysis.flutterElementsCount}`);
      console.log(`Has Any Text: ${flutterAnalysis.hasAnyText ? '✅' : '❌'}`);
      console.log(`Has Visible Content: ${flutterAnalysis.hasVisibleContent ? '✅' : '❌'}`);
      console.log(`Body Text Length: ${flutterAnalysis.bodyText.length}`);
      
      if (flutterAnalysis.bodyText.length > 0) {
        console.log(`\n📄 Body Text:\n${flutterAnalysis.bodyText.substring(0, 500)}`);
      }
      
      console.log(`\n🏗️ Content Elements Found: ${flutterAnalysis.allContent.length}`);
      flutterAnalysis.allContent.forEach((item, index) => {
        if (item.text.length > 0) {
          console.log(`${index + 1}. ${item.tagName} (${item.selector}): "${item.text.substring(0, 50)}" | Visible: ${item.visible}`);
        }
      });
      
      console.log(`\n🔧 Flutter Elements Details:`);
      flutterAnalysis.flutterElements.forEach((item, index) => {
        console.log(`${index + 1}. ${item.tagName} | Visible: ${item.visible} | Text: "${item.text.substring(0, 50)}"`);
      });
      
      // Take screenshot
      await this.page.screenshot({ path: 'test-results/flutter_content_analysis.png', fullPage: true });
      
      // Try to interact with any visible elements
      if (flutterAnalysis.hasVisibleContent) {
        console.log('\n🖱️ Attempting to interact with visible elements...');
        
        for (const item of flutterAnalysis.allContent) {
          if (item.visible && item.text.length > 0) {
            try {
              console.log(`🖱️ Clicking on: ${item.text.substring(0, 30)}`);
              await this.page.click(item.selector);
              await this.page.waitForTimeout(3000);
              
              // Check if anything changed
              const afterClick = await this.page.evaluate(() => {
                return {
                  bodyText: document.body.innerText || document.body.textContent || '',
                  url: window.location.href,
                };
              });
              
              console.log(`📍 After click - URL: ${afterClick.url}`);
              console.log(`📄 After click - Text length: ${afterClick.bodyText.length}`);
              
              if (afterClick.bodyText.length > flutterAnalysis.bodyText.length) {
                console.log('✅ Content changed after click!');
                await this.page.screenshot({ path: 'test-results/flutter_after_click.png', fullPage: true });
                break;
              }
              
              // Go back for next attempt
              await this.page.goto('http://localhost:8080');
              await this.page.waitForTimeout(3000);
              
            } catch (error) {
              console.log(`⚠️ Error clicking ${item.selector}: ${error.message}`);
            }
          }
        }
      }
      
      // Try alternative approach - look for role-based buttons
      console.log('\n🔍 Looking for role-based buttons...');
      const roleButtons = await this.page.evaluate(() => {
        const allElements = Array.from(document.querySelectorAll('*'));
        const roleTexts = ['customer', 'staff', 'admin', 'login', 'sign in'];
        
        return allElements
          .filter(el => {
            const text = (el.innerText || el.textContent || '').toLowerCase();
            const hasRoleText = roleTexts.some(roleText => text.includes(roleText));
            const isClickable = el.onclick || el.getAttribute('onclick') || 
                               el.tagName === 'BUTTON' || 
                               el.getAttribute('role') === 'button';
            return hasRoleText && isClickable;
          })
          .map(el => ({
            tagName: el.tagName,
            text: el.innerText || el.textContent || '',
            className: el.className,
            id: el.id,
            role: el.getAttribute('role'),
            visible: el.offsetParent !== null,
          }));
      });
      
      console.log(`Found ${roleButtons.length} role-based buttons:`);
      roleButtons.forEach((btn, index) => {
        console.log(`${index + 1}. ${btn.tagName}: "${btn.text}" | Role: ${btn.role} | Visible: ${btn.visible}`);
      });
      
      if (roleButtons.length > 0) {
        console.log('\n🖱️ Clicking first role-based button...');
        try {
          await this.page.click('button, [role="button"]');
          await this.page.waitForTimeout(3000);
          await this.page.screenshot({ path: 'test-results/flutter_role_button_click.png', fullPage: true });
        } catch (error) {
          console.log(`⚠️ Error clicking role button: ${error.message}`);
        }
      }
      
    } catch (error) {
      console.error('❌ Content test error:', error);
      await this.page.screenshot({ path: 'test-results/flutter_content_error.png', fullPage: true });
    }
  }

  async run() {
    await this.setup();
    await this.testFlutterContent();
    await this.cleanup();
  }

  async cleanup() {
    if (this.browser) {
      await this.browser.close();
      console.log('🔚 Flutter content test completed');
    }
  }
}

// Run the test
const contentTest = new FlutterContentTest();
contentTest.run().catch(console.error);
