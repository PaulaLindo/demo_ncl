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
    
    // Wait a bit for the app to load
    await page.waitForTimeout(5000);
    
    // Get page title
    const title = await page.title();
    console.log('Page title:', title);
    
    // Get all text content
    const textContent = await page.textContent('body');
    console.log('Page text content:');
    console.log(textContent);
    
    // Check for login elements
    const welcomeText = await page.locator('body').textContent();
    if (welcomeText && welcomeText.includes('Welcome')) {
      console.log('✅ Found welcome text - app is working!');
    }
    
  } catch (error) {
    console.error('Error:', error);
  } finally {
    await browser.close();
  }
})();
