// e2e-tests/test_routing_server.js - Test with proper routing support
const { chromium } = require('playwright');

const BASE_URL = 'http://localhost:8085';

async function testRoutingServer() {
  console.log('🛣️ TESTING WITH ROUTING SUPPORT');
  console.log('===============================');
  
  const browser = await chromium.launch({ headless: false });
  const page = await browser.newPage();
  
  try {
    console.log(`🚀 Navigating to: ${BASE_URL}`);
    await page.goto(BASE_URL, { waitUntil: 'networkidle' });
    
    // Wait for content to load
    await page.waitForTimeout(10000);
    
    // Take screenshot
    await page.screenshot({ path: 'test-results/routing_server_main.png', fullPage: true });
    
    // Check content
    const bodyText = await page.textContent('body');
    const bodyTextLength = bodyText.length;
    
    console.log(`📝 Main Page Length: ${bodyTextLength}`);
    console.log(`🦋 Flutter Loaded: ${bodyText.includes('flutter-view') ? 'YES' : 'NO'}`);
    console.log(`🎯 Has Actual Content: ${bodyText.length > 2000 ? 'YES' : 'NO'}`);
    
    // Test specific routes
    const routes = ['/login/customer', '/customer/home', '/staff/home', '/admin/home'];
    
    for (const route of routes) {
      console.log(`\n📍 Testing route: ${route}`);
      await page.goto(`${BASE_URL}${route}`, { waitUntil: 'networkidle' });
      await page.waitForTimeout(8000); // Longer wait for Flutter to initialize
      
      const routeBodyText = await page.textContent('body');
      const routeLength = routeBodyText.length;
      
      console.log(`  📝 Length: ${routeLength}`);
      console.log(`  🦋 Flutter Loaded: ${routeBodyText.includes('flutter-view') ? 'YES' : 'NO'}`);
      console.log(`  🎯 Has Content: ${routeLength > 1000 ? 'YES' : 'NO'}`);
      
      // Check for specific content
      const hasLoginContent = routeBodyText.includes('Email') || routeBodyText.includes('Password');
      const hasDashboardContent = routeBodyText.includes('Dashboard') || routeBodyText.includes('Home');
      const hasError = routeBodyText.includes('404') || routeBodyText.includes('Error');
      
      console.log(`  🔍 Login Elements: ${hasLoginContent ? 'YES' : 'NO'}`);
      console.log(`  🏠 Dashboard Elements: ${hasDashboardContent ? 'YES' : 'NO'}`);
      console.log(`  🚨 404/Error: ${hasError ? 'YES' : 'NO'}`);
      
      // Show first 300 characters for debugging
      if (routeLength > 100) {
        console.log(`  📄 Preview: "${routeBodyText.substring(0, 300)}..."`);
      }
      
      // Take screenshot for each route
      await page.screenshot({ 
        path: `test-results/routing_server_${route.replace(/\//g, '_')}.png`, 
        fullPage: true 
      });
    }
    
  } catch (error) {
    console.error('❌ Error:', error.message);
  } finally {
    await browser.close();
  }
}

testRoutingServer().catch(console.error);
