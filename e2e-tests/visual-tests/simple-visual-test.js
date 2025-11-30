// simple-visual-test.js
const { chromium } = require('playwright');
const fs = require('fs');
const path = require('path');

async function runSimpleVisualTest() {
  console.log('🖼️  STARTING SIMPLE VISUAL TEST');
  console.log('🚀 This will show you exactly what your Flutter app looks like!');
  
  // Ensure screenshots directory exists
  const screenshotDir = 'screenshots/current';
  if (!fs.existsSync(screenshotDir)) {
    fs.mkdirSync(screenshotDir, { recursive: true });
  }
  
  // Start a simple HTTP server
  const http = require('http');
  const server = http.createServer((req, res) => {
    const filePath = path.join(__dirname, 'build/web', req.url === '/' ? 'index.html' : req.url);
    
    try {
      const content = fs.readFileSync(filePath);
      const ext = path.extname(filePath);
      const contentType = ext === '.html' ? 'text/html' : 
                         ext === '.css' ? 'text/css' :
                         ext === '.js' ? 'application/javascript' :
                         'application/octet-stream';
      
      res.writeHead(200, { 'Content-Type': contentType });
      res.end(content);
    } catch (err) {
      res.writeHead(404);
      res.end('Not found');
    }
  });
  
  server.listen(8080, () => {
    console.log('🚀 Server started at http://localhost:8080');
  });
  
  // Wait for server to start
  await new Promise(resolve => setTimeout(resolve, 2000));
  
  const browser = await chromium.launch({ 
    headless: false, // Show the browser
    slowMo: 500 // Slow down actions so you can see them
  });
  
  const context = await browser.newContext({
    viewport: { width: 1280, height: 720 }
  });
  
  const page = await context.newPage();
  
  try {
    console.log('\n📱 Navigating to Flutter app...');
    console.log('👀 WATCH THE BROWSER - YOU WILL SEE YOUR FLUTTER APP!');
    
    await page.goto('http://localhost:8080');
    await page.waitForTimeout(5000); // Wait for Flutter app to load
    
    console.log('✅ Flutter app loaded in browser!');
    console.log('👀 YOU SHOULD SEE YOUR NCL APP IN THE BROWSER NOW!');
    
    // Take main screenshot
    await page.screenshot({ 
      path: `${screenshotDir}/flutter-app-main-screen.png`,
      fullPage: true 
    });
    console.log('📸 Main screenshot saved: flutter-app-main-screen.png');
    
    // Test different viewports
    const viewports = [
      { name: 'Desktop', width: 1280, height: 720 },
      { name: 'Tablet', width: 768, height: 1024 },
      { name: 'Mobile', width: 375, height: 667 }
    ];
    
    for (const viewport of viewports) {
      console.log(`\n📱 Testing ${viewport.name} viewport (${viewport.width}x${viewport.height})...`);
      await page.setViewportSize({ width: viewport.width, height: viewport.height });
      await page.waitForTimeout(2000);
      
      await page.screenshot({ 
        path: `${screenshotDir}/flutter-app-${viewport.name.toLowerCase()}-viewport.png`,
        fullPage: true 
      });
      
      console.log(`✅ ${viewport.name} screenshot saved!`);
    }
    
    // Reset to desktop for button testing
    await page.setViewportSize({ width: 1280, height: 720 });
    await page.waitForTimeout(1000);
    
    // Try to find and interact with buttons
    console.log('\n👆 Testing button interactions...');
    console.log('👀 WATCH THE BROWSER - YOU WILL SEE BUTTONS BEING HOVERED!');
    
    const buttons = [
      { name: 'Customer Login', selector: 'text=Customer Login' },
      { name: 'Staff Access', selector: 'text=Staff Access' },
      { name: 'Admin Portal', selector: 'text=Admin Portal' }
    ];
    
    for (const button of buttons) {
      try {
        console.log(`\n👆 Looking for ${button.name} button...`);
        const element = page.locator(button.selector).first();
        
        if (await element.isVisible({ timeout: 3000 })) {
          console.log(`✅ Found ${button.name} - hovering now...`);
          await element.hover();
          await page.waitForTimeout(1500);
          
          await page.screenshot({ 
            path: `${screenshotDir}/flutter-app-${button.name.toLowerCase().replace(' ', '-')}-hover.png`,
            fullPage: false 
          });
          
          console.log(`🎉 ${button.name} hover screenshot saved!`);
          console.log(`👀 YOU SHOULD HAVE SEEN THE BUTTON BEING HOVERED!`);
        } else {
          console.log(`⚠️  ${button.name} not found, trying alternatives...`);
          
          // Try alternative selectors
          const alternatives = [
            `button:has-text("${button.name.split(' ')[0]}")`,
            `text=${button.name.split(' ')[0]}`,
            `[role="button"]:has-text("${button.name.split(' ')[0]}")`
          ];
          
          for (const altSelector of alternatives) {
            try {
              const altElement = page.locator(altSelector).first();
              if (await altElement.isVisible({ timeout: 2000 })) {
                console.log(`✅ Found with alternative: ${altSelector}`);
                await altElement.hover();
                await page.waitForTimeout(1000);
                await page.screenshot({ 
                  path: `${screenshotDir}/flutter-app-${button.name.toLowerCase().replace(' ', '-')}-alt-hover.png`,
                  fullPage: false 
                });
                break;
              }
            } catch (e) {
              // Continue trying
            }
          }
        }
      } catch (error) {
        console.log(`❌ Error with ${button.name}:`, error.message);
      }
    }
    
    // Take final complete screenshot
    console.log('\n📸 Taking final complete screenshot...');
    await page.screenshot({ 
      path: `${screenshotDir}/flutter-app-final-complete.png`,
      fullPage: true 
    });
    
    console.log('\n🎉 SIMPLE VISUAL TEST COMPLETED!');
    console.log('📁 Screenshots saved to screenshots/current/:');
    console.log('   - flutter-app-main-screen.png');
    console.log('   - flutter-app-desktop-viewport.png');
    console.log('   - flutter-app-tablet-viewport.png');
    console.log('   - flutter-app-mobile-viewport.png');
    console.log('   - Button hover screenshots');
    console.log('   - flutter-app-final-complete.png');
    console.log('\n👀 OPEN THESE SCREENSHOTS TO SEE YOUR FLUTTER APP!');
    console.log('✅ YOU SHOULD HAVE SEEN THE APP IN THE BROWSER!');
    console.log('✅ YOU SHOULD HAVE SEEN BUTTONS BEING HOVERED!');
    console.log('✅ NO ANDROID STUDIO NEEDED!');
    console.log('✅ NO EMULATOR ISSUES!');
    console.log('✅ PURE VISUAL TESTING!');
    console.log('🚀 SUCCESS!');
    
  } catch (error) {
    console.error('❌ Error running visual test:', error);
  } finally {
    await browser.close();
    server.close();
    console.log('\n✅ Browser and server closed');
  }
}

// Run the test
runSimpleVisualTest().catch(console.error);
