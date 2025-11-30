const { chromium } = require('playwright');

(async () => {
  console.log('🚀 Starting Direct UI Test for NCL App...');
  
  const browser = await chromium.launch({ 
    headless: false,
    slowMo: 500 // Slow down for better visibility
  });
  
  try {
    const page = await browser.newPage();
    
    // Enable console logging
    page.on('console', msg => console.log('📱 PAGE:', msg.text()));
    page.on('pageerror', err => console.log('❌ ERROR:', err.message));
    
    console.log('🌐 Navigating to NCL app...');
    await page.goto('http://localhost:8081', { 
      waitUntil: 'domcontentloaded',
      timeout: 30000 
    });
    
    console.log('⏳ Waiting for Flutter app to render...');
    await page.waitForTimeout(5000);
    
    // Take initial screenshot
    await page.screenshot({ path: 'ncl-initial-state.png', fullPage: true });
    console.log('📸 Initial screenshot saved');
    
    // Test 1: Check if login chooser screen appears
    console.log('🔍 Test 1: Looking for login chooser elements...');
    
    try {
      // Look for welcome text or login options
      const welcomeText = await page.locator('text=Welcome').first();
      const customerLogin = await page.locator('text=Customer').first();
      const staffLogin = await page.locator('text=Staff').first();
      const adminLogin = await page.locator('text=Admin').first();
      
      let foundElements = [];
      
      if (await welcomeText.isVisible()) {
        foundElements.push('Welcome text');
        console.log('✅ Found welcome text');
      }
      
      if (await customerLogin.isVisible()) {
        foundElements.push('Customer login');
        console.log('✅ Found customer login option');
      }
      
      if (await staffLogin.isVisible()) {
        foundElements.push('Staff login');
        console.log('✅ Found staff login option');
      }
      
      if (await adminLogin.isVisible()) {
        foundElements.push('Admin login');
        console.log('✅ Found admin login option');
      }
      
      if (foundElements.length > 0) {
        console.log(`🎉 SUCCESS: Found ${foundElements.join(', ')}`);
        
        // Test 2: Try clicking on Customer login
        console.log('🔍 Test 2: Attempting Customer login flow...');
        
        if (await customerLogin.isVisible()) {
          await customerLogin.click();
          console.log('👆 Clicked Customer login');
          await page.waitForTimeout(3000);
          
          // Look for login form elements
          const emailField = await page.locator('input[type="email"], input[placeholder*="email"], input[name="email"]').first();
          const passwordField = await page.locator('input[type="password"], input[placeholder*="password"], input[name="password"]').first();
          const signInButton = await page.locator('button:has-text("Sign"), button:has-text("Login"), button[type="submit"]').first();
          
          if (await emailField.isVisible()) {
            console.log('✅ Found email field');
            await emailField.fill('customer@example.com');
            console.log('📝 Filled email field');
          }
          
          if (await passwordField.isVisible()) {
            console.log('✅ Found password field');
            await passwordField.fill('password123');
            console.log('📝 Filled password field');
          }
          
          if (await signInButton.isVisible()) {
            console.log('✅ Found sign in button');
            await signInButton.click();
            console.log('👆 Clicked sign in button');
            await page.waitForTimeout(3000);
            
            // Check if we're logged in
            const dashboardText = await page.locator('text=Welcome, text=Dashboard, text=Home').first();
            if (await dashboardText.isVisible()) {
              console.log('🎉 SUCCESS: Login successful - Dashboard visible');
            } else {
              console.log('⚠️ Login may have failed - no dashboard found');
            }
          } else {
            console.log('❌ No sign in button found');
          }
        }
        
      } else {
        console.log('❌ No login elements found');
        
        // Try to find any interactive elements
        const buttons = await page.$$('button, [role="button"], .clickable');
        console.log(`Found ${buttons.length} potential clickable elements`);
        
        const textElements = await page.$$eval('*', elements => 
          elements.filter(el => el.textContent && el.textContent.trim().length > 0)
            .map(el => el.textContent.trim())
            .slice(0, 10)
        );
        console.log('Text content found:', textElements);
      }
      
    } catch (error) {
      console.error('❌ Test error:', error.message);
    }
    
    // Final screenshot
    await page.screenshot({ path: 'ncl-final-state.png', fullPage: true });
    console.log('📸 Final screenshot saved');
    
    console.log('✅ UI Test completed. Browser will stay open for 30 seconds...');
    await page.waitForTimeout(30000);
    
  } catch (error) {
    console.error('❌ Fatal error:', error);
  } finally {
    await browser.close();
  }
})();
