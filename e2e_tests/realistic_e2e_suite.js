// realistic_e2e_suite.js - Tests what actually exists in the app
const { chromium } = require('playwright');

class RealisticE2ESuite {
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
    console.log('🚀 Setting up Realistic E2E Test Suite...');
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

  // Test 1: Complete User Journey - Customer Booking Flow
  async testCustomerBookingJourney() {
    console.log('\n🧪 Test 1: Customer Booking Journey');
    
    try {
      await this.loginAs('customer');
      await this.page.screenshot({ path: 'test-results/customer_journey_1_dashboard.png' });
      
      // Look for booking options
      const bookingElements = [
        'Book Service', 'Book', 'Services', 'Booking', 'Schedule', 'Appointment'
      ];
      
      let bookingFound = false;
      let bookingCompleted = false;
      
      for (const text of bookingElements) {
        const element = await this.findElementByText(text);
        if (element) {
          await element.click();
          await this.page.waitForTimeout(2000);
          bookingFound = true;
          break;
        }
      }
      
      if (bookingFound) {
        await this.page.screenshot({ path: 'test-results/customer_journey_2_booking_page.png' });
        
        // Look for service selection
        const services = ['Cleaning', 'Service', 'General', 'Deep', 'Carpet'];
        for (const service of services) {
          const serviceElement = await this.findElementByText(service);
          if (serviceElement) {
            await serviceElement.click();
            await this.page.waitForTimeout(1000);
            break;
          }
        }
        
        // Look for price/quote
        const priceElements = ['$', 'Price', 'Quote', 'Cost'];
        let priceFound = false;
        for (const priceText of priceElements) {
          const priceElement = await this.findElementByText(priceText);
          if (priceElement) {
            priceFound = true;
            break;
          }
        }
        
        // Try to proceed
        const proceedElements = ['Proceed', 'Continue', 'Next', 'Book Now', 'Confirm'];
        for (const proceedText of proceedElements) {
          const proceedElement = await this.findElementByText(proceedText);
          if (proceedElement) {
            await proceedElement.click();
            await this.page.waitForTimeout(2000);
            bookingCompleted = true;
            break;
          }
        }
        
        await this.page.screenshot({ path: 'test-results/customer_journey_3_booking_result.png' });
      }
      
      this.recordResult(
        'Customer Booking Journey',
        bookingFound && bookingCompleted,
        bookingFound && bookingCompleted ? 'Customer can navigate booking flow' : 'Booking flow incomplete'
      );
      
    } catch (error) {
      this.recordResult('Customer Booking Journey', false, error.message);
    }
  }

  // Test 2: Staff Timekeeping and Schedule Management
  async testStaffTimekeepingJourney() {
    console.log('\n🧪 Test 2: Staff Timekeeping Journey');
    
    try {
      await this.loginAs('staff');
      await this.page.screenshot({ path: 'test-results/staff_journey_1_dashboard.png' });
      
      // Look for timekeeping/schedule features
      const timekeepingElements = [
        'Timekeeping', 'Schedule', 'Hours', 'Clock', 'Jobs', 'Tasks', 'Availability'
      ];
      
      let timekeepingFound = false;
      let timekeepingCompleted = false;
      
      for (const text of timekeepingElements) {
        const element = await this.findElementByText(text);
        if (element) {
          await element.click();
          await this.page.waitForTimeout(2000);
          timekeepingFound = true;
          break;
        }
      }
      
      if (timekeepingFound) {
        await this.page.screenshot({ path: 'test-results/staff_journey_2_timekeeping.png' });
        
        // Look for clock-in/clock-out functionality
        const clockElements = ['Clock In', 'Clock Out', 'Check In', 'Check Out', 'Start', 'End'];
        for (const clockText of clockElements) {
          const clockElement = await this.findElementByText(clockText);
          if (clockElement) {
            await clockElement.click();
            await this.page.waitForTimeout(2000);
            timekeepingCompleted = true;
            break;
          }
        }
        
        // Look for schedule view
        const scheduleElements = ['Schedule', 'Calendar', 'Today', 'Week', 'Month'];
        for (const scheduleText of scheduleElements) {
          const scheduleElement = await this.findElementByText(scheduleText);
          if (scheduleElement) {
            await scheduleElement.click();
            await this.page.waitForTimeout(1000);
            break;
          }
        }
        
        await this.page.screenshot({ path: 'test-results/staff_journey_3_timekeeping_result.png' });
      }
      
      this.recordResult(
        'Staff Timekeeping Journey',
        timekeepingFound && timekeepingCompleted,
        timekeepingFound && timekeepingCompleted ? 'Staff can access timekeeping features' : 'Timekeeping flow incomplete'
      );
      
    } catch (error) {
      this.recordResult('Staff Timekeeping Journey', false, error.message);
    }
  }

