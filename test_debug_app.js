const { chromium } = require('playwright');

(async () => {
  const browser = await chromium.launch();
  const page = await browser.newPage();
  
  // Listen for console messages
  page.on('console', msg => {
    console.log(`CONSOLE [${msg.type()}]:`, msg.text());
  });
  
  page.on('pageerror', error => {
    console.log('PAGE ERROR:', error.message);
  });
  
  try {
    console.log('Testing debug app on http://localhost:8095...');
    await page.goto('http://localhost:8095');
    
    // Wait for the app to load
    console.log('Waiting 5 seconds for app to initialize...');
    await page.waitForTimeout(5000);
    
    // Look for the debug content
    const welcomeText = await page.locator('text=Welcome to NCL').first();
    const welcomeExists = await welcomeText.count();
    console.log(`Welcome text found: ${welcomeExists > 0}`);
    
    if (welcomeExists > 0) {
      const welcomeTextContent = await welcomeText.textContent();
      console.log('Welcome text content:', welcomeTextContent);
    }
    
    // Look for all text content
    const allText = await page.textContent('body');
    console.log('All page text:');
    console.log(allText);
    
    // Take screenshot
    await page.screenshot({ path: 'debug-app-screenshot.png' });
    console.log('Screenshot saved as debug-app-screenshot.png');
    
  } catch (error) {
    console.error('Error:', error);
  } finally {
    await browser.close();
  }
})();
