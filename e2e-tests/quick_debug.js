// e2e-tests/quick_debug.js - Quick debug of fallback UI
const { chromium } = require('playwright');

const BASE_URL = 'http://localhost:8081';

async function quickDebug() {
  console.log('🔍 Quick Debug of Fallback UI...');
  
  const browser = await chromium.launch({ headless: false });
  const context = await browser.newContext();
  const page = await context.newPage();
  
  // Capture console logs
  page.on('console', msg => {
    console.log(`📝 ${msg.type()}: ${msg.text()}`);
  });
  
  page.on('pageerror', error => {
    console.log(`🚨 Page Error: ${error.message}`);
  });
  
  try {
    await page.goto(BASE_URL);
    await page.waitForTimeout(8000); // Wait longer for fallback to load
    
    const bodyText = await page.textContent('body');
    console.log('📄 Body Text Length:', bodyText.length);
    console.log('📄 Body Text Preview:');
    console.log(bodyText.substring(0, 1000));
    
    // Check for overlay by ID
    const overlay = await page.$('#flutter-fallback-overlay');
    console.log('🎯 Overlay Found by ID:', !!overlay);
    
    // Check for any element with high z-index
    const highZIndex = await page.$('[style*="z-index: 1001"]');
    console.log('🎯 High z-index Found:', !!highZIndex);
    
    // Check for buttons
    const buttons = await page.$$('button');
    console.log('🔘 Buttons Found:', buttons.length);
    
    // Check all divs
    const divs = await page.$$('div');
    console.log('📦 Divs Found:', divs.length);
    
    // Screenshot
    await page.screenshot({ path: 'quick_debug.png', fullPage: true });
    console.log('📸 Screenshot saved: quick_debug.png');
    
  } catch (error) {
    console.error('❌ Debug failed:', error);
  } finally {
    await browser.close();
  }
}

quickDebug().catch(console.error);
