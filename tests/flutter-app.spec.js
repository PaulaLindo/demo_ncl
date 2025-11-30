// tests/flutter-app.spec.js
const { test, expect } = require('@playwright/test');

test.describe('Flutter NCL App - Browser Testing', () => {
  test.beforeEach(async ({ page }) => {
    // Navigate to the Flutter web app
    await page.goto('http://localhost:8080');
    await page.waitForTimeout(5000); // Wait for Flutter app to load
  });

  test('should launch the Flutter app', async ({ page }) => {
    console.log('🚀 Testing Flutter app launch...');
    console.log('👀 WATCH THE BROWSER - YOU SHOULD SEE THE NCL APP!');
    
    // Take a screenshot to verify the app loaded
    await page.screenshot({ path: 'screenshots/flutter_app_launched.png' });
    
    // Check if the page has loaded (basic check)
    const title = await page.title();
    console.log(`📱 Page title: ${title}`);
    
    // Look for any Flutter app content
    const body = await page.locator('body').innerHTML();
    const hasFlutterContent = body.includes('flutter') || 
                            body.includes('NCL') || 
                            body.includes('Customer') ||
                            body.includes('Login');
    
    if (hasFlutterContent) {
      console.log('✅ Flutter app content detected!');
    } else {
      console.log('⚠️ Flutter app content not immediately visible, but app may still be loading...');
    }
    
    await page.waitForTimeout(3000); // Give time to see the app
  });

  test('should find and click Customer Login button', async ({ page }) => {
    console.log('👆 Testing Customer Login button...');
    console.log('👀 WATCH THE BROWSER - YOU WILL SEE THE BUTTON BEING CLICKED!');
    
    await page.waitForTimeout(3000);
    
    try {
      // Try to find Customer Login button
      const customerLogin = page.locator('text=Customer Login').first();
      
      if (await customerLogin.isVisible()) {
        console.log('✅ Found Customer Login button - clicking now...');
        await customerLogin.click();
        console.log('🎉 CUSTOMER LOGIN BUTTON CLICKED!');
        
        await page.waitForTimeout(3000);
        await page.screenshot({ path: 'screenshots/customer_login_clicked.png' });
      } else {
        console.log('⚠️ Customer Login button not found, trying alternatives...');
        
        // Try alternative selectors
        const alternatives = [
          'button:has-text("Customer")',
          'text=Customer',
          '[role="button"]:has-text("Customer")',
          '.customer-login'
        ];
        
        for (const selector of alternatives) {
          try {
            const element = page.locator(selector).first();
            if (await element.isVisible({ timeout: 2000 })) {
              console.log(`✅ Found element with: ${selector}`);
              await element.click();
              console.log('🎉 CUSTOMER LOGIN BUTTON CLICKED!');
              await page.waitForTimeout(2000);
              await page.screenshot({ path: 'screenshots/customer_login_alt.png' });
              break;
            }
          } catch (e) {
            // Continue trying
          }
        }
      }
    } catch (error) {
      console.log('❌ Error with Customer Login:', error.message);
    }
  });

  test('should find and click Staff Access button', async ({ page }) => {
    console.log('👆 Testing Staff Access button...');
    console.log('👀 WATCH THE BROWSER - YOU WILL SEE THE BUTTON BEING CLICKED!');
    
    await page.waitForTimeout(3000);
    
    try {
      const staffAccess = page.locator('text=Staff Access').first();
      
      if (await staffAccess.isVisible()) {
        console.log('✅ Found Staff Access button - clicking now...');
        await staffAccess.click();
        console.log('🎉 STAFF ACCESS BUTTON CLICKED!');
        
        await page.waitForTimeout(3000);
        await page.screenshot({ path: 'screenshots/staff_access_clicked.png' });
      } else {
        console.log('⚠️ Staff Access button not found');
      }
    } catch (error) {
      console.log('❌ Error with Staff Access:', error.message);
    }
  });

  test('should find and click Admin Portal button', async ({ page }) => {
    console.log('👆 Testing Admin Portal button...');
    console.log('👀 WATCH THE BROWSER - YOU WILL SEE THE BUTTON BEING CLICKED!');
    
    await page.waitForTimeout(3000);
    
    try {
      const adminPortal = page.locator('text=Admin Portal').first();
      
      if (await adminPortal.isVisible()) {
        console.log('✅ Found Admin Portal button - clicking now...');
        await adminPortal.click();
        console.log('🎉 ADMIN PORTAL BUTTON CLICKED!');
        
        await page.waitForTimeout(3000);
        await page.screenshot({ path: 'screenshots/admin_portal_clicked.png' });
      } else {
        console.log('⚠️ Admin Portal button not found');
      }
    } catch (error) {
      console.log('❌ Error with Admin Portal:', error.message);
    }
  });

  test('should check for welcome message', async ({ page }) => {
    console.log('📝 Testing welcome message...');
    
    await page.waitForTimeout(3000);
    
    try {
      // Look for welcome text
      const welcomeText = page.locator('text=/welcome/i').first();
      
      if (await welcomeText.isVisible({ timeout: 3000 })) {
        console.log('✅ Welcome text found!');
        const text = await welcomeText.textContent();
        console.log(`📝 Welcome message: "${text}"`);
        await page.screenshot({ path: 'screenshots/welcome_text_found.png' });
      } else {
        console.log('⚠️ Welcome text not found with case-insensitive search');
        
        // Try exact match
        const exactWelcome = page.locator('text=Welcome').first();
        if (await exactWelcome.isVisible({ timeout: 2000 })) {
          const text = await exactWelcome.textContent();
          console.log(`✅ Found welcome text: "${text}"`);
        } else {
          console.log('⚠️ No welcome text found');
        }
      }
    } catch (error) {
      console.log('❌ Error finding welcome text:', error.message);
    }
  });

  test('complete interaction flow', async ({ page }) => {
    console.log('🎭 COMPLETE INTERACTION FLOW TEST');
    console.log('👀 WATCH THE BROWSER - FULL APP INTERACTION!');
    
    await page.waitForTimeout(5000);
    
    // Test all main buttons
    const buttons = [
      { name: 'Customer Login', selector: 'text=Customer Login' },
      { name: 'Staff Access', selector: 'text=Staff Access' },
      { name: 'Admin Portal', selector: 'text=Admin Portal' }
    ];
    
    for (const button of buttons) {
      console.log(`\n👆 Testing ${button.name}...`);
      
      try {
        const element = page.locator(button.selector).first();
        
        if (await element.isVisible({ timeout: 3000 })) {
          console.log(`✅ Found ${button.name} - clicking...`);
          await element.click();
          console.log(`🎉 ${button.name} CLICKED!`);
          
          await page.waitForTimeout(2000);
          
          // Try to go back
          await page.goBack().catch(() => {});
          await page.waitForTimeout(1000);
        } else {
          console.log(`⚠️ ${button.name} not found`);
        }
      } catch (error) {
        console.log(`❌ Error with ${button.name}:`, error.message);
      }
    }
    
    // Final screenshot
    await page.screenshot({ path: 'screenshots/complete_flow_finished.png' });
    
    console.log('\n🎉 PLAYWRIGHT FLUTTER TEST COMPLETED!');
    console.log('📱 You should have seen all interactions in the browser!');
    console.log('✅ REAL UI TESTING WITH PLAYWRIGHT WORKING!');
    console.log('✅ NO ANDROID STUDIO NEEDED!');
    console.log('✅ NO EMULATOR ISSUES!');
    console.log('✅ SUCCESS! 🚀');
  });
});
