const { chromium } = require('playwright');

(async () => {
  const browser = await chromium.launch();
  const page = await browser.newPage();
  
  // Listen for all console messages
  page.on('console', msg => {
    console.log(`CONSOLE [${msg.type()}]:`, msg.text());
  });
  
  page.on('pageerror', error => {
    console.log('PAGE ERROR:', error.message);
    console.log('ERROR STACK:', error.stack);
  });
  
  page.on('requestfailed', request => {
    console.log('REQUEST FAILED:', request.url(), request.failure());
  });
  
  try {
    console.log('Navigating to http://localhost:8093...');
    await page.goto('http://localhost:8093', { waitUntil: 'networkidle' });
    
    // Wait longer for Flutter to initialize
    console.log('Waiting 10 seconds for Flutter to initialize...');
    await page.waitForTimeout(10000);
    
    // Check if Flutter app element exists
    const flutterApp = await page.locator('flutter-view').first();
    const appExists = await flutterApp.count();
    console.log(`Flutter app element found: ${appExists > 0}`);
    
    if (appExists > 0) {
      // Get Flutter app dimensions
      const boundingBox = await flutterApp.boundingBox();
      console.log('Flutter app dimensions:', boundingBox);
      
      // Check if it's visible
      const isVisible = await flutterApp.isVisible();
      console.log('Flutter app is visible:', isVisible);
      
      // Look for any text inside the Flutter app
      const appText = await flutterApp.textContent();
      console.log('Flutter app text content:', appText);
      
      // Look for semantic elements
      const semanticElements = await page.locator('flt-semantics-host').all();
      console.log(`Found ${semanticElements.length} semantic elements`);
      
      // Look for canvas elements (Flutter rendering)
      const canvasElements = await page.locator('canvas').all();
      console.log(`Found ${canvasElements.length} canvas elements`);
      
      // Check for any script errors
      const scripts = await page.locator('script').all();
      console.log(`Found ${scripts.length} script elements`);
      
      // Check main.dart.js is loaded
      const mainScript = await page.locator('script[src*="main.dart.js"]').count();
      console.log(`Main Dart script found: ${mainScript > 0}`);
    }
    
    // Take screenshot
    await page.screenshot({ path: 'debug-ui-rendering.png', fullPage: true });
    console.log('Screenshot saved as debug-ui-rendering.png');
    
    // Get page HTML structure
    const bodyHTML = await page.locator('body').innerHTML();
    console.log('Body HTML length:', bodyHTML.length);
    console.log('Body HTML preview:', bodyHTML.substring(0, 500));
    
  } catch (error) {
    console.error('Error during debugging:', error);
  } finally {
    await browser.close();
  }
})();