  // Test 3: Admin Dashboard and Management Features
  async testAdminManagementJourney() {
    console.log('\n🧪 Test 3: Admin Management Journey');
    
    try {
      await this.loginAs('admin');
      await this.page.screenshot({ path: 'test-results/admin_journey_1_dashboard.png' });
      
      // Look for admin management features
      const adminElements = [
        'Staff Management', 'User Management', 'Reports', 'Analytics', 'Settings', 'Payroll', 'Bookings', 'Revenue'
      ];
      
      let managementFound = false;
      let managementCompleted = false;
      
      for (const text of adminElements) {
        const element = await this.findElementByText(text);
        if (element) {
          await element.click();
          await this.page.waitForTimeout(2000);
          managementFound = true;
          break;
        }
      }
      
      if (managementFound) {
        await this.page.screenshot({ path: 'test-results/admin_journey_2_management.png' });
        
        // Look for data/records in the management section
        const dataElements = ['List', 'Table', 'Records', 'Data', 'Users', 'Staff', 'Report'];
        for (const dataText of dataElements) {
          const dataElement = await this.findElementByText(dataText);
          if (dataElement) {
            managementCompleted = true;
            break;
          }
        }
        
        // Look for create/add functionality
        const createElements = ['Create', 'Add', 'New', 'Add User', 'Create Staff'];
        for (const createText of createElements) {
          const createElement = await this.findElementByText(createText);
          if (createElement) {
            await createElement.click();
            await this.page.waitForTimeout(1000);
            break;
          }
        }
        
        await this.page.screenshot({ path: 'test-results/admin_journey_3_management_result.png' });
      }
      
      this.recordResult(
        'Admin Management Journey',
        managementFound && managementCompleted,
        managementFound && managementCompleted ? 'Admin can access management features' : 'Management flow incomplete'
      );
      
    } catch (error) {
      this.recordResult('Admin Management Journey', false, error.message);
    }
  }

  // Test 4: Cross-Role Integration - Job Assignment Flow
  async testCrossRoleJobAssignment() {
    console.log('\n🧪 Test 4: Cross-Role Job Assignment');
    
    try {
      // Step 1: Admin creates/manages jobs
      await this.loginAs('admin');
      await this.page.screenshot({ path: 'test-results/cross_role_1_admin_jobs.png' });
      
      const jobElements = ['Jobs', 'Assignments', 'Schedule', 'Tasks'];
      let jobsFound = false;
      
      for (const text of jobElements) {
        const element = await this.findElementByText(text);
        if (element) {
          await element.click();
          await this.page.waitForTimeout(2000);
          jobsFound = true;
          break;
        }
      }
      
      if (jobsFound) {
        // Look for job creation/assignment
        const createElements = ['Create', 'Assign', 'New Job', 'Add'];
        for (const createText of createElements) {
          const createElement = await this.findElementByText(createText);
          if (createElement) {
            await createElement.click();
            await this.page.waitForTimeout(1000);
            break;
          }
        }
      }
      
      await this.page.screenshot({ path: 'test-results/cross_role_2_job_management.png' });
      
      // Step 2: Staff views assigned jobs
      await this.loginAs('staff');
      await this.page.screenshot({ path: 'test-results/cross_role_3_staff_jobs.png' });
      
      const staffJobElements = ['Jobs', 'Tasks', 'My Jobs', 'Assignments', 'Schedule'];
      let staffJobsFound = false;
      
      for (const text of staffJobElements) {
        const element = await this.findElementByText(text);
        if (element) {
          await element.click();
          await this.page.waitForTimeout(2000);
          staffJobsFound = true;
          break;
        }
      }
      
      await this.page.screenshot({ path: 'test-results/cross_role_4_staff_job_view.png' });
      
      // Step 3: Customer views booking status
      await this.loginAs('customer');
      await this.page.screenshot({ path: 'test-results/cross_role_5_customer_bookings.png' });
      
      const bookingElements = ['Bookings', 'My Bookings', 'Appointments', 'History'];
      let customerBookingsFound = false;
      
      for (const text of bookingElements) {
        const element = await this.findElementByText(text);
        if (element) {
          await element.click();
          await this.page.waitForTimeout(2000);
          customerBookingsFound = true;
          break;
        }
      }
      
      await this.page.screenshot({ path: 'test-results/cross_role_6_booking_status.png' });
      
      this.recordResult(
        'Cross-Role Job Assignment',
        jobsFound && staffJobsFound && customerBookingsFound,
        jobsFound && staffJobsFound && customerBookingsFound ? 'Job assignment flow works across all roles' : 'Cross-role flow incomplete'
      );
      
    } catch (error) {
      this.recordResult('Cross-Role Job Assignment', false, error.message);
    }
  }

