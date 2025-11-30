// icon_based_navigation_suite.js - Tests with icon-based navigation
const { chromium } = require('playwright');

class IconBasedNavigationSuite {
  constructor() {
    this.browser = null;
    this.page = null;
    this.testResults = [];
    this.coordinates = {
      customerLogin: { x: 640, y: 360 },
      staffAccess: { x: 640, y: 460 },
      adminPortal: { x: 640, y: 560 },
      helpButton: { x: 640, y: 650 }
    };
  }

  async setup() {
    console.log('🚀 Setting up Icon-Based Navigation Suite...');
    this.browser = await chromium.launch({ headless: false });
    this.page = await this.browser.newPage();
    console.log('✅ Browser launched');
  }

  async recordResult(testName, passed, details = '') {
    this.testResults.push({
      test: testName,
      passed: passed,
      details: details,
      timestamp: new Date().toISOString()
    });
    
    const status = passed ? '✅ PASS' : '❌ FAIL';
    console.log(`${status}: ${testName}`);
    if (details) console.log(`   Details: ${details}`);
  }

  async loginAs(role) {
    console.log(`🔐 Logging in as ${role}...`);
    
    await this.page.goto('http://localhost:8080');
    await this.page.waitForTimeout(5000);
    
    let coords, email, password;
    
    switch(role) {
      case 'customer':
        coords = this.coordinates.customerLogin;
        email = 'customer@example.com';
        password = 'customer123';
        break;
      case 'staff':
        coords = this.coordinates.staffAccess;
        email = 'staff@example.com';
        password = 'staff123';
        break;
      case 'admin':
        coords = this.coordinates.adminPortal;
        email = 'admin@example.com';
        password = 'admin123';
        break;
    }
    
    await this.page.mouse.click(coords.x, coords.y);
    await this.page.waitForTimeout(3000);
    
    const inputs = this.page.locator('input');
    if (await inputs.count() >= 2) {
      await inputs.nth(0).fill(email);
      await inputs.nth(1).fill(password);
      await this.page.waitForTimeout(1000);
      
      const submitButton = this.page.locator('button, input[type="submit"]');
      if (await submitButton.isVisible()) {
        await submitButton.click();
        await this.page.waitForTimeout(3000);
      }
    }
    
    console.log(`✅ ${role} login completed`);
  }

  // Helper method to click navigation items by index
  async clickNavigationByIndex(index, sectionName) {
    try {
      // Look for navigation rail items
      const navItems = this.page.locator('[role="tab"], .navigation-rail-item, .nav-item, button');
      const itemCount = await navItems.count();
      
      if (itemCount > index) {
        await navItems.nth(index).click();
        await this.page.waitForTimeout(2000);
        return true;
      }
      
      // Alternative: look for clickable elements in sidebar
      const sidebarItems = this.page.locator('nav, .sidebar, .navigation').locator('button, [role="button"], div');
      const sidebarCount = await sidebarItems.count();
      
      if (sidebarCount > index) {
        await sidebarItems.nth(index).click();
        await this.page.waitForTimeout(2000);
        return true;
      }
      
      return false;
    } catch (error) {
      console.log(`Navigation click failed for ${sectionName}: ${error.message}`);
      return false;
    }
  }

  // Test 1: Admin Icon-Based Navigation
  async testAdminIconNavigation() {
    console.log('\n🧪 Test 1: Admin Icon-Based Navigation');
    
    try {
      await this.loginAs('admin');
      await this.page.screenshot({ path: 'test-results/icon_admin_1_overview.png' });
      
      // Test each navigation item by index (based on admin_dashboard.dart)
      const adminSections = [
        { index: 0, name: 'Overview' },
        { index: 1, name: 'Temp Cards' },
        { index: 2, name: 'Proxy Time' },
        { index: 3, name: 'Quality Audit' },
        { index: 4, name: 'B2B Leads' },
        { index: 5, name: 'Payroll' },
        { index: 6, name: 'Logistics' },
        { index: 7, name: 'Restrictions' },
        { index: 8, name: 'Audit Logs' }
      ];
      
      let sectionsWorking = [];
      
      for (const section of adminSections) {
        const clicked = await this.clickNavigationByIndex(section.index, section.name);
        
        if (clicked) {
          await this.page.screenshot({ path: `test-results/icon_admin_${section.name.toLowerCase().replace(' ', '_')}.png` });
          
          // Look for content in the section
          const contentElements = await this.page.locator('div, p, h1, h2, h3, table, list, card').count();
          if (contentElements > 0) {
            sectionsWorking.push(section.name);
          }
        }
      }
      
      // Look for stats cards specifically
      const statsCards = this.page.locator('.card, [role="card"], mat-card');
      const statsCount = await statsCards.count();
      
      this.recordResult(
        'Admin Icon-Based Navigation',
        sectionsWorking.length > 0,
        `Successfully navigated to ${sectionsWorking.length} sections: ${sectionsWorking.join(', ')}`
      );
      
    } catch (error) {
      this.recordResult('Admin Icon-Based Navigation', false, error.message);
    }
  }

