// e2e-tests/test_flutter_dev_server.js - Test with Flutter development server
const { chromium } = require('playwright');

const BASE_URL = 'http://localhost:8086';

async function testFlutterDevServer() {
  console.log('🚀 TESTING FLUTTER DEV SERVER');
  console.log('=============================');
  
  const browser = await chromium.launch({ headless: false });
  const page = await browser.newPage();
  
  try {
    console.log(`🚀 Navigating to: ${BASE_URL}`);
    await page.goto(BASE_URL, { waitUntil: 'networkidle' });
    
    // Wait for content to load
    await page.waitForTimeout(15000); // Longer wait for release mode
    
    // Take screenshot
    await page.screenshot({ path: 'test-results/flutter_dev_main.png', fullPage: true });
    
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
      await page.waitForTimeout(10000); // Wait for Flutter to handle routing
      
      const routeBodyText = await page.textContent('body');
      const routeLength = routeBodyText.length;
      
      console.log(`  📝 Length: ${routeLength}`);
      console.log(`  🦋 Flutter Loaded: ${routeBodyText.includes('flutter-view') ? 'YES' : 'NO'}`);
      console.log(`  🎯 Has Content: ${routeLength > 1000 ? 'YES' : 'NO'}`);
      
      // Check for specific content
      const hasLoginContent = routeBodyText.includes('Email') || routeBodyText.includes('Password');
      const hasDashboardContent = routeBodyText.includes('Dashboard') || routeBodyText.includes('Home');
      const hasError = routeBodyText.includes('404') || routeBodyText.includes('Error');
      const hasAuthDebug = routeBodyText.includes('AuthProvider') || routeBodyText.includes('Login');
      
      console.log(`  🔍 Login Elements: ${hasLoginContent ? 'YES' : 'NO'}`);
      console.log(`  🏠 Dashboard Elements: ${hasDashboardContent ? 'YES' : 'NO'}`);
      console.log(`  🚨 404/Error: ${hasError ? 'YES' : 'NO'}`);
      console.log(`  🔐 Auth Debug: ${hasAuthDebug ? 'YES' : 'NO'}`);
      
      // Show first 300 characters for debugging
      if (routeLength > 100) {
        console.log(`  📄 Preview: "${routeBodyText.substring(0, 300)}..."`);
      }
      
      // Take screenshot for each route
      await page.screenshot({ 
        path: `test-results/flutter_dev_${route.replace(/\//g, '_')}.png`, 
        fullPage: true 
      });
    }
    
  } catch (error) {
    console.error('❌ Error:', error.message);
  } finally {
    await browser.close();
  }
}

testFlutterDevServer().catch(console.error);
