// e2e-tests/test_downgraded_flutter.js - Test with downgraded Flutter version
const { chromium } = require('playwright');

const BASE_URL = 'http://localhost:8090';

async function testDowngradedFlutter() {
  console.log('🔽 TESTING DOWNGRADED FLUTTER (3.38.1)');
  console.log('=======================================');
  
  const browser = await chromium.launch({ headless: false });
  const page = await browser.newPage();
  
  try {
    console.log(`🚀 Navigating to: ${BASE_URL}`);
    await page.goto(BASE_URL, { waitUntil: 'networkidle' });
    
    // Wait for Flutter to load
    await page.waitForTimeout(15000);
    
    // Check for flt-scene-host (the critical missing element)
    const sceneHostExists = await page.evaluate(() => {
      return !!document.querySelector('flt-scene-host');
    });
    
    console.log(`🎬 Scene Host Exists: ${sceneHostExists ? 'YES' : 'NO'}`);
    
    // Check content
    const bodyText = await page.textContent('body');
    const bodyTextLength = bodyText.length;
    
    console.log(`📝 Body Length: ${bodyTextLength}`);
    console.log(`🦋 Flutter Loaded: ${bodyText.includes('flutter-view') ? 'YES' : 'NO'}`);
    console.log(`🎯 Has Actual Content: ${bodyText.length > 2000 ? 'YES' : 'NO'}`);
    
    // Check for our specific test content
    const hasTestContent = bodyText.includes('FLUTTER WEB WORKING!') || 
                          bodyText.includes('MINIMAL WEB TEST');
    
    console.log(`🧪 Has Test Content: ${hasTestContent ? 'YES' : 'NO'}`);
    
    // Check Flutter structure
    const flutterStructure = await page.evaluate(() => {
      const flutterView = document.querySelector('flutter-view');
      const sceneHost = document.querySelector('flt-scene-host');
      const glassPane = document.querySelector('flt-glass-pane');
      
      return {
        hasFlutterView: !!flutterView,
        hasSceneHost: !!sceneHost,
        hasGlassPane: !!glassPane,
        flutterViewChildren: flutterView ? flutterView.children.length : 0,
        sceneHostChildren: sceneHost ? sceneHost.children.length : 0
      };
    });
    
    console.log('🔍 Flutter Structure:', flutterStructure);
    
    // Check for any canvas elements (CanvasKit renderer)
    const canvasInfo = await page.evaluate(() => {
      const canvases = Array.from(document.querySelectorAll('canvas'));
      return canvases.length;
    });
    
    console.log(`🎨 Canvas Elements: ${canvasInfo}`);
    
    // Show first 300 characters for debugging
    console.log(`📄 Body Preview: "${bodyText.substring(0, 300)}..."`);
    
    // Take screenshot
    await page.screenshot({ path: 'test-results/downgraded_flutter_test.png', fullPage: true });
    
    // Final diagnosis
    if (sceneHostExists && hasTestContent) {
      console.log('✅ SUCCESS: Flutter web rendering works with downgraded version!');
    } else if (sceneHostExists && !hasTestContent) {
      console.log('⚠️  PARTIAL: Scene host exists but no content');
    } else if (!sceneHostExists && bodyTextLength > 1000) {
      console.log('❌ ISSUE: Flutter loads but no scene host (same issue)');
    } else {
      console.log('❌ CRITICAL: Flutter not loading properly');
    }
    
  } catch (error) {
    console.error('❌ Error:', error.message);
  } finally {
    await browser.close();
  }
}

testDowngradedFlutter().catch(console.error);