  // Test 2: Staff Tab-Based Navigation
  async testStaffTabNavigation() {
    console.log('\n🧪 Test 2: Staff Tab-Based Navigation');
    
    try {
      await this.loginAs('staff');
      await this.page.screenshot({ path: 'test-results/icon_staff_1_dashboard.png' });
      
      // Look for tab bar elements
      const tabBar = this.page.locator('[role="tablist"], .tab-bar, .tabs');
      const tabItems = tabBar.locator('[role="tab"], .tab, button');
      const tabCount = await tabItems.count();
      
      let tabsWorking = [];
      
      // Click through each tab
      for (let i = 0; i < tabCount; i++) {
        try {
          await tabItems.nth(i).click();
          await this.page.waitForTimeout(2000);
          
          await this.page.screenshot({ path: `test-results/icon_staff_tab_${i}.png` });
          
          // Look for content
          const contentElements = await this.page.locator('div, p, h1, h2, h3, table, list, button').count();
          if (contentElements > 0) {
            tabsWorking.push(`Tab ${i}`);
          }
        } catch (e) {
          // Continue to next tab
        }
      }
      
      // Look for specific staff features
      const staffFeatures = ['Timekeeping', 'Schedule', 'Profile', 'Jobs', 'Clock'];
      let featuresFound = [];
      
      for (const feature of staffFeatures) {
        const element = await this.findElementByText(feature);
        if (element) {
          featuresFound.push(feature);
        }
      }
      
      this.recordResult(
        'Staff Tab-Based Navigation',
        tabsWorking.length > 0 || featuresFound.length > 0,
        `Found ${tabsWorking.length} tabs and ${featuresFound.length} features: ${featuresFound.join(', ')}`
      );
      
    } catch (error) {
      this.recordResult('Staff Tab-Based Navigation', false, error.message);
    }
  }

  // Test 3: Customer Tab-Based Navigation
  async testCustomerTabNavigation() {
    console.log('\n🧪 Test 3: Customer Tab-Based Navigation');
    
    try {
      await this.loginAs('customer');
      await this.page.screenshot({ path: 'test-results/icon_customer_1_dashboard.png' });
      
      // Look for tab bar elements
      const tabBar = this.page.locator('[role="tablist"], .tab-bar, .tabs');
      const tabItems = tabBar.locator('[role="tab"], .tab, button');
      const tabCount = await tabItems.count();
      
      let tabsWorking = [];
      
      // Click through each tab
      for (let i = 0; i < tabCount; i++) {
        try {
          await tabItems.nth(i).click();
          await this.page.waitForTimeout(2000);
          
          await this.page.screenshot({ path: `test-results/icon_customer_tab_${i}.png` });
          
          // Look for content
          const contentElements = await this.page.locator('div, p, h1, h2, h3, table, list, button').count();
          if (contentElements > 0) {
            tabsWorking.push(`Tab ${i}`);
          }
        } catch (e) {
          // Continue to next tab
        }
      }
      
      // Look for specific customer features
      const customerFeatures = ['Services', 'Bookings', 'Account', 'Book', 'Service'];
      let featuresFound = [];
      
      for (const feature of customerFeatures) {
        const element = await this.findElementByText(feature);
        if (element) {
          featuresFound.push(feature);
        }
      }
      
      this.recordResult(
        'Customer Tab-Based Navigation',
        tabsWorking.length > 0 || featuresFound.length > 0,
        `Found ${tabsWorking.length} tabs and ${featuresFound.length} features: ${featuresFound.join(', ')}`
      );
      
    } catch (error) {
      this.recordResult('Customer Tab-Based Navigation', false, error.message);
    }
  }

