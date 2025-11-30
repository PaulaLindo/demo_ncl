const { chromium } = require('playwright');

async function debugFlutterElements() {
  const browser = await chromium.launch();
  const page = await browser.newPage();
  
  try {
    console.log('🌐 Navigating to http://localhost:8082...');
    await page.goto('http://localhost:8082');
    
    // Wait for Flutter app to load
    await page.waitForTimeout(10000);
    
    console.log('📄 Page title:', await page.title());
    
    // Get all text content using different methods
    console.log('\n=== METHOD 1: document.body.innerText ===');
    const bodyText = await page.evaluate(() => document.body.innerText);
    console.log('Body text:', bodyText);
    
    console.log('\n=== METHOD 2: document.body.textContent ===');
    const bodyContent = await page.evaluate(() => document.body.textContent);
    console.log('Body content:', bodyContent);
    
    console.log('\n=== METHOD 3: All text nodes ===');
    const allTextNodes = await page.evaluate(() => {
      const walker = document.createTreeWalker(
        document.body,
        NodeFilter.SHOW_TEXT,
        null,
        false
      );
      const textNodes = [];
      let node;
      while (node = walker.nextNode()) {
        if (node.textContent.trim()) {
          textNodes.push(node.textContent.trim());
        }
      }
      return textNodes;
    });
    console.log('All text nodes:', allTextNodes);
    
    console.log('\n=== METHOD 4: Flutter-specific elements ===');
    const flutterElements = await page.evaluate(() => {
      const elements = [];
      // Check for various Flutter web element types
      const selectors = [
        'flt-glass-pane',
        'flt-scene',
        'flt-canvas-container',
        'canvas',
        'flutter-view',
        '[role="button"]',
        'button',
        '.text',
        'span',
        'div'
      ];
      
      for (const selector of selectors) {
        const els = document.querySelectorAll(selector);
        if (els.length > 0) {
          elements.push({
            selector: selector,
            count: els.length,
            texts: Array.from(els).map(el => el.textContent || el.innerText || '').filter(t => t.trim())
          });
        }
      }
      return elements;
    });
    console.log('Flutter elements:', JSON.stringify(flutterElements, null, 2));
    
    console.log('\n=== METHOD 5: Try to find specific text ===');
    const specificTexts = ['Welcome to NCL', 'Customer Login', 'Staff Access', 'Admin Portal'];
    for (const text of specificTexts) {
      try {
        const element = await page.locator(`text=${text}`).first();
        const isVisible = await element.isVisible({ timeout: 1000 });
        console.log(`"${text}": ${isVisible ? 'VISIBLE' : 'NOT VISIBLE'}`);
      } catch (e) {
        console.log(`"${text}": NOT FOUND`);
      }
    }
    
    // Take screenshot
    await page.screenshot({ path: 'debug-detailed-screenshot.png', fullPage: true });
    console.log('\n📸 Screenshot saved as debug-detailed-screenshot.png');
    
  } catch (error) {
    console.error('❌ Error:', error);
  } finally {
    await browser.close();
  }
}

debugFlutterElements();
