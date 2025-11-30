// e2e-tests/debug_route_content.js - Debug what's in the 156-character responses
const { chromium } = require('playwright');

const BASE_URL = 'http://localhost:8084';

async function debugRouteContent() {
  console.log('🔍 DEBUGGING ROUTE CONTENT');
  console.log('==========================');
  
  const browser = await chromium.launch({ headless: false });
  const page = await browser.newPage();
  
  try {
    const routes = ['/login/customer', '/customer/home', '/staff/home', '/admin/home'];
    
    for (const route of routes) {
      console.log(`\n📍 Debugging route: ${route}`);
      
      await page.goto(`${BASE_URL}${route}`, { waitUntil: 'networkidle' });
      await page.waitForTimeout(3000);
      
      const routeBodyText = await page.textContent('body');
      const routeLength = routeBodyText.length;
      
      console.log(`  📝 Length: ${routeLength}`);
      console.log(`  📄 Full Content: "${routeBodyText}"`);
      
      // Check if it's an HTML 404 or error page
      const isHtmlError = routeBodyText.includes('<!DOCTYPE') || 
                         routeBodyText.includes('<html>') ||
                         routeBodyText.includes('404') ||
                         routeBodyText.includes('Not Found');
      
      console.log(`  🚨 HTML Error Page: ${isHtmlError ? 'YES' : 'NO'}`);
      
      // Check HTTP status
      const response = await page.evaluate(() => performance.getEntriesByType('navigation')[0]);
      console.log(`  🌐 HTTP Status: ${response.responseStatus || 'Unknown'}`);
    }
    
  } catch (error) {
    console.error('❌ Error:', error.message);
  } finally {
    await browser.close();
  }
}

debugRouteContent().catch(console.error);