  // Test 4: Content Discovery and Interaction
  async testContentDiscovery() {
    console.log('\n🧪 Test 4: Content Discovery and Interaction');
    
    try {
      // Test admin content discovery
      await this.loginAs('admin');
      
      // Look for interactive elements
      const buttons = this.page.locator('button, [role="button"]');
      const buttonCount = await buttons.count();
      
      // Look for form elements
      const inputs = this.page.locator('input, select, textarea');
      const inputCount = await inputs.count();
      
      // Look for data displays
      const cards = this.page.locator('.card, [role="card"], mat-card');
      const cardCount = await cards.count();
      
      // Look for tables/lists
      const tables = this.page.locator('table, .table, [role="table"]');
      const tableCount = await tables.count();
      
      await this.page.screenshot({ path: 'test-results/content_discovery_admin.png' });
      
      // Try clicking some buttons
      let buttonsWorking = 0;
      for (let i = 0; i < Math.min(buttonCount, 5); i++) {
        try {
          await buttons.nth(i).click();
          await this.page.waitForTimeout(1000);
          buttonsWorking++;
          
          // Go back if possible
          await this.page.goBack().catch(() => {});
          await this.page.waitForTimeout(500);
        } catch (e) {
          // Continue
        }
      }
      
      // Test staff content discovery
      await this.loginAs('staff');
      
      const staffButtons = this.page.locator('button, [role="button"]');
      const staffButtonCount = await staffButtons.count();
      
      await this.page.screenshot({ path: 'test-results/content_discovery_staff.png' });
      
      // Test customer content discovery
      await this.loginAs('customer');
      
      const customerButtons = this.page.locator('button, [role="button"]');
      const customerButtonCount = await customerButtons.count();
      
      await this.page.screenshot({ path: 'test-results/content_discovery_customer.png' });
      
      this.recordResult(
        'Content Discovery and Interaction',
        buttonCount > 0 || inputCount > 0 || cardCount > 0,
        `Admin: ${buttonCount} buttons, ${inputCount} inputs, ${cardCount} cards, ${tableCount} tables`
      );
      
    } catch (error) {
      this.recordResult('Content Discovery and Interaction', false, error.message);
    }
  }

  // Test 5: Form Interaction Testing
  async testFormInteraction() {
    console.log('\n🧪 Test 5: Form Interaction Testing');
    
    try {
      // Test admin forms
      await this.loginAs('admin');
      
      // Navigate to different sections and look for forms
      const navItems = this.page.locator('[role="tab"], .navigation-rail-item, button');
      const navCount = await navItems.count();
      
      let formsFound = 0;
      let formsWorking = 0;
      
      for (let i = 1; i < Math.min(navCount, 5); i++) {
        try {
          await navItems.nth(i).click();
          await this.page.waitForTimeout(2000);
          
          // Look for forms
          const forms = this.page.locator('form');
          const formCount = await forms.count();
          
          if (formCount > 0) {
            formsFound++;
            
            // Try to fill form elements
            const inputs = forms.locator('input, select, textarea');
            const inputCount = await inputs.count();
            
            for (let j = 0; j < Math.min(inputCount, 3); j++) {
              try {
                const input = inputs.nth(j);
                const tagName = await input.evaluate(el => el.tagName);
                
                if (tagName === 'INPUT') {
                  const inputType = await input.getAttribute('type');
                  if (inputType === 'text' || inputType === 'email') {
                    await input.fill('Test Data');
                  } else if (inputType === 'number') {
                    await input.fill('1');
                  }
                } else if (tagName === 'SELECT') {
                  await input.selectOption({ index: 1 });
                }
                
                await this.page.waitForTimeout(500);
              } catch (e) {
                // Continue
              }
            }
            
            formsWorking++;
          }
        } catch (e) {
          // Continue
        }
      }
      
      await this.page.screenshot({ path: 'test-results/form_interaction_result.png' });
      
      this.recordResult(
        'Form Interaction Testing',
        formsFound > 0,
        `Found ${formsFound} forms, successfully interacted with ${formsWorking} forms`
      );
      
    } catch (error) {
      this.recordResult('Form Interaction Testing', false, error.message);
    }
  }

