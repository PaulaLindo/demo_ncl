// e2e-tests/test_clean_flutter_after_fix.js - Test clean Flutter after cleaning
const { chromium } = require('playwright');

const BASE_URL = 'http://localhost:8093';

async function testCleanFlutterAfterFix() {
  console.log('🧼 TESTING CLEAN FLUTTER AFTER CLEANING');
  console.log('=====================================');
  
  const browser = await chromium.launch({ headless: false });
  const page = await browser.newPage();
  
  try {
    console.log(`🚀 Navigating to: ${BASE_URL}`);
    await page.goto(BASE_URL, { waitUntil: 'networkidle' });
    
    // Wait for Flutter to load
    await page.waitForTimeout(20000);
    
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
    
    // Check for default Flutter content
    const hasFlutterContent = bodyText.includes('Flutter') || 
                              bodyText.includes('You have') ||
                              bodyText.includes('home screen');
    
    console.log(`🧪 Has Flutter Content: ${hasFlutterContent ? 'YES' : 'NO'}`);
    
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
    
    // Check for canvas elements
    const canvasInfo = await page.evaluate(() => {
      const canvases = Array.from(document.querySelectorAll('canvas'));
      return canvases.length;
    });
    
    console.log(`🎨 Canvas Elements: ${canvasInfo}`);
    
    // Show first 300 characters for debugging
    console.log(`📄 Body Preview: "${bodyText.substring(0, 300)}..."`);
    
    // Take screenshot
    await page.screenshot({ path: 'test-results/clean_flutter_after_fix.png', fullPage: true });
    
    // Final diagnosis
    if (sceneHostExists && hasFlutterContent) {
      console.log('✅ SUCCESS: Clean Flutter project works after cleaning!');
      console.log('   This means the issue was with build cache');
    } else if (sceneHostExists && !hasFlutterContent) {
      console.log('⚠️  PARTIAL: Scene host exists but no content');
    } else if (!sceneHostExists && bodyTextLength > 1000) {
      console.log('❌ ISSUE: Same problem persists');
      console.log('   This indicates a deeper Flutter web engine issue');
    } else {
      console.log('❌ CRITICAL: Flutter not loading properly');
    }
    
  } catch (error) {
    console.error('❌ Error:', error.message);
  } finally {
    await browser.close();
  }
}

testCleanFlutterAfterFix().catch(console.error);
