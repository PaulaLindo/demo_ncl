// e2e-tests/debug_css_conflicts.js - Debug CSS conflicts and hidden content
const { chromium } = require('playwright');

const BASE_URL = 'http://localhost:8086';

async function debugCssConflicts() {
  console.log('🎨 DEBUGGING CSS CONFLICTS');
  console.log('==========================');
  
  const browser = await chromium.launch({ headless: false });
  const page = await browser.newPage();
  
  try {
    console.log(`🚀 Navigating to: ${BASE_URL}`);
    await page.goto(BASE_URL, { waitUntil: 'networkidle' });
    
    // Wait for Flutter to load
    await page.waitForTimeout(10000);
    
    // Check for computed styles
    console.log('\n🔍 CHECKING COMPUTED STYLES:');
    
    // Get body element styles
    const bodyStyles = await page.evaluate(() => {
      const body = document.body;
      const computed = window.getComputedStyle(body);
      return {
        display: computed.display,
        visibility: computed.visibility,
        opacity: computed.opacity,
        position: computed.position,
        overflow: computed.overflow,
        height: computed.height,
        width: computed.width,
        backgroundColor: computed.backgroundColor,
        zIndex: computed.zIndex
      };
    });
    
    console.log('📄 Body Styles:', bodyStyles);
    
    // Check flutter-view styles
    const flutterViewStyles = await page.evaluate(() => {
      const flutterView = document.querySelector('flutter-view');
      if (!flutterView) return null;
      
      const computed = window.getComputedStyle(flutterView);
      const rect = flutterView.getBoundingClientRect();
      
      return {
        display: computed.display,
        visibility: computed.visibility,
        opacity: computed.opacity,
        position: computed.position,
        overflow: computed.overflow,
        height: computed.height,
        width: computed.width,
        backgroundColor: computed.backgroundColor,
        zIndex: computed.zIndex,
        rect: {
          width: rect.width,
          height: rect.height,
          top: rect.top,
          left: rect.left
        }
      };
    });
    
    console.log('🦋 Flutter View Styles:', flutterViewStyles);
    
    // Check flt-scene-host styles
    const sceneHostStyles = await page.evaluate(() => {
      const sceneHost = document.querySelector('flt-scene-host');
      if (!sceneHost) return null;
      
      const computed = window.getComputedStyle(sceneHost);
      const rect = sceneHost.getBoundingClientRect();
      
      return {
        display: computed.display,
        visibility: computed.visibility,
        opacity: computed.opacity,
        position: computed.position,
        overflow: computed.overflow,
        height: computed.height,
        width: computed.width,
        backgroundColor: computed.backgroundColor,
        zIndex: computed.zIndex,
        rect: {
          width: rect.width,
          height: rect.height,
          top: rect.top,
          left: rect.left
        }
      };
    });
    
    console.log('🎬 Scene Host Styles:', sceneHostStyles);
    
    // Check for any child elements inside flutter-view
    const flutterChildren = await page.evaluate(() => {
      const flutterView = document.querySelector('flutter-view');
      if (!flutterView) return null;
      
      const children = Array.from(flutterView.querySelectorAll('*'));
      return children.map(child => ({
        tagName: child.tagName,
        className: child.className,
        id: child.id,
        display: window.getComputedStyle(child).display,
        visibility: window.getComputedStyle(child).visibility,
        opacity: window.getComputedStyle(child).opacity,
        textContent: child.textContent ? child.textContent.substring(0, 50) : '',
        rect: child.getBoundingClientRect()
      }));
    });
    
    console.log(`👶 Flutter Children (${flutterChildren ? flutterChildren.length : 0}):`);
    if (flutterChildren) {
      flutterChildren.forEach((child, index) => {
        console.log(`  ${index + 1}. ${child.tagName} - ${child.display} / ${child.visibility} / ${child.opacity}`);
        if (child.textContent) {
          console.log(`     Text: "${child.textContent}"`);
        }
      });
    }
    
    // Check for any canvas elements (CanvasKit renderer)
    const canvasInfo = await page.evaluate(() => {
      const canvases = Array.from(document.querySelectorAll('canvas'));
      return canvases.map(canvas => ({
        width: canvas.width,
        height: canvas.height,
        display: window.getComputedStyle(canvas).display,
        visibility: window.getComputedStyle(canvas).visibility,
        opacity: window.getComputedStyle(canvas).opacity,
        rect: canvas.getBoundingClientRect()
      }));
    });
    
    console.log(`🎨 Canvas Elements (${canvasInfo.length}):`);
    canvasInfo.forEach((canvas, index) => {
      console.log(`  ${index + 1}. ${canvas.width}x${canvas.height} - ${canvas.display} / ${canvas.visibility} / ${canvas.opacity}`);
    });
    
    // Check for any injected CSS
    const injectedCSS = await page.evaluate(() => {
      const stylesheets = Array.from(document.styleSheets);
      const injectedRules = [];
      
      stylesheets.forEach((sheet, index) => {
        try {
          if (sheet.href && sheet.href.includes('flutter')) {
            // Skip Flutter's own stylesheets
            return;
          }
          
          const rules = Array.from(sheet.cssRules || []);
          rules.forEach(rule => {
            if (rule.cssText.includes('!important') || 
                rule.cssText.includes('display: none') ||
                rule.cssText.includes('visibility: hidden') ||
                rule.cssText.includes('opacity: 0')) {
              injectedRules.push({
                sheetIndex: index,
                ruleText: rule.cssText
              });
            }
          });
        } catch (e) {
          // CORS issues, skip this stylesheet
        }
      });
      
      return injectedRules;
    });
    
    console.log(`🚨 Problematic CSS Rules (${injectedCSS.length}):`);
    injectedCSS.forEach((rule, index) => {
      console.log(`  ${index + 1}. ${rule.ruleText}`);
    });
    
    // Take a screenshot for visual reference
    await page.screenshot({ path: 'test-results/css_conflicts_debug.png', fullPage: true });
    
  } catch (error) {
    console.error('❌ Error:', error.message);
  } finally {
    await browser.close();
  }
}

debugCssConflicts().catch(console.error);
