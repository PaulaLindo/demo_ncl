// coordinate_click_test.js - Click buttons by coordinates based on screenshot
const { chromium } = require('playwright');

async function runCoordinateClickTest() {
  console.log('🚀 Starting coordinate click test...');
  
  const browser = await chromium.launch({ headless: false });
  const page = await browser.newPage();
  
  try {
    await page.goto('http://localhost:8080');
    await page.waitForTimeout(10000);
    
    // Take screenshot to verify layout
    await page.screenshot({ path: 'test-results/coordinate-initial.png' });
    console.log('📸 Initial screenshot taken');
    
    // Based on the screenshot, approximate button coordinates
    // Customer Login (blue button) - center area
    // Staff Access (green button) - below customer
    // Admin Portal (purple button) - below staff
    
    const buttonCoordinates = [
      { x: 640, y: 360, name: 'Customer Login' },
      { x: 640, y: 460, name: 'Staff Access' },
      { x: 640, y: 560, name: 'Admin Portal' }
    ];
    
    for (const coords of buttonCoordinates) {
      try {
        console.log('🖱️ Clicking on ' + coords.name + ' at (' + coords.x + ', ' + coords.y + ')');
        
        // Use correct Playwright syntax for coordinate clicks
        await page.mouse.click(coords.x, coords.y);
        await page.waitForTimeout(3000);
        
        // Take screenshot after click
        await page.screenshot({ path: 'test-results/coordinate-' + coords.name.toLowerCase().replace(' ', '-') + '-clicked.png' });
        
        // Check if we navigated to a new page
        const currentUrl = page.url();
        if (currentUrl !== 'http://localhost:8080/') {
          console.log('✅ Navigation detected! New URL: ' + currentUrl);
          
          // Look for form elements
          const inputs = page.locator('input');
          const inputCount = await inputs.count();
          
          if (inputCount > 0) {
            console.log('✅ Found ' + inputCount + ' input fields on login page');
            
            // Fill the form
            if (inputCount >= 2) {
              await inputs.nth(0).fill('test@example.com');
              await inputs.nth(1).fill('testpassword');
              await page.waitForTimeout(1000);
              await page.screenshot({ path: 'test-results/form-filled-' + coords.name.toLowerCase().replace(' ', '-') + '.png' });
              console.log('✅ Form filled for ' + coords.name);
              
              // Try to submit
              const submitButton = page.locator('button, input[type="submit"]');
              if (await submitButton.isVisible({ timeout: 3000 })) {
                await submitButton.click();
                await page.waitForTimeout(3000);
                await page.screenshot({ path: 'test-results/after-submit-' + coords.name.toLowerCase().replace(' ', '-') + '.png' });
                console.log('✅ Submit button clicked for ' + coords.name);
              }
            }
          }
          
          break; // Found a working button, stop testing
        }
        
        // Go back for next button
        await page.goto('http://localhost:8080');
        await page.waitForTimeout(3000);
        
      } catch (e) {
        console.log('❌ Click on ' + coords.name + ' failed: ' + e.message);
      }
    }
    
    // Try clicking on the help text area
    await page.goto('http://localhost:8080');
    await page.waitForTimeout(3000);
    
    try {
      console.log('🖱️ Clicking on help text area');
      await page.mouse.click(640, 650); // Bottom area where help text might be
      await page.waitForTimeout(2000);
      await page.screenshot({ path: 'test-results/help-area-clicked.png' });
      console.log('✅ Help area clicked');
    } catch (e) {
      console.log('❌ Help area click failed: ' + e.message);
    }
    
    console.log('🎉 Coordinate click test completed!');
    
  } catch (error) {
    console.error('❌ Test failed: ' + error.message);
    
    try {
      await page.screenshot({ path: 'test-results/coordinate-error.png' });
      console.log('📸 Error screenshot taken');
    } catch (screenshotError) {
      console.log('Could not take error screenshot');
    }
  } finally {
    await browser.close();
    console.log('🔚 Browser closed');
  }
}

runCoordinateClickTest().catch(console.error);
