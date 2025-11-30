// e2e-tests/test_new_build.js - Test the newly built Flutter app
const { chromium } = require('playwright');

const BASE_URL = 'http://localhost:8087';

async function testNewBuild() {
  console.log('🏗️ TESTING NEWLY BUILT FLUTTER APP');
  console.log('==================================');
  
  const browser = await chromium.launch({ headless: false });
  const page = await browser.newPage();
  
  try {
    console.log(`🚀 Navigating to: ${BASE_URL}`);
    await page.goto(BASE_URL, { waitUntil: 'networkidle' });
    
    // Wait for Flutter to load
    await page.waitForTimeout(15000);
    
    // Check for flt-scene-host
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
    
    // Check scene host details if it exists
    if (sceneHostExists) {
      const sceneHostStyles = await page.evaluate(() => {
        const sceneHost = document.querySelector('flt-scene-host');
        const computed = window.getComputedStyle(sceneHost);
        const rect = sceneHost.getBoundingClientRect();
        
        return {
          display: computed.display,
          visibility: computed.visibility,
          opacity: computed.opacity,
          position: computed.position,
          height: computed.height,
          width: computed.width,
          backgroundColor: computed.backgroundColor,
          zIndex: computed.zIndex,
          rect: {
            width: rect.width,
            height: rect.height,
            top: rect.top,
            left: rect.left
          },
          childCount: sceneHost.children.length
        };
      });
      
      console.log('🎬 Scene Host Details:', sceneHostStyles);
    }
    
    // Check for any actual content
    const hasActualContent = await page.evaluate(() => {
      // Look for any text that's not just CSS
      const allText = document.body.textContent || '';
      const cssText = 'flutter-view flt-scene-host';
      
      return allText.length > 1000 && !allText.startsWith(cssText);
    });
    
    console.log(`🎯 Has Real Content: ${hasActualContent ? 'YES' : 'NO'}`);
    
    // Test a specific route
    console.log(`\n📍 Testing route: /login/customer`);
    await page.goto(`${BASE_URL}/login/customer`, { waitUntil: 'networkidle' });
    await page.waitForTimeout(10000);
    
    const loginBodyText = await page.textContent('body');
    const loginLength = loginBodyText.length;
    
    console.log(`  📝 Login Page Length: ${loginLength}`);
    console.log(`  🦋 Flutter Loaded: ${loginBodyText.includes('flutter-view') ? 'YES' : 'NO'}`);
    console.log(`  🔍 Login Elements: ${loginBodyText.includes('Email') || loginBodyText.includes('Password') ? 'YES' : 'NO'}`);
    
    // Take screenshots
    await page.screenshot({ path: 'test-results/new_build_main.png', fullPage: true });
    await page.screenshot({ path: 'test-results/new_build_login.png', fullPage: true });
    
  } catch (error) {
    console.error('❌ Error:', error.message);
  } finally {
    await browser.close();
  }
}

testNewBuild().catch(console.error);
