// e2e-tests/test_clean_environment.js - Test Flutter with clean Node.js environment
const { chromium } = require('playwright');

async function testCleanEnvironment() {
  console.log('🧹 TESTING FLUTTER WITH CLEAN ENVIRONMENT');
  console.log('==========================================');
  
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
    console.log(`🚀 Loading Flutter app with clean environment...`);
    
    // Navigate to Flutter app
    await page.goto('http://localhost:8101', { 
      waitUntil: 'networkidle',
      timeout: 30000 
    });
    
    // Wait for Flutter to initialize
    await page.waitForTimeout(15000);
    
    console.log('\n🔍 CLEAN ENVIRONMENT ANALYSIS');
    console.log('=============================');
    
    // Check Flutter elements
    const flutterCheck = await page.evaluate(() => {
      const results = {
        flutterView: !!document.querySelector('flutter-view'),
        sceneHost: !!document.querySelector('flt-scene-host'),
        glassPane: !!document.querySelector('flt-glass-pane'),
        canvasElements: document.querySelectorAll('canvas').length,
        htmlElements: document.querySelectorAll('flt-render-box, flt-picture, div[style*="transform"]').length,
        bodyText: document.body.textContent || '',
        timestamp: Date.now()
      };
      
      return results;
    });
    
    console.log(`🦋 Flutter View: ${flutterCheck.flutterView ? 'EXISTS' : 'MISSING'}`);
    console.log(`🎬 Scene Host: ${flutterCheck.sceneHost ? 'EXISTS' : 'MISSING'}`);
    console.log(`🪟 Glass Pane: ${flutterCheck.glassPane ? 'EXISTS' : 'MISSING'}`);
    console.log(`🎨 Canvas Elements: ${flutterCheck.canvasElements}`);
    console.log(`🌐 HTML Elements: ${flutterCheck.htmlElements}`);
    console.log(`📝 Body Length: ${flutterCheck.bodyText.length}`);
    
    // Check for actual content
    const hasActualContent = flutterCheck.bodyText.length > 2000 && 
                           !flutterCheck.bodyText.startsWith('flutter-view flt-scene-host');
    
    console.log(`\n🎯 CONTENT ANALYSIS:`);
    console.log(`📝 Body length: ${flutterCheck.bodyText.length}`);
    console.log(`🎯 Has actual content: ${hasActualContent ? 'YES' : 'NO'}`);
    
    if (hasActualContent) {
      console.log(`📄 Content preview: "${flutterCheck.bodyText.substring(0, 200)}..."`);
    }
    
    // Check for authentication elements
    const hasAuthElements = flutterCheck.bodyText.includes('Login') || 
                           flutterCheck.bodyText.includes('Email') || 
                           flutterCheck.bodyText.includes('Password') ||
                           flutterCheck.bodyText.includes('Customer') ||
                           flutterCheck.bodyText.includes('Staff') ||
                           flutterCheck.bodyText.includes('Admin');
    
    console.log(`🔐 Authentication elements: ${hasAuthElements ? 'YES' : 'NO'}`);
    
    // Test login route
    console.log(`\n📍 Testing login route...`);
    await page.goto('http://localhost:8101/login/customer', { waitUntil: 'networkidle' });
    await page.waitForTimeout(10000);
    
    const loginBodyText = await page.textContent('body');
    const loginLength = loginBodyText.length;
    const hasLoginContent = loginBodyText.includes('Email') || loginBodyText.includes('Password');
    
    console.log(`📝 Login page length: ${loginLength}`);
    console.log(`🔐 Login form content: ${hasLoginContent ? 'YES' : 'NO'}`);
    
    // Take screenshots
    await page.screenshot({ 
      path: 'test-results/clean_environment_main.png', 
      fullPage: true 
    });
    
    await page.goto('http://localhost:8101/login/customer', { waitUntil: 'networkidle' });
    await page.screenshot({ 
      path: 'test-results/clean_environment_login.png', 
      fullPage: true 
    });
    
    // Final diagnosis
    console.log('\n🎯 FINAL DIAGNOSIS - CLEAN ENVIRONMENT');
    console.log('=====================================');
    
    if (flutterCheck.sceneHost && hasActualContent) {
      console.log('✅ SUCCESS: Clean environment fixed the issue!');
      console.log('   Scene host exists and content is rendering');
      console.log('   Authentication system ready for testing');
    } else if (flutterCheck.sceneHost && !hasActualContent) {
      console.log('⚠️  PARTIAL: Scene host exists but no content');
      console.log('   Clean environment helped but content still missing');
    } else if (!flutterCheck.sceneHost && flutterCheck.flutterView) {
      console.log('❌ ISSUE PERSISTS: Scene host still missing');
      console.log('   Clean environment did not resolve the rendering issue');
      console.log('   This confirms a deeper Flutter web engine problem');
    } else {
      console.log('❌ NO IMPROVEMENT: Flutter elements still missing');
    }
    
    console.log('\n📋 NEXT STEPS:');
    if (flutterCheck.sceneHost && hasActualContent) {
      console.log('✅ SUCCESS: Test authentication system');
      console.log('✅ SUCCESS: All routes should work');
      console.log('✅ SUCCESS: Ready for production testing');
    } else {
      console.log('1. Try Docker container environment');
      console.log('2. Test on different machine');
      console.log('3. Consider production deployment');
      console.log('4. Use alternative web framework');
    }
    
    console.log('\n🔗 Keeping browser open for manual inspection...');
    await page.waitForTimeout(10000);
    
  } catch (error) {
    console.error('❌ Test failed:', error.message);
  } finally {
    await browser.close();
  }
}

testCleanEnvironment().catch(console.error);
