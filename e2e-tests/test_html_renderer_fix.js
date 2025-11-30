// e2e-tests/test_html_renderer_fix.js - Test HTML renderer fix
const { chromium } = require('playwright');

async function testHtmlRendererFix() {
  console.log('🌐 TESTING HTML RENDERER FIX');
  console.log('============================');
  
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
    console.log(`🚀 Loading Flutter app with HTML renderer...`);
    
    // Navigate to Flutter app
    await page.goto('http://localhost:8100', { 
      waitUntil: 'networkidle',
      timeout: 30000 
    });
    
    // Wait for HTML renderer to initialize
    await page.waitForTimeout(10000);
    
    console.log('\n🔍 CHECKING HTML RENDERER INITIALIZATION');
    console.log('======================================');
    
    // Check for HTML renderer-specific elements
    const htmlRendererCheck = await page.evaluate(() => {
      const results = {
        flutterView: !!document.querySelector('flutter-view'),
        sceneHost: !!document.querySelector('flt-scene-host'),
        canvasElements: document.querySelectorAll('canvas').length,
        htmlElements: document.querySelectorAll('flt-render-box, flt-picture, div[style*="transform"]').length,
        bodyText: document.body.textContent || '',
        timestamp: Date.now()
      };
      
      // Look for HTML renderer specific elements
      results.htmlDetails = Array.from(document.querySelectorAll('flt-render-box, flt-picture, div[style*="transform"]'))
        .map(el => ({
          tagName: el.tagName,
          className: el.className,
          display: window.getComputedStyle(el).display,
          rect: el.getBoundingClientRect()
        }));
      
      return results;
    });
    
    console.log(`🦋 Flutter View: ${htmlRendererCheck.flutterView ? 'EXISTS' : 'MISSING'}`);
    console.log(`🎬 Scene Host: ${htmlRendererCheck.sceneHost ? 'EXISTS' : 'MISSING'}`);
    console.log(`🎨 Canvas Elements: ${htmlRendererCheck.canvasElements}`);
    console.log(`🌐 HTML Elements: ${htmlRendererCheck.htmlElements}`);
    console.log(`📝 Body Length: ${htmlRendererCheck.bodyText.length}`);
    
    if (htmlRendererCheck.htmlDetails.length > 0) {
      console.log('🌐 HTML Renderer Elements:');
      htmlRendererCheck.htmlDetails.forEach((el, index) => {
        console.log(`  ${index + 1}. ${el.tagName} - ${el.display}`);
        if (el.rect.width > 0 && el.rect.height > 0) {
          console.log(`     Size: ${el.rect.width}x${el.rect.height}`);
        }
      });
    }
    
    // Check for HTML renderer console messages
    const htmlMessages = consoleMessages.filter(msg => 
      msg.text.toLowerCase().includes('html') ||
      msg.text.toLowerCase().includes('renderer') ||
      msg.text.includes('🌐') ||
      msg.text.includes('🔍')
    );
    
    console.log(`\n📢 HTML renderer messages: ${htmlMessages.length}`);
    htmlMessages.forEach((msg, index) => {
      console.log(`  ${index + 1}. [${msg.type.toUpperCase()}] ${msg.text}`);
    });
    
    // Check if we have actual content now
    const hasActualContent = htmlRendererCheck.bodyText.length > 2000 && 
                           !htmlRendererCheck.bodyText.startsWith('flutter-view flt-scene-host');
    
    console.log(`\n🎯 CONTENT ANALYSIS:`);
    console.log(`📝 Body length: ${htmlRendererCheck.bodyText.length}`);
    console.log(`🎯 Has actual content: ${hasActualContent ? 'YES' : 'NO'}`);
    
    if (hasActualContent) {
      console.log(`📄 Content preview: "${htmlRendererCheck.bodyText.substring(0, 200)}..."`);
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
      path: 'test-results/html_renderer_fix_result.png', 
      fullPage: true 
    });
    
    // Final diagnosis
    console.log('\n🎯 FINAL DIAGNOSIS:');
    console.log('==================');
    
    if (htmlRendererCheck.sceneHost && hasActualContent) {
      console.log('✅ SUCCESS: HTML renderer fix worked!');
      console.log('   Scene host exists and content is rendering');
    } else if (htmlRendererCheck.sceneHost && !hasActualContent) {
      console.log('⚠️  PARTIAL: Scene host exists but no content');
      console.log('   HTML renderer is working but content not visible');
    } else if (htmlRendererCheck.htmlElements > 0 && !htmlRendererCheck.sceneHost) {
      console.log('⚠️  HTML RENDERER: HTML elements exist but no scene host');
      console.log('   HTML renderer loaded but rendering surface not created');
    } else {
      console.log('❌ HTML renderer fix did not resolve the issue');
      
      if (htmlRendererCheck.htmlElements > 0) {
        console.log('🔍 HTML renderer is loading but scene host still missing');
      } else {
        console.log('🔍 No HTML renderer elements found');
      }
    }
    
    console.log('\n📋 NEXT STEPS:');
    if (!htmlRendererCheck.sceneHost) {
      console.log('1. Move to Cypress for E2E testing as planned');
      console.log('2. Use Cypress to test authentication system');
      console.log('3. Cypress may provide better debugging insights');
    } else {
      console.log('✅ HTML renderer working - proceed with authentication testing');
    }
    
    console.log('\n🔗 Keeping browser open for manual inspection...');
    await page.waitForTimeout(10000);
    
  } catch (error) {
    console.error('❌ Test failed:', error.message);
  } finally {
    await browser.close();
  }
}

testHtmlRendererFix().catch(console.error);
