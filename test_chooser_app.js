const { chromium } = require('playwright');

(async () => {
  const browser = await chromium.launch();
  const page = await browser.newPage();
  
  // Listen for console messages
  page.on('console', msg => {
    console.log(`CONSOLE [${msg.type()}]:`, msg.text());
  });
  
  page.on('pageerror', error => {
    console.log('PAGE ERROR:', error.message);
  });
  
  try {
    console.log('Testing chooser app on http://localhost:8096...');
    await page.goto('http://localhost:8096');
    
    // Wait for the app to load
    console.log('Waiting 5 seconds for app to initialize...');
    await page.waitForTimeout(5000);
    
    // Look for the welcome text
    const welcomeText = await page.locator('text=Welcome to NCL').first();
    const welcomeExists = await welcomeText.count();
    console.log(`Welcome text found: ${welcomeExists > 0}`);
    
    // Look for login options
    const customerLogin = await page.locator('text=Customer Login').first();
    const staffLogin = await page.locator('text=Staff Access').first();
    const adminLogin = await page.locator('text=Admin Portal').first();
    
    console.log(`Customer Login found: ${await customerLogin.count() > 0}`);
    console.log(`Staff Access found: ${await staffLogin.count() > 0}`);
    console.log(`Admin Portal found: ${await adminLogin.count() > 0}`);
    
    // Get all visible text
    const allText = await page.textContent('body');
    console.log('Page text content:');
    console.log(allText);
    
    // Take screenshot
    await page.screenshot({ path: 'chooser-app-screenshot.png', fullPage: true });
    console.log('Screenshot saved as chooser-app-screenshot.png');
    
    // Test clicking on Customer Login
    if (await customerLogin.count() > 0) {
      console.log('Clicking on Customer Login...');
      await customerLogin.click();
      await page.waitForTimeout(2000);
      
      // Look for dialog
      const dialog = await page.locator('text=Customer Login is coming soon').first();
      const dialogExists = await dialog.count();
      console.log(`Dialog appeared: ${dialogExists > 0}`);
      
      if (dialogExists > 0) {
        // Close the dialog
        await page.keyboard.press('Escape');
        await page.waitForTimeout(1000);
      }
    }
    
  } catch (error) {
    console.error('Error:', error);
  } finally {
    await browser.close();
  }
})();
