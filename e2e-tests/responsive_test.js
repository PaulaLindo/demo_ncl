// e2e-tests/responsive_test.js - Test responsive design
const { chromium } = require('playwright');

const BASE_URL = 'http://localhost:8081';

async function testResponsiveDesign() {
  console.log('📱 Testing Responsive Design...');
  
  const browser = await chromium.launch({ headless: false });
  const context = await browser.newContext();
  
  const viewports = [
    { name: 'Desktop', width: 1280, height: 720 },
    { name: 'Tablet', width: 768, height: 1024 },
    { name: 'Mobile', width: 375, height: 667 }
  ];
  
  const results = [];
  
  for (const viewport of viewports) {
    console.log(`\n📱 Testing ${viewport.name} (${viewport.width}x${viewport.height})`);
    
    const page = await context.newPage();
    await page.setViewportSize(viewport);
    
    try {
      await page.goto(BASE_URL);
      await page.waitForTimeout(3000);
      
      // Check if UI is visible and properly sized
      const container = await page.$('#flutter-fallback-container');
      const hasContainer = !!container;
      
      // Check button visibility
      const buttons = await page.$$('button');
      const buttonCount = buttons.length;
      
      // Check if content fits viewport
      const bodyText = await page.textContent('body');
      const hasContent = bodyText.includes('Welcome to NCL');
      
      // Screenshot
      const filename = `responsive_${viewport.name.toLowerCase()}.png`;
      await page.screenshot({ path: filename, fullPage: true });
      
      results.push({
        viewport: viewport.name,
        width: viewport.width,
        height: viewport.height,
        hasContainer,
        buttonCount,
        hasContent,
        screenshot: filename
      });
      
      console.log(`  ✅ Container: ${hasContainer}`);
      console.log(`  ✅ Buttons: ${buttonCount}`);
      console.log(`  ✅ Content: ${hasContent}`);
      console.log(`  📸 Screenshot: ${filename}`);
      
    } catch (error) {
      console.error(`  ❌ Error testing ${viewport.name}:`, error.message);
      results.push({
        viewport: viewport.name,
        error: error.message
      });
    } finally {
      await page.close();
    }
  }
  
  await browser.close();
  
  // Generate report
  console.log('\n📊 RESPONSIVE DESIGN REPORT');
  console.log('==========================');
  results.forEach(result => {
    console.log(`\n📱 ${result.viewport}:`);
    if (result.error) {
      console.log(`  ❌ Error: ${result.error}`);
    } else {
      console.log(`  ✅ Resolution: ${result.width}x${result.height}`);
      console.log(`  ✅ Container: ${result.hasContainer}`);
      console.log(`  ✅ Buttons: ${result.buttonCount}`);
      console.log(`  ✅ Content: ${result.hasContent}`);
      console.log(`  📸 Screenshot: ${result.screenshot}`);
    }
  });
  
  return results;
}

if (require.main === module) {
  testResponsiveDesign().catch(console.error);
}

module.exports = { testResponsiveDesign };
