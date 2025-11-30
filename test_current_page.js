const { chromium } = require('playwright');

(async () => {
  const browser = await chromium.launch();
  const page = await browser.newPage();
  
  // Listen for console messages
  page.on('console', msg => {
    console.log('CONSOLE:', msg.type(), msg.text());
  });
  
  page.on('pageerror', error => {
    console.log('PAGE ERROR:', error.message);
  });
  
  try {
    await page.goto('http://localhost:8092');
    
    // Wait for the app to load
    await page.waitForTimeout(5000);
    
    // Get page title
    const title = await page.title();
    console.log('Page title:', title);
    
    // Try to find any text content
    const bodyText = await page.textContent('body');
    console.log('Body text content:');
    console.log(bodyText);
    
    // Look for any visible text elements
    const textElements = await page.locator('*:visible').all();
    console.log(`Found ${textElements.length} visible elements`);
    
    for (let i = 0; i < Math.min(textElements.length, 10); i++) {
      const element = textElements[i];
      const text = await element.textContent();
      if (text && text.trim().length > 0) {
        console.log(`Element ${i}: "${text.trim()}"`);
      }
    }
    
    // Take screenshot
    await page.screenshot({ path: 'current-page.png' });
    console.log('Screenshot saved as current-page.png');
    
  } catch (error) {
    console.error('Error:', error);
  } finally {
    await browser.close();
  }
})();
