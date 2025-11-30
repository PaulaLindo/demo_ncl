// e2e-tests/browser_debug_test.js - Comprehensive browser debug test
const { chromium } = require('playwright');

async function browserDebugTest() {
  console.log('🔍 COMPREHENSIVE BROWSER DEBUG TEST');
  console.log('==================================');
  
  const browser = await chromium.launch({ 
    headless: false, // Keep visible for manual inspection
    devtools: true   // Open DevTools automatically
  });
  
  const context = await browser.newContext({
    viewport: { width: 1280, height: 720 }
  });
  
  const page = await context.newPage();
  
  // Set up console logging to capture everything
  const consoleMessages = [];
  page.on('console', msg => {
    consoleMessages.push({
      type: msg.type(),
      text: msg.text(),
      location: msg.location()
        ? `${msg.location().url}:${msg.location().lineNumber}`
        : 'unknown'
    });
    console.log(`📢 ${msg.type().toUpperCase()}: ${msg.text()}`);
  });
  
  // Set up error logging
  page.on('pageerror', error => {
    console.error('🚨 PAGE ERROR:', error.message);
    console.error('🚨 STACK:', error.stack);
  });
  
  // Set up request/response logging
  page.on('request', request => {
    console.log(`🌐 REQUEST: ${request.method()} ${request.url()}`);
  });
  
  page.on('response', response => {
    console.log(`📡 RESPONSE: ${response.status()} ${response.url()}`);
  });
  
  try {
    console.log(`🚀 Navigating to Flutter debug app...`);
    
    // Run the debug version of our app
    await page.goto('http://localhost:8094', { 
      waitUntil: 'networkidle',
      timeout: 30000 
    });
    
    // Wait for initial load
    await page.waitForTimeout(5000);
    
    console.log('\n🔍 DOM ANALYSIS:');
    console.log('================');
    
    // Analyze the DOM structure
    const domAnalysis = await page.evaluate(() => {
      const results = {
        documentTitle: document.title,
        bodyChildren: document.body.children.length,
        flutterView: null,
        sceneHost: null,
        glassPane: null,
        semanticsHost: null,
        canvasElements: [],
        scripts: [],
        styles: [],
        allFlutterElements: []
      };
      
      // Find Flutter elements
      results.flutterView = document.querySelector('flutter-view');
      results.sceneHost = document.querySelector('flt-scene-host');
      results.glassPane = document.querySelector('flt-glass-pane');
      results.semanticsHost = document.querySelector('flt-semantics-host');
      
      // Find all Flutter-related elements
      results.allFlutterElements = Array.from(document.querySelectorAll('*'))
        .filter(el => el.tagName.toLowerCase().includes('flt-') || el.tagName.toLowerCase() === 'flutter-view')
        .map(el => ({
          tagName: el.tagName,
          id: el.id,
          className: el.className,
          children: el.children.length,
          display: window.getComputedStyle(el).display,
          visibility: window.getComputedStyle(el).visibility,
          opacity: window.getComputedStyle(el).opacity,
          rect: el.getBoundingClientRect()
        }));
      
      // Find canvas elements
      results.canvasElements = Array.from(document.querySelectorAll('canvas'))
        .map(canvas => ({
          width: canvas.width,
          height: canvas.height,
          display: window.getComputedStyle(canvas).display,
          rect: canvas.getBoundingClientRect()
        }));
      
      // Find scripts
      results.scripts = Array.from(document.querySelectorAll('script'))
        .map(script => ({
          src: script.src,
          loaded: script.readyState || 'unknown'
        }));
      
      // Find styles
      results.styles = Array.from(document.querySelectorAll('style, link[rel="stylesheet"]'))
        .map(style => ({
          tag: style.tagName,
          href: style.href || 'inline',
          loaded: 'loaded'
        }));
      
      return results;
    });
    
    console.log('📄 Document Title:', domAnalysis.documentTitle);
    console.log('👶 Body Children:', domAnalysis.bodyChildren);
    console.log('🦋 Flutter View:', domAnalysis.flutterView ? 'EXISTS' : 'MISSING');
    console.log('🎬 Scene Host:', domAnalysis.sceneHost ? 'EXISTS' : 'MISSING');
    console.log('🪟 Glass Pane:', domAnalysis.glassPane ? 'EXISTS' : 'MISSING');
    console.log('🔤 Semantics Host:', domAnalysis.semanticsHost ? 'EXISTS' : 'MISSING');
    console.log('🎨 Canvas Elements:', domAnalysis.canvasElements.length);
    
    console.log('\n🔍 ALL FLUTTER ELEMENTS:');
    domAnalysis.allFlutterElements.forEach((el, index) => {
      console.log(`  ${index + 1}. ${el.tagName} - ${el.display} / ${el.visibility} / ${el.opacity}`);
      if (el.rect.width > 0 && el.rect.height > 0) {
        console.log(`     Size: ${el.rect.width}x${el.rect.height}`);
      }
    });
    
    console.log('\n🔍 LOADED SCRIPTS:');
    domAnalysis.scripts.forEach((script, index) => {
      console.log(`  ${index + 1}. ${script.src || 'inline script'}`);
    });
    
    console.log('\n🔍 LOADED STYLES:');
    domAnalysis.styles.forEach((style, index) => {
      console.log(`  ${index + 1}. ${style.tag} - ${style.href}`);
    });
    
    // Check for Flutter initialization in console
    await page.waitForTimeout(10000); // Wait longer for Flutter to initialize
    
    console.log('\n🔍 CONSOLE ANALYSIS:');
    console.log('===================');
    
    const flutterConsoleMessages = consoleMessages.filter(msg => 
      msg.text.includes('flutter') || 
      msg.text.includes('Flutter') ||
      msg.text.includes('DEBUG:') ||
      msg.text.includes('🚀') ||
      msg.text.includes('🌐')
    );
    
    console.log(`📢 Flutter-related console messages (${flutterConsoleMessages.length}):`);
    flutterConsoleMessages.forEach((msg, index) => {
      console.log(`  ${index + 1}. [${msg.type.toUpperCase()}] ${msg.text}`);
      if (msg.location !== 'unknown') {
        console.log(`     📍 ${msg.location}`);
      }
    });
    
    // Try to interact with the page to see if Flutter is responsive
    console.log('\n🔍 INTERACTION TEST:');
    console.log('==================');
    
    try {
      // Look for any clickable elements
      const clickableElements = await page.evaluate(() => {
        const elements = Array.from(document.querySelectorAll('button, [role="button"], a, input, [onclick]'));
        return elements.map(el => ({
          tagName: el.tagName,
          text: el.textContent,
          visible: window.getComputedStyle(el).display !== 'none',
          clickable: el.offsetParent !== null
        }));
      });
      
      console.log(`🔘 Clickable elements found: ${clickableElements.length}`);
      clickableElements.forEach((el, index) => {
        console.log(`  ${index + 1}. ${el.tagName} - "${el.text}" (visible: ${el.visible}, clickable: ${el.clickable})`);
      });
      
      // Try to click on the body to see if there's any response
      await page.click('body');
      await page.waitForTimeout(2000);
      
      // Check if any new console messages appeared
      const newMessages = consoleMessages.slice(-5);
      console.log('📢 Latest console messages after click:');
      newMessages.forEach((msg, index) => {
        console.log(`  ${index + 1}. [${msg.type.toUpperCase()}] ${msg.text}`);
      });
      
    } catch (error) {
      console.error('❌ Interaction test failed:', error.message);
    }
    
    // Take screenshot for visual reference
    await page.screenshot({ 
      path: 'test-results/browser_debug_comprehensive.png', 
      fullPage: true 
    });
    
    console.log('\n🎯 FINAL DIAGNOSIS:');
    console.log('==================');
    
    if (domAnalysis.sceneHost) {
      console.log('✅ Scene host exists - Flutter web engine working');
    } else {
      console.log('❌ Scene host missing - Flutter web engine issue');
      
      if (domAnalysis.flutterView) {
        console.log('⚠️  Flutter view exists but no scene host');
        console.log('   This suggests Flutter partially initializes but fails to create rendering surface');
      } else {
        console.log('❌ No Flutter elements at all');
      }
    }
    
    if (flutterConsoleMessages.length > 0) {
      console.log('✅ Console shows Flutter activity');
    } else {
      console.log('❌ No Flutter console messages - initialization may have failed');
    }
    
    console.log('\n📋 RECOMMENDATIONS:');
    if (!domAnalysis.sceneHost) {
      console.log('1. Check Flutter web engine installation');
      console.log('2. Verify VS Code Flutter extensions are installed');
      console.log('3. Try running `flutter clean && flutter pub get`');
      console.log('4. Check browser console for JavaScript errors');
      console.log('5. Verify Flutter web dependencies are loaded');
    }
    
    console.log('\n🔗 Keep browser open for manual inspection...');
    await page.waitForTimeout(30000); // Keep open for 30 seconds for manual inspection
    
  } catch (error) {
    console.error('❌ Test failed:', error.message);
  } finally {
    await browser.close();
  }
}

browserDebugTest().catch(console.error);
