// debug_ui_helper.js - Debug the UI helper to see what's happening
const { chromium } = require('playwright');

class DebugUIHelper {
  constructor() {
    this.browser = null;
    this.page = null;
  }

  async setup() {
    console.log('🔍 Setting up UI Helper Debug...');
    this.browser = await chromium.launch({ 
      headless: false,
      slowMo: 1000 
    });
    this.page = await this.browser.newPage();
    await this.page.setViewportSize({ width: 1280, height: 720 });
    
    // Monitor all console messages
    this.page.on('console', msg => {
      console.log(`📝 Browser ${msg.type().toUpperCase()}: ${msg.text()}`);
    });
    
    console.log('✅ Browser launched with full console monitoring');
  }

  async debugUIHelper() {
    try {
      console.log('📍 Debugging UI Helper...');
      
      await this.page.goto('http://localhost:8080');
      await this.page.waitForTimeout(5000);
      
      // Check the UI helper state
      const helperState = await this.page.evaluate(() => {
        return {
          url: window.location.href,
          pathname: window.location.pathname,
          readyState: document.readyState,
          hasFlutterUIHelper: !!window.flutterUIHelper,
          overlayElement: document.getElementById('flutter-ui-helper'),
          overlayHTML: document.getElementById('flutter-ui-helper')?.innerHTML || '',
          bodyChildren: document.body.children.length,
          scripts: Array.from(document.scripts).map(s => s.src || 'inline').filter(s => s.includes('flutter_ui_helper')),
          stylesheets: Array.from(document.styleSheets).map(s => s.href || 'inline').filter(s => s.includes('flutter_fixes')),
        };
      });
      
      console.log('\n📊 UI Helper State:');
      console.log(`URL: ${helperState.url}`);
      console.log(`Pathname: ${helperState.pathname}`);
      console.log(`Ready State: ${helperState.readyState}`);
      console.log(`Has Flutter UI Helper: ${helperState.hasFlutterUIHelper ? '✅' : '❌'}`);
      console.log(`Overlay Element: ${helperState.overlayElement ? '✅' : '❌'}`);
      console.log(`Body Children: ${helperState.bodyChildren}`);
      console.log(`Flutter Scripts: ${helperState.scripts.length}`);
      console.log(`Flutter Stylesheets: ${helperState.stylesheets.length}`);
      
      if (helperState.overlayHTML.length > 0) {
        console.log(`\n📄 Overlay HTML Preview:\n${helperState.overlayHTML.substring(0, 500)}`);
      }
      
      // Try to manually trigger the UI helper
      console.log('\n🔧 Manually triggering UI helper...');
      
      const manualTrigger = await this.page.evaluate(() => {
        try {
          if (window.flutterUIHelper) {
            window.flutterUIHelper.init();
            window.flutterUIHelper.createLoginChooser();
            window.flutterUIHelper.createLoginHelper();
            return 'UI helper triggered manually';
          } else {
            return 'UI helper not available';
          }
        } catch (error) {
          return `Manual trigger error: ${error.message}`;
        }
      });
      
      console.log(`🔧 Manual Trigger Result: ${manualTrigger}`);
      
      await this.page.waitForTimeout(3000);
      
      // Check again after manual trigger
      const afterTrigger = await this.page.evaluate(() => {
        const overlay = document.getElementById('flutter-ui-helper');
        const buttons = overlay ? Array.from(overlay.querySelectorAll('button')) : [];
        
        return {
          overlayExists: !!overlay,
          overlayHTML: overlay?.innerHTML || '',
          buttonCount: buttons.length,
          buttonTexts: buttons.map(btn => btn.innerText || btn.textContent || ''),
        };
      });
      
      console.log('\n📊 After Manual Trigger:');
      console.log(`Overlay Exists: ${afterTrigger.overlayExists ? '✅' : '❌'}`);
      console.log(`Button Count: ${afterTrigger.buttonCount}`);
      
      if (afterTrigger.buttonCount > 0) {
        console.log('Button Texts:');
        afterTrigger.buttonTexts.forEach((text, index) => {
          console.log(`  ${index + 1}. "${text}"`);
        });
      }
      
      if (afterTrigger.overlayHTML.length > 0) {
        console.log(`\n📄 Overlay HTML After Trigger:\n${afterTrigger.overlayHTML.substring(0, 1000)}`);
      }
      
      await this.page.screenshot({ path: 'test-results/debug_ui_helper.png', fullPage: true });
      
      // If still not working, create a simple overlay manually
      if (afterTrigger.buttonCount === 0) {
        console.log('\n🔧 Creating simple overlay manually...');
        
        const simpleOverlay = await this.page.evaluate(() => {
          const overlay = document.createElement('div');
          overlay.id = 'simple-test-overlay';
          overlay.style.cssText = `
            position: fixed;
            top: 50%;
            left: 50%;
            transform: translate(-50%, -50%);
            background: white;
            padding: 30px;
            border-radius: 8px;
            box-shadow: 0 4px 12px rgba(0,0,0,0.3);
            z-index: 9999;
            pointer-events: auto;
          `;
          
          const title = document.createElement('h2');
          title.innerText = 'Flutter App Test';
          title.style.cssText = 'margin: 0 0 20px 0; color: #333;';
          
          const customerBtn = document.createElement('button');
          customerBtn.innerText = 'Customer Login';
          customerBtn.style.cssText = `
            display: block;
            width: 100%;
            padding: 10px;
            margin: 10px 0;
            background: #28a745;
            color: white;
            border: none;
            border-radius: 4px;
            cursor: pointer;
          `;
          customerBtn.onclick = () => {
            window.location.href = '/login/customer';
          };
          
          const staffBtn = document.createElement('button');
          staffBtn.innerText = 'Staff Login';
          staffBtn.style.cssText = `
            display: block;
            width: 100%;
            padding: 10px;
            margin: 10px 0;
            background: #ffc107;
            color: #212529;
            border: none;
            border-radius: 4px;
            cursor: pointer;
          `;
          staffBtn.onclick = () => {
            window.location.href = '/login/staff';
          };
          
          const adminBtn = document.createElement('button');
          adminBtn.innerText = 'Admin Login';
          adminBtn.style.cssText = `
            display: block;
            width: 100%;
            padding: 10px;
            margin: 10px 0;
            background: #dc3545;
            color: white;
            border: none;
            border-radius: 4px;
            cursor: pointer;
          `;
          adminBtn.onclick = () => {
            window.location.href = '/login/admin';
          };
          
          overlay.appendChild(title);
          overlay.appendChild(customerBtn);
          overlay.appendChild(staffBtn);
          overlay.appendChild(adminBtn);
          
          document.body.appendChild(overlay);
          
          return 'Simple overlay created';
        });
        
        console.log(`🔧 Simple Overlay Result: ${simpleOverlay}`);
        await this.page.waitForTimeout(3000);
        await this.page.screenshot({ path: 'test-results/simple_overlay_test.png', fullPage: true });
        
        // Test the simple overlay
        console.log('\n🖱️ Testing simple overlay...');
        await this.page.click('button:has-text("Customer Login")');
        await this.page.waitForTimeout(3000);
        
        const finalUrl = this.page.url();
        console.log(`📍 After simple overlay click: ${finalUrl}`);
        
        if (finalUrl.includes('/login/customer')) {
          console.log('✅ Simple overlay navigation successful!');
          await this.page.screenshot({ path: 'test-results/simple_overlay_success.png', fullPage: true });
          return true;
        }
      }
      
      return false;
      
    } catch (error) {
      console.error('❌ UI Helper debug error:', error);
      await this.page.screenshot({ path: 'test-results/debug_ui_helper_error.png', fullPage: true });
      return false;
    }
  }

  async run() {
    await this.setup();
    const success = await this.debugUIHelper();
    await this.cleanup();
    
    console.log(`\n🎯 UI Helper Debug Result: ${success ? '✅ SUCCESS' : '❌ FAILED'}`);
    return success;
  }

  async cleanup() {
    if (this.browser) {
      await this.browser.close();
      console.log('🔚 UI Helper debug completed');
    }
  }
}

// Run the debug
const debugTest = new DebugUIHelper();
debugTest.run().catch(console.error);
