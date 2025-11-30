const { chromium } = require('playwright');

(async () => {
  const browser = await chromium.launch();
  const page = await browser.newPage();
  
  try {
    await page.goto('http://localhost:8091');
    await page.waitForLoadState('networkidle');
    
    // Get page title
    const title = await page.title();
    console.log('Page title:', title);
    
    // Get page content
    const content = await page.content();
    console.log('Page content length:', content.length);
    
    // Get all text content
    const textContent = await page.textContent('body');
    console.log('Page text content:');
    console.log(textContent);
    
    // Take screenshot
    await page.screenshot({ path: 'page-screenshot.png' });
    console.log('Screenshot saved as page-screenshot.png');
    
  } catch (error) {
    console.error('Error:', error);
  } finally {
    await browser.close();
  }
})();
