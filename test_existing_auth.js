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
    console.log('Testing existing auth screens on http://localhost:8098...');
    await page.goto('http://localhost:8098');
    
    // Wait for the app to load
    console.log('Waiting 5 seconds for app to initialize...');
    await page.waitForTimeout(5000);
    
    // Look for the welcome text from existing auth screen
    const welcomeText = await page.locator('text=Welcome to NCL').first();
    const welcomeExists = await welcomeText.count();
    console.log(`Welcome text found: ${welcomeExists > 0}`);
    
    // Look for login options from existing auth screen
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
    await page.screenshot({ path: 'existing-auth-screenshot.png', fullPage: true });
    console.log('Screenshot saved as existing-auth-screenshot.png');
    
    // Test clicking on Customer Login
    if (await customerLogin.count() > 0) {
      console.log('Clicking on Customer Login...');
      await customerLogin.click();
      await page.waitForTimeout(3000);
      
      // Look for login form elements
      const emailField = await page.locator('text=Email').first();
      const passwordField = await page.locator('text=Password').first();
      const signInButton = await page.locator('text=Sign In').first();
      
      console.log(`Email field found: ${await emailField.count() > 0}`);
      console.log(`Password field found: ${await passwordField.count() > 0}`);
      console.log(`Sign In button found: ${await signInButton.count() > 0}`);
      
      // Try to login
      if (await emailField.count() > 0 && await passwordField.count() > 0) {
        console.log('Filling in login form...');
        
        // Fill email
        await page.fill('input[type="email"], input[placeholder*="email"], input[aria-label*="email"]', 'customer@example.com');
        
        // Fill password  
        await page.fill('input[type="password"], input[placeholder*="password"], input[aria-label*="password"]', 'customer123');
        
        // Click sign in
        await signInButton.click();
        await page.waitForTimeout(3000);
        
        // Look for success or error
        const successMessage = await page.locator('text=Login Successful').first();
        const errorMessage = await page.locator('text=Invalid credentials').first();
        
        console.log(`Success message found: ${await successMessage.count() > 0}`);
        console.log(`Error message found: ${await errorMessage.count() > 0}`);
      }
    }
    
  } catch (error) {
    console.error('Error:', error);
  } finally {
    await browser.close();
  }
})();
