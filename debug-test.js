const { chromium } = require('playwright');

(async () => {
  const browser = await chromium.launch({ headless: false });
  const page = await browser.newPage();
  
  try {
    console.log('Navigating to http://localhost:8081...');
    await page.goto('http://localhost:8081');
    
    console.log('Waiting for page to load...');
    await page.waitForLoadState('networkidle');
    
    console.log('Taking screenshot...');
    await page.screenshot({ path: 'debug-screenshot.png' });
    
    console.log('Page title:', await page.title());
    console.log('Page content preview:');
    const content = await page.content();
    console.log(content.substring(0, 1000));
    
    // Wait for user to see the browser
    console.log('Browser opened. Press Enter to continue...');
    await new Promise(resolve => process.stdin.once('data', resolve));
    
  } catch (error) {
    console.error('Error:', error);
  } finally {
    await browser.close();
  }
})();
