const { chromium } = require('playwright');

(async () => {
  console.log('Starting simple web test...');
  
  const browser = await chromium.launch({ 
    headless: false,
    slowMo: 1000 // Slow down actions for better observation
  });
  
  try {
    const page = await browser.newPage();
    
    // Enable console logging
    page.on('console', msg => console.log('PAGE LOG:', msg.text()));
    page.on('pageerror', err => console.log('PAGE ERROR:', err.message));
    
    console.log('Navigating to http://localhost:8081...');
    await page.goto('http://localhost:8081', { 
      waitUntil: 'networkidle',
      timeout: 60000 
    });
    
    console.log('Page loaded. Waiting for Flutter app to initialize...');
    
    // Wait for the Flutter app to load (look for common Flutter indicators)
    try {
      await page.waitForSelector('body', { timeout: 10000 });
      console.log('Body element found');
      
      // Wait a bit more for Flutter to render
      await page.waitForTimeout(5000);
      
      // Take a screenshot
      await page.screenshot({ path: 'flutter-app-loaded.png', fullPage: true });
      console.log('Screenshot saved as flutter-app-loaded.png');
      
      // Check page content
      const title = await page.title();
      console.log('Page title:', title);
      
      // Look for any text content
      const bodyText = await page.evaluate(() => document.body.innerText);
      console.log('Page text content preview:', bodyText.substring(0, 200));
      
      // Look for Flutter-specific elements
      const flutterApp = await page.$('flutter-view');
      if (flutterApp) {
        console.log('Flutter app element found!');
      } else {
        console.log('Flutter app element not found, checking for other indicators...');
        
        // Look for any canvas elements (Flutter uses canvas for rendering)
        const canvas = await page.$('canvas');
        if (canvas) {
          console.log('Canvas element found (Flutter might be rendering)');
        }
        
        // Look for script tags that indicate Flutter is loading
        const scripts = await page.$$eval('script', scripts => 
          scripts.map(s => s.src || s.textContent).filter(Boolean)
        );
        console.log('Scripts found:', scripts.length);
        
        // Check if flutter_bootstrap.js is loaded
        const flutterScript = scripts.find(s => s.includes('flutter_bootstrap'));
        if (flutterScript) {
          console.log('Flutter bootstrap script found');
        }
      }
      
      // Keep browser open for inspection
      console.log('Test completed. Browser will remain open for 30 seconds for inspection...');
      await page.waitForTimeout(30000);
      
    } catch (error) {
      console.error('Error during page interaction:', error);
      await page.screenshot({ path: 'error-screenshot.png' });
    }
    
  } catch (error) {
    console.error('Error:', error);
  } finally {
    await browser.close();
  }
})();
