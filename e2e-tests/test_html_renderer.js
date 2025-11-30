// e2e-tests/test_html_renderer.js - Test Flutter app with HTML renderer
const { chromium } = require('playwright');

const BASE_URL = 'http://localhost:8088';

async function testHtmlRenderer() {
  console.log('🌐 TESTING HTML RENDERER');
  console.log('========================');
  
  const browser = await chromium.launch({ headless: false });
  const page = await browser.newPage();
  
  try {
    console.log(`🚀 Navigating to: ${BASE_URL}`);
    await page.goto(BASE_URL, { waitUntil: 'networkidle' });
    
    // Wait longer for HTML renderer to initialize
    await page.waitForTimeout(15000);
    
    // Check for flt-scene-host (critical for rendering)
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
    
    // Check for HTML renderer indicators
    const hasHtmlElements = await page.evaluate(() => {
      // HTML renderer creates DOM elements instead of canvas
      const flutterElements = document.querySelectorAll('flt-scene-host, flt-render-box, flt-picture, div[style*="transform"]');
      return flutterElements.length > 0;
    });
    
    console.log(`🌐 HTML Renderer Elements: ${hasHtmlElements ? 'YES' : 'NO'}`);
    
    // Check scene host details if it exists
    if (sceneHostExists) {
      const sceneHostDetails = await page.evaluate(() => {
        const sceneHost = document.querySelector('flt-scene-host');
        const computed = window.getComputedStyle(sceneHost);
        const rect = sceneHost.getBoundingClientRect();
        const children = Array.from(sceneHost.children);
        
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
          childCount: children.length,
          children: children.slice(0, 5).map(child => ({
            tagName: child.tagName,
            className: child.className,
            display: window.getComputedStyle(child).display,
            textContent: child.textContent ? child.textContent.substring(0, 30) : ''
          }))
        };
      });
      
      console.log('🎬 Scene Host Details:', sceneHostDetails);
    }
    
    // Check for any actual widget content
    const hasWidgetContent = await page.evaluate(() => {
      // Look for text that indicates actual widgets are rendering
      const allElements = document.querySelectorAll('*');
      const widgetTexts = Array.from(allElements)
        .map(el => el.textContent)
        .filter(text => text && text.trim().length > 0)
        .filter(text => !text.startsWith('flutter-view') && text.length > 5);
      
      return widgetTexts.length > 0;
    });
    
    console.log(`🎯 Has Widget Content: ${hasWidgetContent ? 'YES' : 'NO'}`);
    
    // Test login route
    console.log(`\n📍 Testing route: /login/customer`);
    await page.goto(`${BASE_URL}/login/customer`, { waitUntil: 'networkidle' });
    await page.waitForTimeout(10000);
    
    const loginBodyText = await page.textContent('body');
    const loginLength = loginBodyText.length;
    
    console.log(`  📝 Login Page Length: ${loginLength}`);
    console.log(`  🦋 Flutter Loaded: ${loginBodyText.includes('flutter-view') ? 'YES' : 'NO'}`);
    console.log(`  🔍 Login Elements: ${loginBodyText.includes('Email') || loginBodyText.includes('Password') ? 'YES' : 'NO'}`);
    console.log(`  🎬 Scene Host: ${loginBodyText.includes('flt-scene-host') ? 'YES' : 'NO'}`);
    
    // Take screenshots for comparison
    await page.screenshot({ path: 'test-results/html_renderer_main.png', fullPage: true });
    await page.screenshot({ path: 'test-results/html_renderer_login.png', fullPage: true });
    
  } catch (error) {
    console.error('❌ Error:', error.message);
  } finally {
    await browser.close();
  }
}

testHtmlRenderer().catch(console.error);
