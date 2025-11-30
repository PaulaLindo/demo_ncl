// test-button-taps.js - Simple test to check if button onTap handlers are called
const { chromium } = require('playwright');

async function testButtonTaps() {
  console.log('🧪 TESTING BUTTON TAP HANDLERS');
  console.log('==============================');
  console.log('Checking if the onTap handlers are actually being called');
  console.log('');

  const browser = await chromium.launch({ 
    headless: false, 
    slowMo: 500 
  });

  try {
    const page = await browser.newPage();
    
    // Enable console logging to see debug messages
    page.on('console', msg => {
      const text = msg.text();
      if (text.includes('🔍') || text.includes('❌')) {
        console.log('🖥️ ', text);
      }
    });

    console.log('📍 Step 1: Load main page');
    await page.goto('http://localhost:8080/', { waitUntil: 'networkidle' });
    await page.waitForTimeout(8000);

    console.log('\n📍 Step 2: Try to click Customer Login button area');
    
    // Try different click strategies since text might not be visible
    const clickAttempts = [
      { name: 'Center of screen', x: 640, y: 432 },
      { name: 'Upper middle', x: 640, y: 350 },
      { name: 'Lower middle', x: 640, y: 500 },
      { name: 'Left side', x: 300, y: 432 },
      { name: 'Right side', x: 900, y: 432 },
    ];

    for (const attempt of clickAttempts) {
      console.log(`🎯 Clicking at ${attempt.name} (${attempt.x}, ${attempt.y})`);
      
      // Clear previous console messages
      page.removeAllListeners('console');
      
      // Add fresh listener
      page.on('console', msg => {
        const text = msg.text();
        if (text.includes('🔍') || text.includes('❌')) {
          console.log('🖥️ ', text);
        }
      });
      
      try {
        await page.mouse.click(attempt.x, attempt.y);
        await page.waitForTimeout(2000);
        
        // Check if URL changed
        const currentUrl = page.url();
        if (currentUrl !== 'http://localhost:8080/') {
          console.log('✅ Navigation occurred! URL:', currentUrl);
          console.log('🎉 BUTTONS ARE WORKING!');
          return;
        }
        
        // Check if any debug messages appeared
        // (We can't easily check this programmatically, but the user will see console output)
        
      } catch (error) {
        console.log('❌ Click failed:', error.message);
      }
      
      console.log('---');
    }

    console.log('\n📍 Step 3: Test with text-based selection (if visible)');
    
    // Try to find and click text elements
    try {
      const customerText = await page.locator('text=Customer Login').first();
      if (await customerText.isVisible()) {
        console.log('👤 Found Customer Login text, clicking...');
        await customerText.click();
        await page.waitForTimeout(3000);
        
        const afterUrl = page.url();
        if (afterUrl !== 'http://localhost:8080/') {
          console.log('✅ Text-based navigation worked! URL:', afterUrl);
          return;
        }
      } else {
        console.log('👤 Customer Login text not visible');
      }
    } catch (error) {
      console.log('❌ Text-based click failed:', error.message);
    }

    console.log('\n📍 Step 4: Test programmatic navigation as control');
    await page.evaluate(() => {
      window.history.pushState({}, '', '/login/customer');
    });
    await page.waitForTimeout(2000);
    
    const programmaticUrl = page.url();
    console.log('📍 Programmatic navigation URL:', programmaticUrl);
    
    if (programmaticUrl.includes('/login/customer')) {
      console.log('✅ Programmatic navigation works (control test passed)');
    }

    console.log('\n🎯 RESULTS SUMMARY');
    console.log('==================');
    console.log('📝 Check the browser console for debug messages:');
    console.log('   - "🔍 Customer Login button tapped!" = Button click detected');
    console.log('   - "🔍 Navigation called successfully" = Navigation attempted');
    console.log('   - "❌ Navigation error: ..." = Navigation failed');
    console.log('');
    console.log('🔍 If you see NO debug messages, the onTap handlers are NOT being called');
    console.log('🔍 If you see debug messages but no navigation, the issue is with context.go()');
    console.log('🔍 If programmatic navigation works, the routes are correct');

  } catch (error) {
    console.error('❌ Test failed:', error);
  } finally {
    await browser.close();
    console.log('\n✅ Test completed');
  }
}

// Run the test
testButtonTaps().catch(console.error);
