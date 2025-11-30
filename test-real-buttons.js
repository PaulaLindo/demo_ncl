// test-real-buttons.js - Test buttons in the actual running Flutter app
const { chromium } = require('playwright');

async function testRealButtons() {
  console.log('🧪 TESTING REAL BUTTONS IN RUNNING APP');
  console.log('=======================================');
  console.log('This will test the actual buttons in the Flutter app at http://localhost:8081');
  console.log('');

  const browser = await chromium.launch({ 
    headless: false, 
    slowMo: 1000 
  });

  try {
    const page = await browser.newPage();
    
    // Enable console logging
    page.on('console', msg => {
      const text = msg.text();
      if (text.includes('🔍') || text.includes('❌') || text.includes('✅')) {
        console.log('🖥️ ', text);
      }
    });

    console.log('📍 Step 1: Navigate to running app');
    await page.goto('http://localhost:8081/', { waitUntil: 'networkidle' });
    await page.waitForTimeout(5000);

    console.log('\n📍 Step 2: Check if buttons are visible and clickable');
    
    // Try to find buttons by text content
    const buttons = [
      { text: 'Customer Login', route: '/login/customer' },
      { text: 'Staff Access', route: '/login/staff' },
      { text: 'Admin Portal', route: '/login/admin' }
    ];

    for (const button of buttons) {
      console.log(`\n🎯 Testing: ${button.text}`);
      
      // Clear console
      page.removeAllListeners('console');
      page.on('console', msg => {
        const text = msg.text();
        if (text.includes('🔍') || text.includes('❌') || text.includes('✅')) {
          console.log('🖥️ ', text);
        }
      });
      
      try {
        // Try to find the button by text
        const buttonElement = await page.locator(`text="${button.text}"`).first();
        
        if (await buttonElement.isVisible()) {
          console.log(`✅ Found ${button.text} button - it's visible!`);
          
          // Click it
          await buttonElement.click();
          await page.waitForTimeout(2000);
          
          // Check if navigation occurred
          const currentUrl = page.url();
          if (currentUrl.includes(button.route)) {
            console.log(`✅ Navigation worked! URL: ${currentUrl}`);
          } else {
            console.log(`❌ Navigation failed. URL: ${currentUrl}`);
          }
          
          // Go back to home
          await page.goto('http://localhost:8081/', { waitUntil: 'networkidle' });
          await page.waitForTimeout(2000);
          
        } else {
          console.log(`❌ ${button.text} button not visible`);
          
          // Try clicking by coordinates (overlay buttons)
          console.log(`🎯 Trying coordinate-based click for ${button.text}`);
          
          const coordinates = {
            'Customer Login': { x: 640, y: 350 },
            'Staff Access': { x: 640, y: 420 },
            'Admin Portal': { x: 640, y: 490 }
          };
          
          const coord = coordinates[button.text];
          if (coord) {
            await page.mouse.click(coord.x, coord.y);
            await page.waitForTimeout(2000);
            
            const currentUrl = page.url();
            if (currentUrl.includes(button.route)) {
              console.log(`✅ Coordinate navigation worked! URL: ${currentUrl}`);
            } else {
              console.log(`❌ Coordinate navigation failed. URL: ${currentUrl}`);
            }
            
            // Go back to home
            await page.goto('http://localhost:8081/', { waitUntil: 'networkidle' });
            await page.waitForTimeout(2000);
          }
        }
        
      } catch (error) {
        console.log(`❌ Error testing ${button.text}: ${error.message}`);
      }
    }

    console.log('\n📍 Step 3: Test keyboard navigation');
    await page.goto('http://localhost:8081/', { waitUntil: 'networkidle' });
    await page.waitForTimeout(2000);
    
    console.log('🎯 Pressing "1" for Customer Login');
    await page.keyboard.press('1');
    await page.waitForTimeout(2000);
    
    let url = page.url();
    if (url.includes('/login/customer')) {
      console.log('✅ Keyboard navigation worked! URL:', url);
    } else {
      console.log('❌ Keyboard navigation failed. URL:', url);
    }

    console.log('\n🎯 RESULTS SUMMARY');
    console.log('==================');
    console.log('📝 Check the results above to see which navigation methods work:');
    console.log('   - Text-based button clicks');
    console.log('   - Coordinate-based button clicks (overlay buttons)');
    console.log('   - Keyboard navigation (1, 2, 3 keys)');
    console.log('');
    console.log('🔍 If none work, there might be an issue with the actual button implementation');

  } catch (error) {
    console.error('❌ Test failed:', error);
  } finally {
    await browser.close();
    console.log('\n✅ Test completed');
  }
}

// Run the test
testRealButtons().catch(console.error);
