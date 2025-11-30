// flutter_aware_test.js - Wait for Flutter to fully render
const { chromium } = require('playwright');

async function runFlutterAwareTest() {
  console.log('🚀 Starting Flutter-aware test...');
  
  const browser = await chromium.launch({ headless: false });
  const page = await browser.newPage();
  
  try {
    await page.goto('http://localhost:8080');
    
    // Wait much longer for Flutter to fully render
    console.log('⏳ Waiting for Flutter app to fully render...');
    await page.waitForTimeout(10000); // 10 seconds
    
    // Wait for Flutter semantics to be ready
    try {
      await page.waitForSelector('flt-semantics', { timeout: 10000 });
      console.log('✅ Flutter semantics found');
    } catch (e) {
      console.log('⚠️ Flutter semantics not found, continuing anyway...');
    }
    
    // Take screenshot of fully loaded app
    await page.screenshot({ path: 'test-results/flutter-fully-loaded.png' });
    console.log('📸 Fully loaded app screenshot taken');
    
    // Get page content after full render
    const bodyText = await page.locator('body').textContent();
    console.log('Page text after render (first 300 chars): ' + bodyText.substring(0, 300) + '...');
    
    // Look for Flutter button elements
    const flutterButtons = page.locator('flt-gesture-detector, flt-button');
    const flutterButtonCount = await flutterButtons.count();
    console.log('Found ' + flutterButtonCount + ' Flutter button elements');
    
    // Look for any elements with text content
    const textElements = page.locator('flt-text, div, span, p');
    const textCount = await textElements.count();
    console.log('Found ' + textCount + ' text elements');
    
    // Check each text element for relevant content
    for (let i = 0; i < Math.min(textCount, 20); i++) {
      try {
        const element = textElements.nth(i);
        const text = await element.textContent();
        if (text && (text.includes('Customer') || text.includes('Staff') || text.includes('Admin') || text.includes('Login'))) {
          console.log('Found relevant text: "' + text + '"');
          
          // Try to click on the element or its parent
          try {
            await element.click();
            await page.waitForTimeout(2000);
            await page.screenshot({ path: 'test-results/flutter-clicked-' + i + '.png' });
            console.log('✅ Clicked on element and took screenshot');
            
            // Go back for next test
            await page.goto('http://localhost:8080');
            await page.waitForTimeout(5000);
          } catch (clickError) {
            console.log('Could not click on element: ' + clickError.message);
          }
        }
      } catch (e) {
        // Skip elements that can't be analyzed
      }
    }
    
    // Try alternative approach: click by coordinates
    console.log('🔍 Trying coordinate-based clicks...');
    
    await page.goto('http://localhost:8080');
    await page.waitForTimeout(5000);
    
    // Take screenshot and try clicking in different areas
    await page.screenshot({ path: 'test-results/before-coordinate-clicks.png' });
    
    // Try clicking in areas where buttons might be
    const clickAreas = [
      { x: 400, y: 300, name: 'center' },
      { x: 400, y: 400, name: 'middle-center' },
      { x: 400, y: 500, name: 'lower-center' },
      { x: 300, y: 400, name: 'left-center' },
      { x: 500, y: 400, name: 'right-center' }
    ];
    
    for (const area of clickAreas) {
      try {
        console.log('Clicking at ' + area.name + ' (' + area.x + ', ' + area.y + ')');
        await page.click(area.x, area.y);
        await page.waitForTimeout(2000);
        await page.screenshot({ path: 'test-results/click-' + area.name + '.png' });
        
        // Check if we navigated to a new page
        const currentUrl = page.url();
        if (currentUrl !== 'http://localhost:8080/') {
          console.log('✅ Navigation detected! New URL: ' + currentUrl);
          break;
        }
        
        // Go back for next click
        await page.goto('http://localhost:8080');
        await page.waitForTimeout(3000);
        
      } catch (e) {
        console.log('Click at ' + area.name + ' failed: ' + e.message);
      }
    }
    
    console.log('🎉 Flutter-aware test completed!');
    
  } catch (error) {
    console.error('❌ Test failed: ' + error.message);
    
    try {
      await page.screenshot({ path: 'test-results/flutter-aware-error.png' });
      console.log('📸 Error screenshot taken');
    } catch (screenshotError) {
      console.log('Could not take error screenshot');
    }
  } finally {
    await browser.close();
    console.log('🔚 Browser closed');
  }
}

runFlutterAwareTest().catch(console.error);
