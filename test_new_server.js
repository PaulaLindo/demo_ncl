const { chromium } = require('playwright');

(async () => {
  const browser = await chromium.launch();
  const page = await browser.newPage();
  
  try {
    await page.goto('http://localhost:8093');
    
    // Wait for the app to load
    await page.waitForTimeout(5000);
    
    // Get page title
    const title = await page.title();
    console.log('Page title:', title);
    
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
    
  } catch (error) {
    console.error('Error:', error);
  } finally {
    await browser.close();
  }
})();