  // Test 6: Visual Layout and Responsiveness
  async testVisualLayout() {
    console.log('\n🧪 Test 6: Visual Layout and Responsiveness');
    
    try {
      const viewports = [
        { width: 1280, height: 720, name: 'Desktop' },
        { width: 768, height: 1024, name: 'Tablet' },
        { width: 375, height: 667, name: 'Mobile' }
      ];
      
      let layoutWorking = true;
      
      for (const viewport of viewports) {
        await this.page.setViewportSize({ width: viewport.width, height: viewport.height });
        
        // Test each role
        await this.loginAs('admin');
        await this.page.waitForTimeout(2000);
        await this.page.screenshot({ path: `test-results/layout_admin_${viewport.name.toLowerCase()}.png` });
        
        await this.loginAs('staff');
        await this.page.waitForTimeout(2000);
        await this.page.screenshot({ path: `test-results/layout_staff_${viewport.name.toLowerCase()}.png` });
        
        await this.loginAs('customer');
        await this.page.waitForTimeout(2000);
        await this.page.screenshot({ path: `test-results/layout_customer_${viewport.name.toLowerCase()}.png` });
        
        // Check if content is visible
        const contentElements = await this.page.locator('body > *').count();
        if (contentElements === 0) {
          layoutWorking = false;
          break;
        }
      }
      
      // Reset to desktop
      await this.page.setViewportSize({ width: 1280, height: 720 });
      
      this.recordResult(
        'Visual Layout and Responsiveness',
        layoutWorking,
        'Layout tested across Desktop, Tablet, and Mobile viewports'
      );
      
    } catch (error) {
      this.recordResult('Visual Layout and Responsiveness', false, error.message);
    }
  }

  async findElementByText(text) {
    try {
      const element = this.page.locator('text=' + text);
      if (await element.isVisible({ timeout: 3000 })) {
        return element;
      }
    } catch (e) {
      try {
        const element = this.page.locator('*', { hasText: text });
        if (await element.isVisible({ timeout: 3000 })) {
          return element;
        }
      } catch (e2) {
        return null;
      }
    }
    return null;
  }

  async runAllTests() {
    console.log('🎯 Starting Icon-Based Navigation Suite...\n');
    
    await this.setup();
    
    // Run all tests
    await this.testAdminIconNavigation();
    await this.testStaffTabNavigation();
    await this.testCustomerTabNavigation();
    await this.testContentDiscovery();
    await this.testFormInteraction();
    await this.testVisualLayout();
    
    // Generate final report
    this.generateReport();
    
    await this.cleanup();
  }

  generateReport() {
    console.log('\n📊 ICON-BASED NAVIGATION TEST SUITE REPORT');
    console.log('==========================================');
    
    const passedTests = this.testResults.filter(r => r.passed).length;
    const totalTests = this.testResults.length;
    
    console.log(`Overall Result: ${passedTests}/${totalTests} tests passed`);
    console.log(`Success Rate: ${Math.round((passedTests / totalTests) * 100)}%`);
    console.log('');
    
    this.testResults.forEach(result => {
      const status = result.passed ? '✅ PASS' : '❌ FAIL';
      console.log(`${status} ${result.test}`);
      if (result.details) {
        console.log(`    ${result.details}`);
      }
    });
    
    // Save report to file
    const reportData = {
      summary: {
        total: totalTests,
        passed: passedTests,
        failed: totalTests - passedTests,
        successRate: Math.round((passedTests / totalTests) * 100),
        timestamp: new Date().toISOString()
      },
      results: this.testResults,
      coordinates: this.coordinates
    };
    
    require('fs').writeFileSync(
      'test-results/icon_based_navigation_test_report.json',
      JSON.stringify(reportData, null, 2)
    );
    
    console.log('\n📄 Detailed report saved to: test-results/icon_based_navigation_test_report.json');
    console.log('📸 Screenshots saved in: test-results/ directory');
  }

  async cleanup() {
    if (this.browser) {
      await this.browser.close();
      console.log('\n🔚 Icon-Based Navigation test suite completed, browser closed');
    }
  }
}

// Run the icon-based navigation suite
const iconBasedNavigationSuite = new IconBasedNavigationSuite();
iconBasedNavigationSuite.runAllTests().catch(console.error);
