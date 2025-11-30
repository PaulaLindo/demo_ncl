// debug_flutter_app.js - Debug script to check Flutter app loading issues
const { chromium } = require('playwright');

class FlutterAppDebugger {
  constructor() {
    this.browser = null;
    this.page = null;
  }

  async setup() {
    console.log('🔍 Setting up Flutter App Debugger...');
    this.browser = await chromium.launch({ 
      headless: false,
      slowMo: 1000 
    });
    this.page = await this.browser.newPage();
    
    // Set up console logging
    this.page.on('console', msg => {
      console.log(`📝 Browser Console: ${msg.type()}: ${msg.text()}`);
    });
    
    this.page.on('pageerror', error => {
      console.error(`❌ Page Error: ${error.message}`);
    });
    
    await this.page.setViewportSize({ width: 1280, height: 720 });
    console.log('✅ Browser launched with console monitoring');
  }

  async debugFlutterApp() {
    try {
      console.log('📍 Navigating to Flutter app...');
      await this.page.goto('http://localhost:8080');
      
      // Wait for initial load
      await this.page.waitForTimeout(5000);
      
      // Check page content
      const content = await this.page.evaluate(() => {
        return {
          title: document.title,
          url: window.location.href,
          readyState: document.readyState,
          bodyHTML: document.body.innerHTML.substring(0, 1000),
          bodyText: document.body.innerText,
          hasFlutterEngine: !!window._flutter,
          hasFlutterLoader: !!document.querySelector('flutter-loader'),
          scripts: Array.from(document.querySelectorAll('script')).map(s => s.src || s.textContent?.substring(0, 50)),
          styles: Array.from(document.querySelectorAll('style')).map(s => s.textContent?.substring(0, 50)),
          errors: window.__flutter_errors || [],
          loadTime: performance.now()
        };
      });
      
      console.log('\n📊 Flutter App Analysis:');
      console.log(`Title: ${content.title}`);
      console.log(`URL: ${content.url}`);
      console.log(`Ready State: ${content.readyState}`);
      console.log(`Body Text Length: ${content.bodyText.length}`);
      console.log(`Flutter Engine: ${content.hasFlutterEngine ? '✅' : '❌'}`);
      console.log(`Flutter Loader: ${content.hasFlutterLoader ? '✅' : '❌'}`);
      console.log(`Scripts Found: ${content.scripts.length}`);
      console.log(`Styles Found: ${content.styles.length}`);
      console.log(`Load Time: ${content.loadTime}ms`);
      
      if (content.bodyText.length > 0) {
        console.log(`\n📄 Body Text Preview:\n${content.bodyText.substring(0, 500)}`);
      }
      
      if (content.bodyHTML.length > 0) {
        console.log(`\n🏗️ HTML Preview:\n${content.bodyHTML.substring(0, 500)}`);
      }
      
      // Take screenshot
      await this.page.screenshot({ path: 'test-results/debug_flutter_app.png', fullPage: true });
      
      // Wait longer and check if Flutter loads
      console.log('\n⏳ Waiting 10 seconds for Flutter to load...');
      await this.page.waitForTimeout(10000);
      
      // Check again after waiting
      const afterWait = await this.page.evaluate(() => {
        return {
          bodyText: document.body.innerText,
          bodyHTML: document.body.innerHTML.substring(0, 1000),
          hasFlutterApp: !!document.querySelector('flt-glass-pane, flutter-app, [flt-renderer]'),
          flutterElements: Array.from(document.querySelectorAll('*')).filter(el => 
            el.tagName.toLowerCase().includes('flt') || 
            el.getAttribute('flt-renderer') !== null
          ).length,
          buttons: Array.from(document.querySelectorAll('button')).length,
          inputs: Array.from(document.querySelectorAll('input')).length,
        };
      });
      
      console.log('\n📊 After Waiting Analysis:');
      console.log(`Body Text Length: ${afterWait.bodyText.length}`);
      console.log(`Flutter App Elements: ${afterWait.hasFlutterApp ? '✅' : '❌'}`);
      console.log(`Flutter Elements Count: ${afterWait.flutterElements}`);
      console.log(`Buttons: ${afterWait.buttons}`);
      console.log(`Inputs: ${afterWait.inputs}`);
      
      if (afterWait.bodyText.length > 0) {
        console.log(`\n📄 Body Text After Wait:\n${afterWait.bodyText.substring(0, 500)}`);
      }
      
      // Try to manually trigger Flutter app load
      console.log('\n🔄 Attempting to manually trigger Flutter app...');
      
      const manualTrigger = await this.page.evaluate(() => {
        try {
          // Try to find and initialize Flutter app
          if (window._flutter && window._flutter.loader) {
            window._flutter.loader.didCreateEngineInitializer().then(engineInitializer => {
              engineInitializer.initializeEngine({
                hostElement: document.body,
                assetBase: '',
              }).then(appRunner => {
                appRunner.runApp();
              });
            });
            return 'Flutter loader trigger attempted';
          }
          
          // Try to find flutter-app element
          const flutterApp = document.querySelector('flutter-app');
          if (flutterApp) {
            return 'flutter-app element found';
          }
          
          // Check for any Flutter-related scripts
          const flutterScripts = Array.from(document.querySelectorAll('script')).filter(s => 
            s.src && (s.src.includes('flutter') || s.src.includes('main.dart.js'))
          );
          
          if (flutterScripts.length > 0) {
            return `Found ${flutterScripts.length} Flutter scripts`;
          }
          
          return 'No Flutter initialization found';
          
        } catch (error) {
          return `Error: ${error.message}`;
        }
      });
      
      console.log(`🔄 Manual Trigger Result: ${manualTrigger}`);
      
      // Wait a bit more after manual trigger
      await this.page.waitForTimeout(5000);
      
      // Final check
      const finalCheck = await this.page.evaluate(() => {
        return {
          bodyText: document.body.innerText,
          buttons: Array.from(document.querySelectorAll('button')).map(btn => btn.innerText),
          hasContent: document.body.innerText.length > 10,
        };
      });
      
      console.log('\n🎯 Final Analysis:');
      console.log(`Has Content: ${finalCheck.hasContent ? '✅' : '❌'}`);
      console.log(`Buttons: ${finalCheck.buttons.join(', ')}`);
      
      if (finalCheck.hasContent) {
        console.log(`\n📄 Final Body Text:\n${finalCheck.bodyText.substring(0, 1000)}`);
      }
      
      await this.page.screenshot({ path: 'test-results/debug_flutter_final.png', fullPage: true });
      
    } catch (error) {
      console.error('❌ Debug error:', error);
      await this.page.screenshot({ path: 'test-results/debug_flutter_error.png', fullPage: true });
    }
  }

  async run() {
    await this.setup();
    await this.debugFlutterApp();
    await this.cleanup();
  }

  async cleanup() {
    if (this.browser) {
      await this.browser.close();
      console.log('🔚 Flutter app debugging completed');
    }
  }
}

// Run the debugger
const flutterDebugger = new FlutterAppDebugger();
flutterDebugger.run().catch(console.error);
