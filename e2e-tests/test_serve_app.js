// e2e-tests/test_serve_app.js - Test the app served with proper routing
const { chromium } = require('playwright');

const BASE_URL = 'http://localhost:8084';

async function testServedApp() {
  console.log('🍽️ TESTING SERVED FLUTTER WEB APP');
  console.log('=================================');
  
  const browser = await chromium.launch({ headless: false });
  const page = await browser.newPage();
  
  try {
    console.log(`🚀 Navigating to: ${BASE_URL}`);
    await page.goto(BASE_URL, { waitUntil: 'networkidle' });
    
    // Wait for content to load
    await page.waitForTimeout(10000);
    
    // Take screenshot
    await page.screenshot({ path: 'test-results/served_app_test.png', fullPage: true });
    
    // Check content
    const bodyText = await page.textContent('body');
    const bodyTextLength = bodyText.length;
    
    console.log(`📝 Body Length: ${bodyTextLength}`);
    console.log(`📄 Body Preview: "${bodyText.substring(0, 300)}..."`);
    
    // Check for Flutter indicators
    const hasFlutter = bodyText.includes('flutter-view') || 
                      bodyText.includes('flt-scene-host') ||
                      bodyText.includes('flt-semantic');
    
    console.log(`🦋 Flutter Loaded: ${hasFlutter ? 'YES' : 'NO'}`);
    
    // Check for actual content (not just CSS)
    const hasActualContent = bodyText.length > 2000 && 
                           !bodyText.startsWith('flutter-view flt-scene-host');
    
    console.log(`🎯 Has Actual Content: ${hasActualContent ? 'YES' : 'NO'}`);
    
    // Test specific routes
    const routes = ['/login/customer', '/customer/home', '/staff/home', '/admin/home'];
    
    for (const route of routes) {
      console.log(`\n📍 Testing route: ${route}`);
      await page.goto(`${BASE_URL}${route}`, { waitUntil: 'networkidle' });
      await page.waitForTimeout(5000);
      
      const routeBodyText = await page.textContent('body');
      const routeLength = routeBodyText.length;
      
      console.log(`  📝 Length: ${routeLength}`);
      console.log(`  🎯 Has Content: ${routeLength > 1000 ? 'YES' : 'NO'}`);
      
      // Check for specific content
      const hasLoginContent = routeBodyText.includes('Email') || routeBodyText.includes('Password');
      const hasDashboardContent = routeBodyText.includes('Dashboard') || routeBodyText.includes('Home');
      
      console.log(`  🔍 Login Elements: ${hasLoginContent ? 'YES' : 'NO'}`);
      console.log(`  🏠 Dashboard Elements: ${hasDashboardContent ? 'YES' : 'NO'}`);
      
      // Take screenshot for each route
      await page.screenshot({ 
        path: `test-results/served_app_${route.replace(/\//g, '_')}.png`, 
        fullPage: true 
      });
    }
    
  } catch (error) {
    console.error('❌ Error:', error.message);
  } finally {
    await browser.close();
  }
}

testServedApp().catch(console.error);
