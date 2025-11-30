// e2e-tests/test_canvaskit_fix.js - Test CanvasKit fix
const { chromium } = require('playwright');

async function testCanvasKitFix() {
  console.log('🎨 TESTING CANVASKIT FIX');
  console.log('========================');
  
  const browser = await chromium.launch({ 
    headless: false,
    devtools: true
  });
  
  const page = await browser.newPage();
  
  // Set up console monitoring
  const consoleMessages = [];
  page.on('console', msg => {
    consoleMessages.push({
      type: msg.type(),
      text: msg.text(),
      timestamp: Date.now()
    });
    console.log(`📢 [${msg.type().toUpperCase()}] ${msg.text()}`);
  });
  
  try {
    console.log(`🚀 Loading Flutter app with CanvasKit fix...`);
    
    // Navigate to Flutter app
    await page.goto('http://localhost:8099', { 
      waitUntil: 'networkidle',
      timeout: 30000 
    });
    
    // Wait for initial load
    await page.waitForTimeout(10000); // Longer wait for CanvasKit
    
    console.log('\n🔍 CHECKING CANVASKIT INITIALIZATION');
    console.log('===================================');
    
    // Check for CanvasKit-specific elements
    const canvasKitCheck = await page.evaluate(() => {
      const results = {
        flutterView: !!document.querySelector('flutter-view'),
        sceneHost: !!document.querySelector('flt-scene-host'),
        canvasElements: document.querySelectorAll('canvas').length,
        canvasKitLoaded: false,
        bodyText: document.body.textContent || '',
        timestamp: Date.now()
      };
      
      // Check for CanvasKit WASM loading
      if (window.flutter && window.flutter.engine && window.flutter.engine.canvasKit) {
        results.canvasKitLoaded = true;
      }
      
      // Check for any canvas elements
      const canvases = document.querySelectorAll('canvas');
      results.canvasDetails = Array.from(canvases).map(canvas => ({
        width: canvas.width,
        height: canvas.height,
        display: window.getComputedStyle(canvas).display,
        rect: canvas.getBoundingClientRect()
      }));
      
      return results;
    });
    
    console.log(`🦋 Flutter View: ${canvasKitCheck.flutterView ? 'EXISTS' : 'MISSING'}`);
    console.log(`🎬 Scene Host: ${canvasKitCheck.sceneHost ? 'EXISTS' : 'MISSING'}`);
    console.log(`🎨 Canvas Elements: ${canvasKitCheck.canvasElements}`);
    console.log(`🔧 CanvasKit Loaded: ${canvasKitCheck.canvasKitLoaded ? 'YES' : 'NO'}`);
    console.log(`📝 Body Length: ${canvasKitCheck.bodyText.length}`);
    
    if (canvasKitCheck.canvasDetails.length > 0) {
      console.log('🎨 Canvas Details:');
      canvasKitCheck.canvasDetails.forEach((canvas, index) => {
        console.log(`  ${index + 1}. ${canvas.width}x${canvas.height} - ${canvas.display}`);
        if (canvas.rect.width > 0 && canvas.rect.height > 0) {
          console.log(`     Size: ${canvas.rect.width}x${canvas.rect.height}`);
        }
      });
    }
    
    // Check for CanvasKit console messages
    const canvasKitMessages = consoleMessages.filter(msg => 
      msg.text.toLowerCase().includes('canvaskit') ||
      msg.text.toLowerCase().includes('canvas') ||
      msg.text.includes('🎨') ||
      msg.text.includes('🔧')
    );
    
    console.log(`\n📢 CanvasKit-related messages: ${canvasKitMessages.length}`);
    canvasKitMessages.forEach((msg, index) => {
      console.log(`  ${index + 1}. [${msg.type.toUpperCase()}] ${msg.text}`);
    });
    
    // Check if we have actual content now
    const hasActualContent = canvasKitCheck.bodyText.length > 2000 && 
                           !canvasKitCheck.bodyText.startsWith('flutter-view flt-scene-host');
    
    console.log(`\n🎯 CONTENT ANALYSIS:`);
    console.log(`📝 Body length: ${canvasKitCheck.bodyText.length}`);
    console.log(`🎯 Has actual content: ${hasActualContent ? 'YES' : 'NO'}`);
    
    if (hasActualContent) {
      console.log(`📄 Content preview: "${canvasKitCheck.bodyText.substring(0, 200)}..."`);
    }
    
    // Test interaction if content exists
    if (hasActualContent) {
      console.log('\n🔘 TESTING INTERACTION:');
      
      try {
        // Look for buttons or interactive elements
        const buttons = await page.$$('button, [role="button"]');
        console.log(`🔘 Found ${buttons.length} buttons`);
        
        if (buttons.length > 0) {
          await buttons[0].click();
          await page.waitForTimeout(2000);
          console.log('✅ Button clicked successfully');
        }
        
      } catch (error) {
        console.error('❌ Interaction test failed:', error.message);
      }
    }
    
    // Take screenshot
    await page.screenshot({ 
      path: 'test-results/canvaskit_fix_result.png', 
      fullPage: true 
    });
    
    // Final diagnosis
    console.log('\n🎯 FINAL DIAGNOSIS:');
    console.log('==================');
    
    if (canvasKitCheck.sceneHost && hasActualContent) {
      console.log('✅ SUCCESS: CanvasKit fix worked!');
      console.log('   Scene host exists and content is rendering');
    } else if (canvasKitCheck.sceneHost && !hasActualContent) {
      console.log('⚠️  PARTIAL: Scene host exists but no content');
      console.log('   CanvasKit is working but content not visible');
    } else if (canvasKitCheck.canvasElements > 0 && !canvasKitCheck.sceneHost) {
      console.log('⚠️  CANVASKIT: Canvas elements exist but no scene host');
      console.log('   CanvasKit loaded but rendering surface not created');
    } else {
      console.log('❌ CanvasKit fix did not resolve the issue');
      
      if (canvasKitCheck.canvasElements > 0) {
        console.log('🔍 CanvasKit is loading but scene host still missing');
      } else {
        console.log('🔍 No CanvasKit elements found');
      }
    }
    
    console.log('\n📋 NEXT STEPS:');
    if (!canvasKitCheck.sceneHost) {
      console.log('1. Try HTML renderer instead');
      console.log('2. Check for CanvasKit compatibility issues');
      console.log('3. Use Cypress for E2E testing as planned');
    } else {
      console.log('✅ CanvasKit working - proceed with authentication testing');
    }
    
    console.log('\n🔗 Keeping browser open for manual inspection...');
    await page.waitForTimeout(10000);
    
  } catch (error) {
    console.error('❌ Test failed:', error.message);
  } finally {
    await browser.close();
  }
}

testCanvasKitFix().catch(console.error);