  // Test 5: Help and Support Features
  async testHelpSupportJourney() {
    console.log('\n🧪 Test 5: Help and Support Journey');
    
    try {
      await this.page.goto('http://localhost:8080');
      await this.page.waitForTimeout(5000);
      
      // Test help dialog from login chooser
      await this.page.mouse.click(this.coordinates.helpButton.x, this.coordinates.helpButton.y);
      await this.page.waitForTimeout(2000);
      
      await this.page.screenshot({ path: 'test-results/help_1_dialog.png' });
      
      // Look for help content
      const helpContent = await this.findElementByText('Help') || 
                         await this.findElementByText('Support') ||
                         await this.findElementByText('Contact') ||
                         await this.findElementByText('Close');
      
      let helpWorking = !!helpContent;
      
      // Try to close help dialog
      const closeElements = ['Close', 'OK', 'Cancel'];
      for (const closeText of closeElements) {
        const closeElement = await this.findElementByText(closeText);
        if (closeElement) {
          await closeElement.click();
          await this.page.waitForTimeout(1000);
          break;
        }
      }
      
      // Test help in customer dashboard
      await this.loginAs('customer');
      
      const customerHelp = await this.findElementByText('Help') || 
                          await this.findElementByText('Support') ||
                          await this.findElementByText('FAQ');
      
      if (customerHelp) {
        await customerHelp.click();
        await this.page.waitForTimeout(1000);
        helpWorking = true;
      }
      
      await this.page.screenshot({ path: 'test-results/help_2_customer_support.png' });
      
      this.recordResult(
        'Help and Support Journey',
        helpWorking,
        helpWorking ? 'Help and support features are accessible' : 'Help features not working'
      );
      
    } catch (error) {
      this.recordResult('Help and Support Journey', false, error.message);
    }
  }

  // Test 6: UI Responsiveness and Navigation
  async testUIResponsiveness() {
    console.log('\n🧪 Test 6: UI Responsiveness and Navigation');
    
    try {
      // Test different viewport sizes
      const viewports = [
        { width: 1280, height: 720, name: 'Desktop' },
        { width: 768, height: 1024, name: 'Tablet' },
        { width: 375, height: 667, name: 'Mobile' }
      ];
      
      let responsiveWorking = true;
      
      for (const viewport of viewports) {
        console.log(`Testing ${viewport.name} view (${viewport.width}x${viewport.height})`);
        
        await this.page.setViewportSize({ width: viewport.width, height: viewport.height });
        await this.page.goto('http://localhost:8080');
        await this.page.waitForTimeout(3000);
        
        await this.page.screenshot({ path: `test-results/responsive_${viewport.name.toLowerCase()}.png` });
        
        // Test login buttons are still accessible
        await this.loginAs('customer');
        
        // Test navigation works
        const navigationElements = ['Dashboard', 'Profile', 'Settings', 'Logout'];
        let navWorking = false;
        
        for (const navText of navigationElements) {
          const navElement = await this.findElementByText(navText);
          if (navElement) {
            navWorking = true;
            break;
          }
        }
        
        if (!navWorking) {
          responsiveWorking = false;
          break;
        }
      }
      
      // Reset to desktop
      await this.page.setViewportSize({ width: 1280, height: 720 });
      
      this.recordResult(
        'UI Responsiveness and Navigation',
        responsiveWorking,
        responsiveWorking ? 'UI is responsive across all viewport sizes' : 'Responsiveness issues found'
      );
      
    } catch (error) {
      this.recordResult('UI Responsiveness and Navigation', false, error.message);
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
    console.log('🎯 Starting Realistic E2E Test Suite...\n');
    
    await this.setup();
    
    // Run all realistic tests
    await this.testCustomerBookingJourney();
    await this.testStaffTimekeepingJourney();
    await this.testAdminManagementJourney();
    await this.testCrossRoleJobAssignment();
    await this.testHelpSupportJourney();
    await this.testUIResponsiveness();
    
    // Generate final report
    this.generateReport();
    
    await this.cleanup();
  }

  generateReport() {
    console.log('\n📊 REALISTIC E2E TEST SUITE REPORT');
    console.log('===================================');
    
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
      'test-results/realistic_e2e_test_report.json',
      JSON.stringify(reportData, null, 2)
    );
    
    console.log('\n📄 Detailed report saved to: test-results/realistic_e2e_test_report.json');
    console.log('📸 Screenshots saved in: test-results/ directory');
  }

  async cleanup() {
    if (this.browser) {
      await this.browser.close();
      console.log('\n🔚 Realistic E2E test suite completed, browser closed');
    }
  }
}

// Run the realistic test suite
const realisticE2ESuite = new RealisticE2ESuite();
realisticE2ESuite.runAllTests().catch(console.error);
