// debug_page_fixed.js - Debug what's actually on the page
const { chromium } = require('playwright');

async function debugPage() {
  console.log('Debugging what is on the page...');
  
  const browser = await chromium.launch({ headless: false });
  const page = await browser.newPage();
  
  try {
    await page.goto('http://localhost:8080');
    await page.waitForTimeout(5000);
    
    // Take screenshot
    await page.screenshot({ path: 'test-results/debug-full-page.png' });
    console.log('Full page screenshot taken');
    
    // Get page title
    const title = await page.title();
    console.log('Page title: ' + title);
    
    // Get page URL
    const url = page.url();
    console.log('Page URL: ' + url);
    
    // Look for any text content
    const bodyText = await page.locator('body').textContent();
    console.log('Page text (first 200 chars): ' + bodyText.substring(0, 200) + '...');
    
    // Look for any clickable elements
    const clickables = page.locator('button, a, div[role="button"], [onclick]');
    const clickableCount = await clickables.count();
    console.log('Found ' + clickableCount + ' clickable elements');
    
    for (let i = 0; i < Math.min(clickableCount, 10); i++) {
      try {
        const element = clickables.nth(i);
        const tagName = await element.evaluate(el => el.tagName);
        const text = await element.textContent();
        const className = await element.getAttribute('class');
        console.log('Clickable ' + (i + 1) + ': <' + tagName + '> "' + (text ? text.substring(0, 50) : '') + '" class="' + className + '"');
      } catch (e) {
        console.log('Clickable ' + (i + 1) + ': Could not analyze');
      }
    }
    
    // Look for text containing Customer, Staff, Admin, Login
    const relevantTexts = page.locator('text=/Customer|Staff|Admin|Login|Access|Portal|Help/i');
    const textCount = await relevantTexts.count();
    console.log('Found ' + textCount + ' relevant text elements');
    
    for (let i = 0; i < Math.min(textCount, 10); i++) {
      try {
        const text = await relevantTexts.nth(i).textContent();
        console.log('Text ' + (i + 1) + ': "' + text + '"');
      } catch (e) {
        console.log('Text ' + (i + 1) + ': Could not get text');
      }
    }
    
    // Look for any input fields
    const inputs = page.locator('input, textarea, select');
    const inputCount = await inputs.count();
    console.log('Found ' + inputCount + ' input fields');
    
    for (let i = 0; i < Math.min(inputCount, 5); i++) {
      try {
        const input = inputs.nth(i);
        const type = await input.getAttribute('type');
        const placeholder = await input.getAttribute('placeholder');
        console.log('Input ' + (i + 1) + ': type="' + type + '" placeholder="' + placeholder + '"');
      } catch (e) {
        console.log('Input ' + (i + 1) + ': Could not analyze');
      }
    }
    
    // Try to click on areas that might contain buttons
    console.log('Trying to find button areas...');
    
    // Look for divs with button-like text
    const potentialButtons = page.locator('div', { hasText: 'Customer Login' });
    if (await potentialButtons.count() > 0) {
      console.log('Found div with Customer Login text');
      await potentialButtons.first().click();
      await page.waitForTimeout(2000);
      await page.screenshot({ path: 'test-results/debug-after-customer-click.png' });
      console.log('Screenshot after clicking Customer Login area');
    }
    
    console.log('Debug completed!');
    
  } catch (error) {
    console.error('Debug failed: ' + error.message);
  } finally {
    await browser.close();
    console.log('Browser closed');
  }
}

debugPage().catch(console.error);
