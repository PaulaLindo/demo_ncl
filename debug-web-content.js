const { chromium } = require('playwright');

async function debugWebContent() {
  const browser = await chromium.launch();
  const page = await browser.newPage();
  
  try {
    console.log('🌐 Navigating to http://localhost:8082...');
    await page.goto('http://localhost:8082');
    
    // Wait for page to load
    await page.waitForTimeout(5000);
    
    console.log('📄 Page title:', await page.title());
    console.log('📄 Page URL:', page.url());
    
    // Get all text content
    const allText = await page.textContent('body');
    console.log('📄 All page text:');
    console.log(allText);
    
    // Get all visible text
    const visibleText = await page.evaluate(() => {
      return document.body.innerText;
    });
    console.log('📄 Visible text:');
    console.log(visibleText);
    
    // Check for Flutter app elements
    const flutterElements = await page.$$('flt-glass-pane, flt-scene, canvas');
    console.log('📱 Flutter elements found:', flutterElements.length);
    
    // Take a screenshot
    await page.screenshot({ path: 'debug-screenshot.png', fullPage: true });
    console.log('📸 Screenshot saved as debug-screenshot.png');
    
  } catch (error) {
    console.error('❌ Error:', error);
  } finally {
    await browser.close();
  }
}

debugWebContent();
