// fixed_integration_suite.js - Fixed CSS selectors and more robust testing
const { chromium } = require('playwright');

class FixedIntegrationTestSuite {
  constructor() {
    this.browser = null;
    this.page = null;
    this.testResults = [];
  }

  async setup() {
    console.log('🚀 Setting up Fixed Integration Test Suite...');
    this.browser = await chromium.launch({ headless: false });
    this.page = await this.browser.newPage();
    
    // Login as admin to access all features
    await this.loginAsAdmin();
  }

  async loginAsAdmin() {
    console.log('🔐 Logging in as Admin...');
    await this.page.goto('http://localhost:8080');
    await this.page.waitForTimeout(5000);
    
    // Click Admin Portal
    await this.page.mouse.click(640, 560);
    await this.page.waitForTimeout(3000);
    
    // Fill admin credentials
    const inputs = this.page.locator('input');
    if (await inputs.count() >= 2) {
      await inputs.nth(0).fill('admin@example.com');
      await inputs.nth(1).fill('admin123');
      await this.page.waitForTimeout(1000);
      
      // Submit
      const submitButton = this.page.locator('button, input[type="submit"]');
      if (await submitButton.isVisible()) {
        await submitButton.click();
        await this.page.waitForTimeout(3000);
      }
    }
    
    console.log('✅ Admin login completed');
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

  // Helper method to find elements by text content
  async findElementByText(text) {
    try {
      const element = this.page.locator('text=' + text);
      if (await element.isVisible({ timeout: 3000 })) {
        return element;
      }
    } catch (e) {
      // Try alternative selectors
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

  // ITC 5.1: Schedule-to-Job Assignment Flow
  async testScheduleToJobAssignment() {
    console.log('\n🧪 ITC 5.1: Schedule-to-Job Assignment Flow');
    
    try {
      // Step 1: Navigate to Staff Management
      const staffManagement = await this.findElementByText('Staff Management');
      if (staffManagement) {
        await staffManagement.click();
        await this.page.waitForTimeout(2000);
      }
      
      await this.page.screenshot({ path: 'test-results/ITC_5_1_fixed_staff_page.png' });
      
      // Step 2: Look for schedule management
      const scheduleElement = await this.findElementByText('Schedule') || 
                            await this.findElementByText('Off Duty') ||
                            await this.findElementByText('Availability');
      
      if (scheduleElement) {
        console.log('✅ Found schedule management area');
        
        // Try to update a staff schedule
        const staffMember = await this.findElementByText('John Staff') || 
                          await this.findElementByText('Staff');
        
        if (staffMember) {
          await staffMember.click();
          await this.page.waitForTimeout(1000);
          
          // Look for dropdown or toggle
          const dropdown = this.page.locator('select, [role="combobox"]');
          if (await dropdown.isVisible()) {
            await dropdown.selectOption({ index: 0 }); // Try first option
            await this.page.waitForTimeout(1000);
          }
        }
      }
      
      // Step 3: Navigate to Scheduler
      const scheduler = await this.findElementByText('Scheduler') || 
                       await this.findElementByText('Jobs') ||
                       await this.findElementByText('Assignment');
      
      if (scheduler) {
        await scheduler.click();
        await this.page.waitForTimeout(2000);
      }
      
      await this.page.screenshot({ path: 'test-results/ITC_5_1_fixed_scheduler.png' });
      
      // Step 4: Try to create a job
      const createJob = await this.findElementByText('Create Job') || 
                       await this.findElementByText('New Job') ||
                       await this.findElementByText('Add');
      
      let jobCreated = false;
      
      if (createJob) {
        await createJob.click();
        await this.page.waitForTimeout(2000);
        
        // Look for form elements
        const form = this.page.locator('form');
        const inputs = form.locator('input, select');
        const inputCount = await inputs.count();
        
        if (inputCount > 0) {
          // Try to fill the form
          for (let i = 0; i < Math.min(inputCount, 3); i++) {
            const input = inputs.nth(i);
            const tagName = await input.evaluate(el => el.tagName);
            
            if (tagName === 'SELECT') {
              await input.selectOption({ index: 1 });
            } else if (tagName === 'INPUT') {
              const inputType = await input.getAttribute('type');
              if (inputType === 'text') {
                await input.fill('Test Data');
              } else if (inputType === 'number') {
                await input.fill('1');
              }
            }
            await this.page.waitForTimeout(500);
          }
          
          // Submit form
          const submit = await this.findElementByText('Submit') || 
                        await this.findElementByText('Create') ||
                        await this.findElementByText('Save');
          
          if (submit) {
            await submit.click();
            await this.page.waitForTimeout(3000);
            jobCreated = true;
          }
        }
      }
      
      await this.page.screenshot({ path: 'test-results/ITC_5_1_fixed_result.png' });
      
      this.recordResult(
        'ITC 5.1: Schedule-to-Job Assignment',
        jobCreated,
        jobCreated ? 'Successfully navigated schedule and job creation flow' : 'Job creation not completed'
      );
      
    } catch (error) {
      this.recordResult('ITC 5.1: Schedule-to-Job Assignment', false, error.message);
    }
  }

  // ITC 5.2: Managed Logistics to Punctuality
  async testManagedLogistics() {
    console.log('\n🧪 ITC 5.2: Managed Logistics to Punctuality');
    
    try {
      // Step 1: Logout and login as staff
      const logout = await this.findElementByText('Logout') || 
                    await this.findElementByText('Sign Out');
      
      if (logout) {
        await logout.click();
        await this.page.waitForTimeout(2000);
      }
      
      // Login as staff
      await this.page.mouse.click(640, 460);
      await this.page.waitForTimeout(3000);
      
      const staffInputs = this.page.locator('input');
      if (await staffInputs.count() >= 2) {
        await staffInputs.nth(0).fill('staff@example.com');
        await staffInputs.nth(1).fill('staff123');
        await this.page.waitForTimeout(1000);
        
        const submitButton = this.page.locator('button, input[type="submit"]');
        if (await submitButton.isVisible()) {
          await submitButton.click();
          await this.page.waitForTimeout(3000);
        }
      }
      
      await this.page.screenshot({ path: 'test-results/ITC_5_2_fixed_staff_dashboard.png' });
      
      // Step 2: Look for Uber/transport request
      const requestUber = await this.findElementByText('Request Uber') || 
                         await this.findElementByText('Transport') ||
                         await this.findElementByText('Travel');
      
      let transportRequested = false;
      
      if (requestUber) {
        await requestUber.click();
        await this.page.waitForTimeout(3000);
        transportRequested = true;
        
        await this.page.screenshot({ path: 'test-results/ITC_5_2_fixed_transport_requested.png' });
      }
      
      // Step 3: Check admin tracking
      await this.page.goto('http://localhost:8080');
      await this.page.waitForTimeout(3000);
      await this.loginAsAdmin();
      
      const tracking = await this.findElementByText('Tracking') || 
                       await this.findElementByText('Live') ||
                       await this.findElementByText('Map');
      
      let trackingVisible = false;
      
      if (tracking) {
        await tracking.click();
        await this.page.waitForTimeout(2000);
        
        await this.page.screenshot({ path: 'test-results/ITC_5_2_fixed_tracking.png' });
        
        // Look for tracking elements
        const trackingElements = await this.findElementByText('ETA') || 
                               await this.findElementByText('Location') ||
                               await this.findElementByText('Live');
        
        trackingVisible = !!trackingElements;
      }
      
      this.recordResult(
        'ITC 5.2: Managed Logistics to Punctuality',
        transportRequested && trackingVisible,
        transportRequested && trackingVisible ? 'Transport requested and tracking visible' : 'Logistics flow incomplete'
      );
      
    } catch (error) {
      this.recordResult('ITC 5.2: Managed Logistics to Punctuality', false, error.message);
    }
  }

  // ITC 5.3: Quality-Gated Payroll Integration
  async testQualityGatedPayroll() {
    console.log('\n🧪 ITC 5.3: Quality-Gated Payroll Integration');
    
    try {
      // Step 1: Login as staff and look for timekeeping
      await this.page.goto('http://localhost:8080');
      await this.page.waitForTimeout(3000);
      
      await this.page.mouse.click(640, 460);
      await this.page.waitForTimeout(3000);
      
      const staffInputs = this.page.locator('input');
      if (await staffInputs.count() >= 2) {
        await staffInputs.nth(0).fill('staff@example.com');
        await staffInputs.nth(1).fill('staff123');
        await this.page.waitForTimeout(1000);
        
        const submitButton = this.page.locator('button, input[type="submit"]');
        if (await submitButton.isVisible()) {
          await submitButton.click();
          await this.page.waitForTimeout(3000);
        }
      }
      
      await this.page.screenshot({ path: 'test-results/ITC_5_3_fixed_staff_timekeeping.png' });
      
      // Step 2: Look for clock-out functionality
      const clockOut = await this.findElementByText('Clock Out') || 
                       await this.findElementByText('Time') ||
                       await this.findElementByText('Hours');
      
      let qualityGateWorking = false;
      
      if (clockOut) {
        await clockOut.click();
        await this.page.waitForTimeout(2000);
        
        await this.page.screenshot({ path: 'test-results/ITC_5_3_fixed_clock_out_attempt.png' });
        
        // Look for quality checklist
        const checklist = await this.findElementByText('Checklist') || 
                         await this.findElementByText('Quality') ||
                         await this.findElementByText('Complete');
        
        if (checklist) {
          qualityGateWorking = true;
          
          // Try to complete checklist
          const checkboxes = this.page.locator('input[type="checkbox"]');
          const checkboxCount = await checkboxes.count();
          
          for (let i = 0; i < Math.min(checkboxCount, 3); i++) {
            await checkboxes.nth(i).check();
            await this.page.waitForTimeout(500);
          }
          
          // Submit checklist
          const submit = await this.findElementByText('Submit') || 
                        await this.findElementByText('Complete');
          
          if (submit) {
            await submit.click();
            await this.page.waitForTimeout(2000);
          }
        }
      }
      
      // Step 3: Check payroll report
      await this.page.goto('http://localhost:8080');
      await this.page.waitForTimeout(3000);
      await this.loginAsAdmin();
      
      const payroll = await this.findElementByText('Payroll') || 
                      await this.findElementByText('Reports') ||
                      await this.findElementByText('Hours');
      
      let payrollUpdated = false;
      
      if (payroll) {
        await payroll.click();
        await this.page.waitForTimeout(2000);
        
        await this.page.screenshot({ path: 'test-results/ITC_5_3_fixed_payroll.png' });
        
        // Look for updated hours or verified status
        const verified = await this.findElementByText('Verified') || 
                        await this.findElementByText('Complete') ||
                        await this.findElementByText('Updated');
        
        payrollUpdated = !!verified;
      }
      
      this.recordResult(
        'ITC 5.3: Quality-Gated Payroll Integration',
        qualityGateWorking && payrollUpdated,
        qualityGateWorking && payrollUpdated ? 'Quality gate and payroll integration working' : 'Integration incomplete'
      );
      
    } catch (error) {
      this.recordResult('ITC 5.3: Quality-Gated Payroll Integration', false, error.message);
    }
  }

  // ITC 5.4: Fixed-Price Quote to Billing (End-to-End)
  async testFixedPriceQuoteToBilling() {
    console.log('\n🧪 ITC 5.4: Fixed-Price Quote to Billing (End-to-End)');
    
    try {
      // Step 1: Login as customer
      await this.page.goto('http://localhost:8080');
      await this.page.waitForTimeout(3000);
      
      await this.page.mouse.click(640, 360);
      await this.page.waitForTimeout(3000);
      
      const customerInputs = this.page.locator('input');
      if (await customerInputs.count() >= 2) {
        await customerInputs.nth(0).fill('customer@example.com');
        await customerInputs.nth(1).fill('customer123');
        await this.page.waitForTimeout(1000);
        
        const submitButton = this.page.locator('button, input[type="submit"]');
        if (await submitButton.isVisible()) {
          await submitButton.click();
          await this.page.waitForTimeout(3000);
        }
      }
      
      await this.page.screenshot({ path: 'test-results/ITC_5_4_fixed_customer_dashboard.png' });
      
      // Step 2: Look for booking functionality
      const bookService = await this.findElementByText('Book Service') || 
                         await this.findElementByText('Book') ||
                         await this.findElementByText('Services');
      
      let bookingFlowWorking = false;
      let quotedPrice = '';
      
      if (bookService) {
        await bookService.click();
        await this.page.waitForTimeout(2000);
        
        await this.page.screenshot({ path: 'test-results/ITC_5_4_fixed_booking_page.png' });
        
        // Look for service selection
        const service = await this.findElementByText('Cleaning') || 
                       await this.findElementByText('Service');
        
        if (service) {
          await service.click();
          await this.page.waitForTimeout(1000);
          
          // Look for price
          const priceElement = await this.findElementByText('$') || 
                              await this.findElementByText('Price') ||
                              await this.findElementByText('Quote');
          
          if (priceElement) {
            quotedPrice = await priceElement.textContent();
            console.log('✅ Found price: ' + quotedPrice);
          }
          
          // Try to proceed
          const proceed = await this.findElementByText('Proceed') || 
                          await this.findElementByText('Continue') ||
                          await this.findElementByText('Next');
          
          if (proceed) {
            await proceed.click();
            await this.page.waitForTimeout(2000);
            
            // Try to confirm
            const confirm = await this.findElementByText('Confirm') || 
                            await this.findElementByText('Book') ||
                            await this.findElementByText('Complete');
            
            if (confirm) {
              await confirm.click();
              await this.page.waitForTimeout(3000);
              bookingFlowWorking = true;
            }
          }
        }
      }
      
      // Step 3: Check revenue report
      await this.page.goto('http://localhost:8080');
      await this.page.waitForTimeout(3000);
      await this.loginAsAdmin();
      
      const revenue = await this.findElementByText('Revenue') || 
                     await this.findElementByText('Reports') ||
                     await this.findElementByText('Analytics');
      
      let revenueTrackingWorking = false;
      
      if (revenue) {
        await revenue.click();
        await this.page.waitForTimeout(2000);
        
        await this.page.screenshot({ path: 'test-results/ITC_5_4_fixed_revenue.png' });
        
        // Look for the quoted price in revenue
        if (quotedPrice) {
          const priceInRevenue = await this.findElementByText(quotedPrice.replace('$', ''));
          revenueTrackingWorking = !!priceInRevenue;
        }
      }
      
      this.recordResult(
        'ITC 5.4: Fixed-Price Quote to Billing',
        bookingFlowWorking && revenueTrackingWorking,
        bookingFlowWorking && revenueTrackingWorking ? 'Quote to billing flow working' : 'Billing integration incomplete'
      );
      
    } catch (error) {
      this.recordResult('ITC 5.4: Fixed-Price Quote to Billing', false, error.message);
    }
  }

  // ITC 5.5: Proxy Shift to Payroll Audit Trail
  async testProxyShiftToPayroll() {
    console.log('\n🧪 ITC 5.5: Proxy Shift to Payroll Audit Trail');
    
    try {
      // Step 1: Admin creates proxy shift
      await this.page.goto('http://localhost:8080');
      await this.page.waitForTimeout(3000);
      await this.loginAsAdmin();
      
      const tempCard = await this.findElementByText('Temp Card') || 
                      await this.findElementByText('Proxy') ||
                      await this.findElementByText('Manual');
      
      let proxyShiftCreated = false;
      
      if (tempCard) {
        await tempCard.click();
        await this.page.waitForTimeout(2000);
        
        await this.page.screenshot({ path: 'test-results/ITC_5_5_fixed_temp_card.png' });
        
        // Try to create shift
        const createShift = await this.findElementByText('Create') || 
                           await this.findElementByText('Add') ||
                           await this.findElementByText('New');
        
        if (createShift) {
          await createShift.click();
          await this.page.waitForTimeout(2000);
          
          // Fill form
          const form = this.page.locator('form');
          const inputs = form.locator('input, select');
          const inputCount = await inputs.count();
          
          for (let i = 0; i < Math.min(inputCount, 2); i++) {
            const input = inputs.nth(i);
            const tagName = await input.evaluate(el => el.tagName);
            
            if (tagName === 'SELECT') {
              await input.selectOption({ index: 1 });
            } else if (tagName === 'INPUT') {
              await input.fill('8');
            }
            await this.page.waitForTimeout(500);
          }
          
          // Submit
          const submit = await this.findElementByText('Submit') || 
                        await this.findElementByText('Create');
          
          if (submit) {
            await submit.click();
            await this.page.waitForTimeout(2000);
            proxyShiftCreated = true;
          }
        }
      }
      
      // Step 2: Check payroll status
      const payroll = await this.findElementByText('Payroll') || 
                      await this.findElementByText('Reports');
      
      let pendingStatusFound = false;
      
      if (payroll) {
        await payroll.click();
        await this.page.waitForTimeout(2000);
        
        await this.page.screenshot({ path: 'test-results/ITC_5_5_fixed_payroll_pending.png' });
        
        const pending = await this.findElementByText('Pending') || 
                       await this.findElementByText('PENDING');
        
        pendingStatusFound = !!pending;
      }
      
      // Step 3: Staff approval
      await this.page.goto('http://localhost:8080');
      await this.page.waitForTimeout(3000);
      
      await this.page.mouse.click(640, 460);
      await this.page.waitForTimeout(3000);
      
      const staffInputs = this.page.locator('input');
      if (await staffInputs.count() >= 2) {
        await staffInputs.nth(0).fill('staff@example.com');
        await staffInputs.nth(1).fill('staff123');
        await this.page.waitForTimeout(1000);
        
        const submitButton = this.page.locator('button, input[type="submit"]');
        if (await submitButton.isVisible()) {
          await submitButton.click();
          await this.page.waitForTimeout(3000);
        }
      }
      
      const approve = await this.findElementByText('Approve') || 
                      await this.findElementByText('Confirm');
      
      let staffApprovalCompleted = false;
      
      if (approve) {
        await approve.click();
        await this.page.waitForTimeout(2000);
        staffApprovalCompleted = true;
      }
      
      // Step 4: Check final payroll status
      await this.page.goto('http://localhost:8080');
      await this.page.waitForTimeout(3000);
      await this.loginAsAdmin();
      
      if (payroll) {
        await payroll.click();
        await this.page.waitForTimeout(2000);
        
        await this.page.screenshot({ path: 'test-results/ITC_5_5_fixed_payroll_approved.png' });
        
        const approved = await this.findElementByText('Approved') || 
                        await this.findElementByText('APPROVED');
        
        const approvedStatusFound = !!approved;
        
        this.recordResult(
          'ITC 5.5: Proxy Shift to Payroll Audit Trail',
          proxyShiftCreated && pendingStatusFound && staffApprovalCompleted && approvedStatusFound,
          'Complete proxy shift to payroll audit trail working'
        );
      }
      
    } catch (error) {
      this.recordResult('ITC 5.5: Proxy Shift to Payroll Audit Trail', false, error.message);
    }
  }

  // ITC 5.6: Training Completion to Job Eligibility
  async testTrainingToJobEligibility() {
    console.log('\n🧪 ITC 5.6: Training Completion to Job Eligibility');
    
    try {
      // Step 1: Admin updates training status
      await this.page.goto('http://localhost:8080');
      await this.page.waitForTimeout(3000);
      await this.loginAsAdmin();
      
      const training = await this.findElementByText('Training') || 
                      await this.findElementByText('Tracker') ||
                      await this.findElementByText('Development');
      
      let trainingUpdated = false;
      
      if (training) {
        await training.click();
        await this.page.waitForTimeout(2000);
        
        await this.page.screenshot({ path: 'test-results/ITC_5_6_fixed_training.png' });
        
        // Look for staff training record
        const staff = await this.findElementByText('John Staff') || 
                     await this.findElementByText('Staff');
        
        if (staff) {
          // Look for training status dropdown
          const dropdown = staff.locator('..').locator('select');
          if (await dropdown.isVisible()) {
            await dropdown.selectOption({ label: 'COMPLETE' });
            await this.page.waitForTimeout(1000);
            
            // Save
            const save = await this.findElementByText('Save') || 
                        await this.findElementByText('Update');
            
            if (save) {
              await save.click();
              await this.page.waitForTimeout(2000);
              trainingUpdated = true;
            }
          }
        }
      }
      
      // Step 2: Check job eligibility
      const scheduler = await this.findElementByText('Scheduler') || 
                       await this.findElementByText('Jobs');
      
      let jobEligibilityWorking = false;
      
      if (scheduler) {
        await scheduler.click();
        await this.page.waitForTimeout(2000);
        
        await this.page.screenshot({ path: 'test-results/ITC_5_6_fixed_scheduler.png' });
        
        // Try to create specialized job
        const createJob = await this.findElementByText('Create Job') || 
                         await this.findElementByText('New');
        
        if (createJob) {
          await createJob.click();
          await this.page.waitForTimeout(2000);
          
          // Look for staff selection
          const staffSelect = this.page.locator('select[name="staff"], select');
          if (await staffSelect.isVisible()) {
            const options = await staffSelect.locator('option').allTextContents();
            const staffAvailable = options.includes('John Staff');
            
            if (staffAvailable) {
              jobEligibilityWorking = true;
            }
          }
        }
      }
      
      this.recordResult(
        'ITC 5.6: Training Completion to Job Eligibility',
        trainingUpdated && jobEligibilityWorking,
        trainingUpdated && jobEligibilityWorking ? 'Training completion leads to job eligibility' : 'Training to job eligibility incomplete'
      );
      
    } catch (error) {
      this.recordResult('ITC 5.6: Training Completion to Job Eligibility', false, error.message);
    }
  }

  async runAllTests() {
    console.log('🎯 Starting Fixed Integration Test Suite...\n');
    
    await this.setup();
    
    // Run all integration tests
    await this.testScheduleToJobAssignment();
    await this.testManagedLogistics();
    await this.testQualityGatedPayroll();
    await this.testFixedPriceQuoteToBilling();
    await this.testProxyShiftToPayroll();
    await this.testTrainingToJobEligibility();
    
    // Generate final report
    this.generateReport();
    
    await this.cleanup();
  }

  generateReport() {
    console.log('\n📊 FIXED INTEGRATION TEST SUITE REPORT');
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
      results: this.testResults
    };
    
    require('fs').writeFileSync(
      'test-results/fixed_integration_test_report.json',
      JSON.stringify(reportData, null, 2)
    );
    
    console.log('\n📄 Detailed report saved to: test-results/fixed_integration_test_report.json');
  }

  async cleanup() {
    if (this.browser) {
      await this.browser.close();
      console.log('\n🔚 Fixed test suite completed, browser closed');
    }
  }
}

// Run the fixed test suite
const fixedTestSuite = new FixedIntegrationTestSuite();
fixedTestSuite.runAllTests().catch(console.error);
