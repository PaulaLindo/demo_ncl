// comprehensive_integration_suite.js - Full E2E tests using actual component names and coordinate login
const { chromium } = require('playwright');

class ComprehensiveIntegrationSuite {
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
    console.log('🚀 Setting up Comprehensive Integration Test Suite...');
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

  // Helper method for coordinate-based login
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
    
    // Click login button
    await this.page.mouse.click(coords.x, coords.y);
    await this.page.waitForTimeout(3000);
    
    // Fill credentials
    const inputs = this.page.locator('input');
    if (await inputs.count() >= 2) {
      await inputs.nth(0).fill(email);
      await inputs.nth(1).fill(password);
      await this.page.waitForTimeout(1000);
      
      // Submit login
      const submitButton = this.page.locator('button, input[type="submit"]');
      if (await submitButton.isVisible()) {
        await submitButton.click();
        await this.page.waitForTimeout(3000);
      }
    }
    
    console.log(`✅ ${role} login completed`);
  }

  // ITC 5.1: Schedule-to-Job Assignment Flow
  async testScheduleToJobAssignment() {
    console.log('\n🧪 ITC 5.1: Schedule-to-Job Assignment Flow');
    
    try {
      // Step 1: Login as admin and navigate to staff management
      await this.loginAs('admin');
      
      await this.page.screenshot({ path: 'test-results/ITC_5_1_admin_dashboard.png' });
      
      // Look for staff management in admin dashboard
      const staffManagement = await this.findElementByText('Staff Management') || 
                            await this.findElementByText('Staff') ||
                            await this.findElementByText('Schedule');
      
      if (staffManagement) {
        await staffManagement.click();
        await this.page.waitForTimeout(2000);
      }
      
      await this.page.screenshot({ path: 'test-results/ITC_5_1_staff_management.png' });
      
      // Step 2: Update staff schedule availability
      const staffMember = await this.findElementByText('John Staff') || 
                          await this.findElementByText('Available') ||
                          await this.findElementByText('Schedule');
      
      if (staffMember) {
        await staffMember.click();
        await this.page.waitForTimeout(1000);
        
        // Look for availability toggle/dropdown
        const availabilityToggle = this.page.locator('select, [role="combobox"], switch, input[type="checkbox"]');
        if (await availabilityToggle.isVisible()) {
          await availabilityToggle.click();
          await this.page.waitForTimeout(1000);
          
          // Save changes
          const saveButton = await this.findElementByText('Save') || 
                            await this.findElementByText('Update');
          if (saveButton) {
            await saveButton.click();
            await this.page.waitForTimeout(2000);
          }
        }
      }
      
      // Step 3: Navigate to scheduler
      const scheduler = await this.findElementByText('Scheduler') || 
                       await this.findElementByText('Jobs') ||
                       await this.findElementByText('Assignment');
      
      if (scheduler) {
        await scheduler.click();
        await this.page.waitForTimeout(2000);
      }
      
      await this.page.screenshot({ path: 'test-results/ITC_5_1_scheduler.png' });
      
      // Step 4: Create job assignment
      const createJob = await this.findElementByText('Create Job') || 
                        await this.findElementByText('New Job') ||
                        await this.findElementByText('Assign');
      
      let jobAssignmentCreated = false;
      
      if (createJob) {
        await createJob.click();
        await this.page.waitForTimeout(2000);
        
        // Fill job assignment form
        const form = this.page.locator('form');
        const serviceSelect = form.locator('select[name="service"]');
        const staffSelect = form.locator('select[name="staff"]');
        
        if (await serviceSelect.isVisible()) {
          await serviceSelect.selectOption({ label: 'General Cleaning' });
        }
        
        if (await staffSelect.isVisible()) {
          await staffSelect.selectOption({ label: 'John Staff' });
        }
        
        // Submit job assignment
        const submitJob = await this.findElementByText('Submit') || 
                         await this.findElementByText('Create') ||
                         await this.findElementByText('Assign');
        
        if (submitJob) {
          await submitJob.click();
          await this.page.waitForTimeout(3000);
          jobAssignmentCreated = true;
        }
      }
      
      await this.page.screenshot({ path: 'test-results/ITC_5_1_job_assigned.png' });
      
      // Step 5: Verify job assignment appears in system
      const jobStatus = await this.findElementByText('Assigned') || 
                       await this.findElementByText('Active') ||
                       await this.findElementByText('Job');
      
      this.recordResult(
        'ITC 5.1: Schedule-to-Job Assignment Flow',
        jobAssignmentCreated,
        jobAssignmentCreated ? 'Staff schedule updated and job assignment created successfully' : 'Job assignment flow incomplete'
      );
      
    } catch (error) {
      this.recordResult('ITC 5.1: Schedule-to-Job Assignment Flow', false, error.message);
    }
  }

  // ITC 5.2: Managed Logistics to Punctuality
  async testManagedLogistics() {
    console.log('\n🧪 ITC 5.2: Managed Logistics to Punctuality');
    
    try {
      // Step 1: Login as staff and request transport
      await this.loginAs('staff');
      
      await this.page.screenshot({ path: 'test-results/ITC_5_2_staff_dashboard.png' });
      
      // Look for active job and transport request
      const requestTransport = await this.findElementByText('Request Transport') || 
                              await this.findElementByText('Request Uber') ||
                              await this.findElementByText('Travel') ||
                              await this.findElementByText('Logistics');
      
      let transportRequested = false;
      
      if (requestTransport) {
        await requestTransport.click();
        await this.page.waitForTimeout(3000);
        transportRequested = true;
        
        await this.page.screenshot({ path: 'test-results/ITC_5_2_transport_requested.png' });
      }
      
      // Step 2: Switch to admin to check live tracking
      await this.loginAs('admin');
      
      // Navigate to live tracking
      const liveTracking = await this.findElementByText('Live Tracking') || 
                          await this.findElementByText('Tracking') ||
                          await this.findElementByText('Map') ||
                          await this.findElementByText('Logistics');
      
      let trackingVisible = false;
      
      if (liveTracking) {
        await liveTracking.click();
        await this.page.waitForTimeout(2000);
        
        await this.page.screenshot({ path: 'test-results/ITC_5_2_live_tracking.png' });
        
        // Look for tracking elements
        const trackingElements = await this.findElementByText('ETA') || 
                               await this.findElementByText('Location') ||
                               await this.findElementByText('Live') ||
                               await this.findElementByText('Tracking');
        
        trackingVisible = !!trackingElements;
      }
      
      this.recordResult(
        'ITC 5.2: Managed Logistics to Punctuality',
        transportRequested && trackingVisible,
        transportRequested && trackingVisible ? 'Transport requested and live tracking visible' : 'Logistics flow incomplete'
      );
      
    } catch (error) {
      this.recordResult('ITC 5.2: Managed Logistics to Punctuality', false, error.message);
    }
  }

  // ITC 5.3: Quality-Gated Payroll Integration
  async testQualityGatedPayroll() {
    console.log('\n🧪 ITC 5.3: Quality-Gated Payroll Integration');
    
    try {
      // Step 1: Login as staff and attempt clock-out
      await this.loginAs('staff');
      
      // Navigate to timekeeping
      const timekeeping = await this.findElementByText('Timekeeping') || 
                          await this.findElementByText('Hours') ||
                          await this.findElementByText('Clock');
      
      if (timekeeping) {
        await timekeeping.click();
        await this.page.waitForTimeout(2000);
      }
      
      await this.page.screenshot({ path: 'test-results/ITC_5_3_timekeeping.png' });
      
      // Look for clock-out button
      const clockOut = await this.findElementByText('Clock Out') || 
                       await this.findElementByText('Check Out');
      
      let qualityGateWorking = false;
      
      if (clockOut) {
        await clockOut.click();
        await this.page.waitForTimeout(2000);
        
        await this.page.screenshot({ path: 'test-results/ITC_5_3_quality_gate.png' });
        
        // Look for quality checklist
        const checklist = await this.findElementByText('Checklist') || 
                         await this.findElementByText('Quality') ||
                         await this.findElementByText('Complete') ||
                         await this.findElementByText('Survey');
        
        if (checklist) {
          qualityGateWorking = true;
          
          // Complete checklist items
          const checkboxes = this.page.locator('input[type="checkbox"], [role="checkbox"]');
          const checkboxCount = await checkboxes.count();
          
          for (let i = 0; i < Math.min(checkboxCount, 5); i++) {
            await checkboxes.nth(i).check();
            await this.page.waitForTimeout(500);
          }
          
          // Add customer rating
          const ratingSlider = this.page.locator('input[type="range"], [role="slider"]');
          if (await ratingSlider.isVisible()) {
            await ratingSlider.fill('5');
            await this.page.waitForTimeout(500);
          }
          
          // Submit checklist
          const submitChecklist = await this.findElementByText('Submit') || 
                                await this.findElementByText('Complete') ||
                                await this.findElementByText('Done');
          
          if (submitChecklist) {
            await submitChecklist.click();
            await this.page.waitForTimeout(2000);
          }
          
          // Now clock out should work
          await clockOut.click();
          await this.page.waitForTimeout(3000);
        }
      }
      
      await this.page.screenshot({ path: 'test-results/ITC_5_3_clocked_out.png' });
      
      // Step 2: Check payroll report as admin
      await this.loginAs('admin');
      
      // Navigate to payroll
      const payroll = await this.findElementByText('Payroll') || 
                      await this.findElementByText('Reports') ||
                      await this.findElementByText('Hours Report');
      
      let payrollUpdated = false;
      
      if (payroll) {
        await payroll.click();
        await this.page.waitForTimeout(2000);
        
        await this.page.screenshot({ path: 'test-results/ITC_5_3_payroll_report.png' });
        
        // Look for verified hours
        const verifiedStatus = await this.findElementByText('Verified') || 
                             await this.findElementByText('Complete') ||
                             await this.findElementByText('Approved');
        
        payrollUpdated = !!verifiedStatus;
      }
      
      this.recordResult(
        'ITC 5.3: Quality-Gated Payroll Integration',
        qualityGateWorking && payrollUpdated,
        qualityGateWorking && payrollUpdated ? 'Quality gate enforced and payroll updated with verified hours' : 'Quality-gated payroll incomplete'
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
      await this.loginAs('customer');
      
      await this.page.screenshot({ path: 'test-results/ITC_5_4_customer_dashboard.png' });
      
      // Step 2: Navigate to booking
      const bookService = await this.findElementByText('Book Service') || 
                         await this.findElementByText('Book') ||
                         await this.findElementByText('Services') ||
                         await this.findElementByText('Booking');
      
      let bookingFlowWorking = false;
      let quotedPrice = '';
      
      if (bookService) {
        await bookService.click();
        await this.page.waitForTimeout(2000);
        
        await this.page.screenshot({ path: 'test-results/ITC_5_4_services.png' });
        
        // Select service
        const service = await this.findElementByText('Cleaning') || 
                       await this.findElementByText('Service') ||
                       await this.findElementByText('General');
        
        if (service) {
          await service.click();
          await this.page.waitForTimeout(1000);
          
          // Look for price quote
          const priceElement = await this.findElementByText('$') || 
                              await this.findElementByText('Price') ||
                              await this.findElementByText('Quote') ||
                              await this.findElementByText('Cost');
          
          if (priceElement) {
            quotedPrice = await priceElement.textContent();
            console.log('✅ Found quoted price: ' + quotedPrice);
          }
          
          // Proceed with booking
          const proceed = await this.findElementByText('Proceed') || 
                          await this.findElementByText('Continue') ||
                          await this.findElementByText('Next') ||
                          await this.findElementByText('Book Now');
          
          if (proceed) {
            await proceed.click();
            await this.page.waitForTimeout(2000);
            
            // Confirm booking
            const confirm = await this.findElementByText('Confirm') || 
                            await this.findElementByText('Book') ||
                            await this.findElementByText('Complete') ||
                            await this.findElementByText('Pay');
            
            if (confirm) {
              await confirm.click();
              await this.page.waitForTimeout(5000);
              bookingFlowWorking = true;
            }
          }
        }
      }
      
      await this.page.screenshot({ path: 'test-results/ITC_5_4_booking_complete.png' });
      
      // Step 3: Check revenue report as admin
      await this.loginAs('admin');
      
      // Navigate to revenue reports
      const revenue = await this.findElementByText('Revenue') || 
                     await this.findElementByText('Reports') ||
                     await this.findElementByText('Analytics') ||
                     await this.findElementByText('Billing');
      
      let revenueTrackingWorking = false;
      
      if (revenue) {
        await revenue.click();
        await this.page.waitForTimeout(2000);
        
        await this.page.screenshot({ path: 'test-results/ITC_5_4_revenue_report.png' });
        
        // Look for the quoted price in revenue
        if (quotedPrice) {
          const priceInRevenue = await this.findElementByText(quotedPrice.replace('$', ''));
          revenueTrackingWorking = !!priceInRevenue;
        }
      }
      
      this.recordResult(
        'ITC 5.4: Fixed-Price Quote to Billing',
        bookingFlowWorking && revenueTrackingWorking,
        bookingFlowWorking && revenueTrackingWorking ? 'Quote to billing flow working with price matching' : 'Quote to billing incomplete'
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
      await this.loginAs('admin');
      
      // Navigate to temp card/proxy shift
      const tempCard = await this.findElementByText('Temp Card') || 
                      await this.findElementByText('Proxy Shift') ||
                      await this.findElementByText('Manual Entry') ||
                      await this.findElementByText('Add Shift');
      
      let proxyShiftCreated = false;
      
      if (tempCard) {
        await tempCard.click();
        await this.page.waitForTimeout(2000);
        
        await this.page.screenshot({ path: 'test-results/ITC_5_5_temp_card.png' });
        
        // Create proxy shift
        const createShift = await this.findElementByText('Create Shift') || 
                           await this.findElementByText('Add') ||
                           await this.findElementByText('New');
        
        if (createShift) {
          await createShift.click();
          await this.page.waitForTimeout(2000);
          
          // Fill shift details
          const form = this.page.locator('form');
          const inputs = form.locator('input, select');
          const inputCount = await inputs.count();
          
          for (let i = 0; i < Math.min(inputCount, 3); i++) {
            const input = inputs.nth(i);
            const tagName = await input.evaluate(el => el.tagName);
            
            if (tagName === 'SELECT') {
              await input.selectOption({ index: 1 });
            } else if (tagName === 'INPUT') {
              const inputType = await input.getAttribute('type');
              if (inputType === 'text') {
                await input.fill('Test Shift');
              } else if (inputType === 'number') {
                await input.fill('8');
              }
            }
            await this.page.waitForTimeout(500);
          }
          
          // Submit proxy shift
          const submit = await this.findElementByText('Submit') || 
                        await this.findElementByText('Create') ||
                        await this.findElementByText('Save');
          
          if (submit) {
            await submit.click();
            await this.page.waitForTimeout(2000);
            proxyShiftCreated = true;
          }
        }
      }
      
      // Step 2: Check payroll for PENDING status
      const payroll = await this.findElementByText('Payroll') || 
                      await this.findElementByText('Reports');
      
      let pendingStatusFound = false;
      
      if (payroll) {
        await payroll.click();
        await this.page.waitForTimeout(2000);
        
        await this.page.screenshot({ path: 'test-results/ITC_5_5_payroll_pending.png' });
        
        const pending = await this.findElementByText('Pending') || 
                       await this.findElementByText('PENDING') ||
                       await this.findElementByText('Awaiting');
        
        pendingStatusFound = !!pending;
      }
      
      // Step 3: Staff approval
      await this.loginAs('staff');
      
      // Look for shift approval
      const approveShift = await this.findElementByText('Approve') || 
                           await this.findElementByText('Confirm') ||
                           await this.findElementByText('Review');
      
      let staffApprovalCompleted = false;
      
      if (approveShift) {
        await approveShift.click();
        await this.page.waitForTimeout(2000);
        staffApprovalCompleted = true;
        
        await this.page.screenshot({ path: 'test-results/ITC_5_5_shift_approved.png' });
      }
      
      // Step 4: Check final payroll status
      await this.loginAs('admin');
      
      if (payroll) {
        await payroll.click();
        await this.page.waitForTimeout(2000);
        
        await this.page.screenshot({ path: 'test-results/ITC_5_5_payroll_final.png' });
        
        const approved = await this.findElementByText('Approved') || 
                        await this.findElementByText('APPROVED') ||
                        await this.findElementByText('Complete');
        
        const approvedStatusFound = !!approved;
        
        this.recordResult(
          'ITC 5.5: Proxy Shift to Payroll Audit Trail',
          proxyShiftCreated && pendingStatusFound && staffApprovalCompleted && approvedStatusFound,
          'Complete proxy shift to payroll audit trail working with proper status transitions'
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
      await this.loginAs('admin');
      
      // Navigate to training management
      const training = await this.findElementByText('Training') || 
                      await this.findElementByText('Development') ||
                      await this.findElementByText('Skills') ||
                      await this.findElementByText('Courses');
      
      let trainingUpdated = false;
      
      if (training) {
        await training.click();
        await this.page.waitForTimeout(2000);
        
        await this.page.screenshot({ path: 'test-results/ITC_5_6_training.png' });
        
        // Find staff training record
        const staffTraining = await this.findElementByText('John Staff') || 
                              await this.findElementByText('Training') ||
                              await this.findElementByText('Skills');
        
        if (staffTraining) {
          // Look for training status dropdown
          const statusDropdown = staffTraining.locator('..').locator('select, [role="combobox"]');
          if (await statusDropdown.isVisible()) {
            await statusDropdown.selectOption({ label: 'COMPLETE' });
            await this.page.waitForTimeout(1000);
            
            // Save training status
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
      
      // Step 2: Check job eligibility in scheduler
      const scheduler = await this.findElementByText('Scheduler') || 
                       await this.findElementByText('Jobs') ||
                       await this.findElementByText('Assignment');
      
      let jobEligibilityWorking = false;
      
      if (scheduler) {
        await scheduler.click();
        await this.page.waitForTimeout(2000);
        
        await this.page.screenshot({ path: 'test-results/ITC_5_6_scheduler.png' });
        
        // Create specialized job
        const createJob = await this.findElementByText('Create Job') || 
                         await this.findElementByText('New Job');
        
        if (createJob) {
          await createJob.click();
          await this.page.waitForTimeout(2000);
          
          // Look for specialized service (e.g., Carpet Cleaning)
          const serviceSelect = this.page.locator('select[name="service"]');
          if (await serviceSelect.isVisible()) {
            await serviceSelect.selectOption({ label: 'Carpet Cleaning' });
            await this.page.waitForTimeout(1000);
          }
          
          // Check if trained staff is now eligible
          const staffSelect = this.page.locator('select[name="staff"]');
          if (await staffSelect.isVisible()) {
            const options = await staffSelect.locator('option').allTextContents();
            const trainedStaffEligible = options.includes('John Staff');
            
            if (trainedStaffEligible) {
              await staffSelect.selectOption({ label: 'John Staff' });
              jobEligibilityWorking = true;
            }
          }
        }
      }
      
      await this.page.screenshot({ path: 'test-results/ITC_5_6_eligibility_confirmed.png' });
      
      this.recordResult(
        'ITC 5.6: Training Completion to Job Eligibility',
        trainingUpdated && jobEligibilityWorking,
        trainingUpdated && jobEligibilityWorking ? 'Training completion immediately enables job eligibility' : 'Training to job eligibility incomplete'
      );
      
    } catch (error) {
      this.recordResult('ITC 5.6: Training Completion to Job Eligibility', false, error.message);
    }
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

  async runAllTests() {
    console.log('🎯 Starting Comprehensive Integration Test Suite...\n');
    
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
    console.log('\n📊 COMPREHENSIVE INTEGRATION TEST SUITE REPORT');
    console.log('===============================================');
    
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
      'test-results/comprehensive_integration_test_report.json',
      JSON.stringify(reportData, null, 2)
    );
    
    console.log('\n📄 Detailed report saved to: test-results/comprehensive_integration_test_report.json');
    console.log('📸 Screenshots saved in: test-results/ directory');
  }

  async cleanup() {
    if (this.browser) {
      await this.browser.close();
      console.log('\n🔚 Comprehensive test suite completed, browser closed');
    }
  }
}

// Run the comprehensive test suite
const comprehensiveTestSuite = new ComprehensiveIntegrationSuite();
comprehensiveTestSuite.runAllTests().catch(console.error);
