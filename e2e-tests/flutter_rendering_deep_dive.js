// e2e-tests/flutter_rendering_deep_dive.js - Deep dive into Flutter rendering issues
const { chromium } = require('playwright');

async function flutterRenderingDeepDive() {
  console.log('🔬 FLUTTER RENDERING DEEP DIVE');
  console.log('==============================');
  
  const browser = await chromium.launch({ 
    headless: false,
    devtools: true
  });
  
  const page = await browser.newPage();
  
  // Set up comprehensive monitoring
  const consoleMessages = [];
  const networkRequests = [];
  const errors = [];
  
  page.on('console', msg => {
    consoleMessages.push({
      type: msg.type(),
      text: msg.text(),
      timestamp: Date.now()
    });
    console.log(`📢 [${msg.type().toUpperCase()}] ${msg.text()}`);
  });
  
  page.on('request', request => {
    networkRequests.push({
      url: request.url(),
      method: request.method(),
      timestamp: Date.now()
    });
  });
  
  page.on('pageerror', error => {
    errors.push({
      message: error.message,
      stack: error.stack,
      timestamp: Date.now()
    });
    console.error('🚨 PAGE ERROR:', error.message);
  });
  
  try {
    console.log(`🚀 Loading Flutter app...`);
    
    // Navigate to Flutter app
    await page.goto('http://localhost:8095', { 
      waitUntil: 'networkidle',
      timeout: 30000 
    });
    
    // Wait for initial load
    await page.waitForTimeout(5000);
    
    console.log('\n🔍 PHASE 1: Initial DOM Analysis');
    console.log('================================');
    
    // Analyze initial state
    const initialState = await page.evaluate(() => {
      const body = document.body;
      const flutterView = document.querySelector('flutter-view');
      
      return {
        bodyChildren: body.children.length,
        bodyText: body.textContent || '',
        flutterViewExists: !!flutterView,
        sceneHostExists: !!document.querySelector('flt-scene-host'),
        glassPaneExists: !!document.querySelector('flt-glass-pane'),
        flutterViewChildren: flutterView ? flutterView.children.length : 0,
        timestamp: Date.now()
      };
    });
    
    console.log(`📄 Body children: ${initialState.bodyChildren}`);
    console.log(`📝 Body text length: ${initialState.bodyText.length}`);
    console.log(`🦋 Flutter view: ${initialState.flutterViewExists ? 'EXISTS' : 'MISSING'}`);
    console.log(`🎬 Scene host: ${initialState.sceneHostExists ? 'EXISTS' : 'MISSING'}`);
    console.log(`🪟 Glass pane: ${initialState.glassPaneExists ? 'EXISTS' : 'MISSING'}`);
    console.log(`👶 Flutter view children: ${initialState.flutterViewChildren}`);
    
    if (initialState.bodyText.length > 100) {
      console.log(`📄 Body preview: "${initialState.bodyText.substring(0, 150)}..."`);
    }
    
    console.log('\n🔍 PHASE 2: Flutter Initialization Monitoring');
    console.log('==========================================');
    
    // Monitor Flutter initialization over time
    const monitoringResults = [];
    
    for (let i = 0; i < 10; i++) {
      await page.waitForTimeout(2000);
      
      const currentState = await page.evaluate(() => {
        const flutterView = document.querySelector('flutter-view');
        const sceneHost = document.querySelector('flt-scene-host');
        
        return {
          flutterViewExists: !!flutterView,
          sceneHostExists: !!sceneHost,
          flutterViewChildren: flutterView ? flutterView.children.length : 0,
          bodyTextLength: document.body.textContent.length,
          timestamp: Date.now()
        };
      });
      
      monitoringResults.push(currentState);
      
      console.log(`⏰ ${i + 1}: Flutter=${currentState.flutterViewExists ? '✅' : '❌'} Scene=${currentState.sceneHostExists ? '✅' : '❌'} Children=${currentState.flutterViewChildren} Length=${currentState.bodyTextLength}`);
      
      // If scene host appears, break early
      if (currentState.sceneHostExists) {
        console.log('🎉 Scene host appeared!');
        break;
      }
    }
    
    console.log('\n🔍 PHASE 3: Console and Network Analysis');
    console.log('=====================================');
    
    // Analyze console messages for Flutter activity
    const flutterMessages = consoleMessages.filter(msg => 
      msg.text.toLowerCase().includes('flutter') ||
      msg.text.toLowerCase().includes('dart') ||
      msg.text.includes('🚀') ||
      msg.text.includes('🌐') ||
      msg.text.includes('🦋')
    );
    
    console.log(`📢 Flutter-related console messages: ${flutterMessages.length}`);
    flutterMessages.forEach((msg, index) => {
      console.log(`  ${index + 1}. [${msg.type.toUpperCase()}] ${msg.text}`);
    });
    
    // Analyze network requests
    const flutterRequests = networkRequests.filter(req => 
      req.url.includes('flutter') ||
      req.url.includes('dart') ||
      req.url.includes('.js')
    );
    
    console.log(`🌐 Flutter-related network requests: ${flutterRequests.length}`);
    flutterRequests.slice(0, 10).forEach((req, index) => {
      console.log(`  ${index + 1}. ${req.method} ${req.url}`);
    });
    
    // Check for errors
    console.log(`🚨 Page errors: ${errors.length}`);
    errors.forEach((error, index) => {
      console.log(`  ${index + 1}. ${error.message}`);
    });
    
    console.log('\n🔍 PHASE 4: DOM Deep Dive');
    console.log('========================');
    
    // Deep dive into DOM structure
    const domDeepDive = await page.evaluate(() => {
      const results = {
        allElements: [],
        flutterElements: [],
        potentialIssues: []
      };
      
      // Get all elements
      const allElements = document.querySelectorAll('*');
      results.allElements = allElements.length;
      
      // Find Flutter elements
      results.flutterElements = Array.from(document.querySelectorAll('*'))
        .filter(el => 
          el.tagName.toLowerCase().includes('flt-') || 
          el.tagName.toLowerCase() === 'flutter-view'
        )
        .map(el => ({
          tagName: el.tagName,
          id: el.id,
          className: el.className,
          children: el.children.length,
          display: window.getComputedStyle(el).display,
          visibility: window.getComputedStyle(el).visibility,
          opacity: window.getComputedStyle(el).opacity,
          rect: el.getBoundingClientRect(),
          hasText: (el.textContent || '').length > 0
        }));
      
      // Check for potential issues
      const body = document.body;
      if (body.textContent && body.textContent.startsWith('flutter-view flt-scene-host')) {
        results.potentialIssues.push('Body contains only CSS boilerplate');
      }
      
      if (results.flutterElements.length === 0) {
        results.potentialIssues.push('No Flutter elements found');
      }
      
      const sceneHost = document.querySelector('flt-scene-host');
      if (!sceneHost) {
        results.potentialIssues.push('Scene host missing - critical rendering issue');
      }
      
      return results;
    });
    
    console.log(`📄 Total DOM elements: ${domDeepDive.allElements}`);
    console.log(`🦋 Flutter elements: ${domDeepDive.flutterElements.length}`);
    
    if (domDeepDive.flutterElements.length > 0) {
      console.log('🔍 Flutter elements found:');
      domDeepDive.flutterElements.forEach((el, index) => {
        console.log(`  ${index + 1}. ${el.tagName} - ${el.display} / ${el.visibility} / ${el.opacity}`);
        console.log(`     Children: ${el.children}, Has text: ${el.hasText}`);
        if (el.rect.width > 0 && el.rect.height > 0) {
          console.log(`     Size: ${el.rect.width}x${el.rect.height}`);
        }
      });
    }
    
    if (domDeepDive.potentialIssues.length > 0) {
      console.log('⚠️  Potential issues found:');
      domDeepDive.potentialIssues.forEach((issue, index) => {
        console.log(`  ${index + 1}. ${issue}`);
      });
    }
    
    console.log('\n🔍 PHASE 5: Attempt Manual Intervention');
    console.log('===================================');
    
    // Try to manually trigger Flutter rendering
    const manualAttempt = await page.evaluate(() => {
      const results = { attempts: [], success: false };
      
      // Attempt 1: Check if we can find any Flutter initialization functions
      if (window.flutter || window._flutter) {
        results.attempts.push('Flutter global object found');
      }
      
      // Attempt 2: Try to trigger window resize
      window.dispatchEvent(new Event('resize'));
      results.attempts.push('Window resize triggered');
      
      // Attempt 3: Check if scene host appears after resize
      setTimeout(() => {
        const sceneHost = document.querySelector('flt-scene-host');
        if (sceneHost) {
          results.success = true;
          results.attempts.push('Scene host appeared after resize');
        }
      }, 1000);
      
      return results;
    });
    
    console.log('🔧 Manual intervention attempts:');
    manualAttempt.attempts.forEach((attempt, index) => {
      console.log(`  ${index + 1}. ${attempt}`);
    });
    
    // Wait and check if manual intervention worked
    await page.waitForTimeout(2000);
    
    const finalCheck = await page.evaluate(() => ({
      sceneHostExists: !!document.querySelector('flt-scene-host'),
      bodyTextLength: document.body.textContent.length,
      timestamp: Date.now()
    }));
    
    console.log(`🎯 Final check - Scene host: ${finalCheck.sceneHostExists ? 'EXISTS' : 'MISSING'}`);
    console.log(`📝 Final body length: ${finalCheck.bodyTextLength}`);
    
    // Take final screenshot
    await page.screenshot({ 
      path: 'test-results/flutter_deep_dive_final.png', 
      fullPage: true 
    });
    
    console.log('\n🎯 FINAL DIAGNOSIS');
    console.log('==================');
    
    if (finalCheck.sceneHostExists) {
      console.log('✅ SUCCESS: Flutter rendering works!');
    } else {
      console.log('❌ CONFIRMED: Flutter web rendering issue persists');
      
      if (domDeepDive.flutterElements.length > 0) {
        console.log('🔍 Flutter elements exist but scene host missing');
        console.log('   This suggests Flutter partially initializes but fails at rendering surface creation');
      } else {
        console.log('🔍 No Flutter elements found');
        console.log('   This suggests Flutter fails to initialize completely');
      }
      
      if (errors.length > 0) {
        console.log('🚨 JavaScript errors detected - may be causing the issue');
      }
      
      if (flutterMessages.length === 0) {
        console.log('📢 No Flutter console messages - initialization may be failing silently');
      }
    }
    
    console.log('\n📋 RECOMMENDATIONS:');
    if (!finalCheck.sceneHostExists) {
      console.log('1. Check Flutter web engine installation');
      console.log('2. Verify browser compatibility (try different browser)');
      console.log('3. Check for JavaScript errors in console');
      console.log('4. Try clearing browser cache and Flutter build cache');
      console.log('5. Consider using a different Flutter version');
    }
    
    console.log('\n🔗 Keeping browser open for manual inspection...');
    await page.waitForTimeout(10000); // Keep open for manual inspection
    
  } catch (error) {
    console.error('❌ Test failed:', error.message);
  } finally {
    await browser.close();
  }
}

flutterRenderingDeepDive().catch(console.error);
