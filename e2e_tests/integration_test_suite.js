// integration_test_suite.js - Comprehensive E2E tests for all integration cases
const { chromium } = require('playwright');

class IntegrationTestSuite {
  constructor() {
    this.browser = null;
    this.page = null;
    this.testResults = [];
  }

  async setup() {
    console.log('🚀 Setting up Integration Test Suite...');
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

  // ITC 5.1: Schedule-to-Job Assignment Flow
  async testScheduleToJobAssignment() {
    console.log('\n🧪 ITC 5.1: Schedule-to-Job Assignment Flow');
    
    try {
      // Step 1: Navigate to Staff Management
      await this.page.goto('http://localhost:8080');
      await this.page.waitForTimeout(3000);
      
      // Look for Staff Management in admin dashboard
      const staffManagement = this.page.locator('text=Staff Management, text=Staff, text=Schedules');
      if (await staffManagement.isVisible({ timeout: 5000 })) {
        await staffManagement.click();
        await this.page.waitForTimeout(2000);
      }
      
      // Step 2: Update staff schedule to "Off Duty"
      await this.page.screenshot({ path: 'test-results/ITC_5_1_staff_schedule_page.png' });
      
      // Look for staff member and schedule controls
      const staffRow = this.page.locator('tr, div').filter({ hasText: 'John Staff' }).first();
      if (await staffRow.isVisible()) {
        console.log('✅ Found staff member');
        
        // Update schedule to Off Duty
        const scheduleDropdown = staffRow.locator('select, [role="combobox"]');
        if (await scheduleDropdown.isVisible()) {
          await scheduleDropdown.selectOption({ label: 'Off Duty' });
          await this.page.waitForTimeout(1000);
          
          // Save changes
          const saveButton = this.page.locator('button:has-text("Save"), button:has-text("Update")');
          if (await saveButton.isVisible()) {
            await saveButton.click();
            await this.page.waitForTimeout(2000);
          }
        }
      }
      
      // Step 3: Navigate to Scheduler
      const scheduler = this.page.locator('text=Scheduler, text=Job Assignment');
      if (await scheduler.isVisible()) {
        await scheduler.click();
        await this.page.waitForTimeout(2000);
      }
      
      // Step 4: Create job offer for the same day
      await this.page.screenshot({ path: 'test-results/ITC_5_1_scheduler_page.png' });
      
      const createJobButton = this.page.locator('button:has-text("Create Job"), button:has-text("New Job")');
      if (await createJobButton.isVisible()) {
        await createJobButton.click();
        await this.page.waitForTimeout(2000);
        
        // Fill job details
        const jobForm = this.page.locator('form');
        const serviceSelect = jobForm.locator('select[name="service"]');
        const staffSelect = jobForm.locator('select[name="staff"]');
        
        if (await serviceSelect.isVisible()) {
          await serviceSelect.selectOption({ label: 'General Cleaning' });
        }
        
        if (await staffSelect.isVisible()) {
          await staffSelect.selectOption({ label: 'John Staff' }); // The staff we set to Off Duty
        }
        
        // Submit job
        const submitJob = jobForm.locator('button:has-text("Create"), button:has-text("Submit")');
        if (await submitJob.isVisible()) {
          await submitJob.click();
          await this.page.waitForTimeout(3000);
        }
      }
      
      // Step 5: Verify job offer appears and can be accepted
      await this.page.screenshot({ path: 'test-results/ITC_5_1_job_created.png' });
      
      // Look for job offer status
      const jobStatus = this.page.locator('text=Job Offer, text=Pending, text=Assigned');
      const jobOfferVisible = await jobStatus.isVisible();
      
      this.recordResult(
        'ITC 5.1: Schedule-to-Job Assignment',
        jobOfferVisible,
        jobOfferVisible ? 'Staff member with Off Duty schedule successfully received job offer' : 'Job offer not found'
      );
      
    } catch (error) {
      this.recordResult('ITC 5.1: Schedule-to-Job Assignment', false, error.message);
    }
  }

  // ITC 5.2: Managed Logistics to Punctuality
  async testManagedLogistics() {
    console.log('\n🧪 ITC 5.2: Managed Logistics to Punctuality');
    
    try {
      // Step 1: Navigate to Staff App (simulate staff member)
      await this.page.goto('http://localhost:8080');
      await this.page.waitForTimeout(3000);
      
      // Logout from admin and login as staff
      const logoutButton = this.page.locator('button:has-text("Logout"), text=Logout');
      if (await logoutButton.isVisible()) {
        await logoutButton.click();
        await this.page.waitForTimeout(2000);
      }
      
      // Login as staff
      await this.page.mouse.click(640, 460); // Staff Access button
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
      
      // Step 2: Look for active job and Request Uber button
      await this.page.screenshot({ path: 'test-results/ITC_5_2_staff_dashboard.png' });
      
      const requestUberButton = this.page.locator('button:has-text("Request Uber"), text=Request Uber');
      const uberButtonVisible = await requestUberButton.isVisible({ timeout: 5000 });
      
      if (uberButtonVisible) {
        // Click Request Uber
        await requestUberButton.click();
        await this.page.waitForTimeout(3000);
        
        await this.page.screenshot({ path: 'test-results/ITC_5_2_uber_requested.png' });
        
        // Step 3: Switch back to admin to check live tracking
        await this.page.goto('http://localhost:8080');
        await this.page.waitForTimeout(3000);
        await this.loginAsAdmin();
        
        // Navigate to Live Tracking
        const liveTracking = this.page.locator('text=Live Tracking, text=Tracking, text=Map');
        if (await liveTracking.isVisible()) {
          await liveTracking.click();
          await this.page.waitForTimeout(3000);
        }
        
        await this.page.screenshot({ path: 'test-results/ITC_5_2_live_tracking.png' });
        
        // Look for trip status, ETA, location
        const tripStatus = this.page.locator('text=ETA, text=Location, text=Tracking, text=Live');
        const trackingVisible = await tripStatus.isVisible({ timeout: 5000 });
        
        this.recordResult(
          'ITC 5.2: Managed Logistics to Punctuality',
          trackingVisible,
          trackingVisible ? 'Uber API call succeeded and live tracking visible' : 'Live tracking not found'
        );
      } else {
        this.recordResult('ITC 5.2: Managed Logistics to Punctuality', false, 'Request Uber button not found');
      }
      
    } catch (error) {
      this.recordResult('ITC 5.2: Managed Logistics to Punctuality', false, error.message);
    }
  }

  // ITC 5.3: Quality-Gated Payroll Integration
  async testQualityGatedPayroll() {
    console.log('\n🧪 ITC 5.3: Quality-Gated Payroll Integration');
    
    try {
      // Step 1: Navigate to Staff App for clock-out
      await this.page.goto('http://localhost:8080');
      await this.page.waitForTimeout(3000);
      
      // Login as staff
      await this.page.mouse.click(640, 460); // Staff Access
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
      
      // Step 2: Look for Clock-Out button
      await this.page.screenshot({ path: 'test-results/ITC_5_3_staff_timekeeping.png' });
      
      const clockOutButton = this.page.locator('button:has-text("Clock Out"), text=Clock Out');
      const clockOutVisible = await clockOutButton.isVisible({ timeout: 5000 });
      
      if (clockOutVisible) {
        // Try to clock out without completing checklist
        await clockOutButton.click();
        await this.page.waitForTimeout(2000);
        
        // Look for quality checklist
        await this.page.screenshot({ path: 'test-results/ITC_5_3_quality_checklist.png' });
        
        const qualityChecklist = this.page.locator('text=Checklist, text=Quality, text=Complete');
        const checklistVisible = await qualityChecklist.isVisible({ timeout: 5000 });
        
        if (checklistVisible) {
          console.log('✅ Quality checklist appeared - clock out blocked');
          
          // Complete checklist items
          const checklistItems = this.page.locator('input[type="checkbox"], [role="checkbox"]');
          const itemCount = await checklistItems.count();
          
          for (let i = 0; i < itemCount; i++) {
            await checklistItems.nth(i).check();
            await this.page.waitForTimeout(500);
          }
          
          // Add customer rating
          const ratingInput = this.page.locator('input[type="range"], [role="slider"]');
          if (await ratingInput.isVisible()) {
            await ratingInput.fill('5');
            await this.page.waitForTimeout(500);
          }
          
          // Submit completed checklist
          const submitChecklist = this.page.locator('button:has-text("Submit"), button:has-text("Complete")');
          if (await submitChecklist.isVisible()) {
            await submitChecklist.click();
            await this.page.waitForTimeout(3000);
          }
          
          // Now clock out should work
          await clockOutButton.click();
          await this.page.waitForTimeout(3000);
          
          await this.page.screenshot({ path: 'test-results/ITC_5_3_clock_out_complete.png' });
          
          // Step 3: Switch to admin to check payroll
          await this.page.goto('http://localhost:8080');
          await this.page.waitForTimeout(3000);
          await this.loginAsAdmin();
          
          // Navigate to Payroll Report
          const payrollReport = this.page.locator('text=Payroll, text=Reports, text=Draft Payroll');
          if (await payrollReport.isVisible()) {
            await payrollReport.click();
            await this.page.waitForTimeout(3000);
          }
          
          await this.page.screenshot({ path: 'test-results/ITC_5_3_payroll_report.png' });
          
          // Look for VERIFIED status
          const verifiedStatus = this.page.locator('text=VERIFIED, text=Verified, text=Complete');
          const verifiedVisible = await verifiedStatus.isVisible({ timeout: 5000 });
          
          this.recordResult(
            'ITC 5.3: Quality-Gated Payroll Integration',
            verifiedVisible,
            verifiedVisible ? 'Clock out gated by checklist, hours appear as VERIFIED in payroll' : 'VERIFIED status not found in payroll'
          );
        } else {
          this.recordResult('ITC 5.3: Quality-Gated Payroll Integration', false, 'Quality checklist not displayed');
        }
      } else {
        this.recordResult('ITC 5.3: Quality-Gated Payroll Integration', false, 'Clock Out button not found');
      }
      
    } catch (error) {
      this.recordResult('ITC 5.3: Quality-Gated Payroll Integration', false, error.message);
    }
  }

  // ITC 5.4: Fixed-Price Quote to Billing (End-to-End)
  async testFixedPriceQuoteToBilling() {
    console.log('\n🧪 ITC 5.4: Fixed-Price Quote to Billing (End-to-End)');
    
    try {
      // Step 1: Navigate to Customer App
      await this.page.goto('http://localhost:8080');
      await this.page.waitForTimeout(3000);
      
      // Login as customer
      await this.page.mouse.click(640, 360); // Customer Login
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
      
      // Step 2: Navigate to booking
      await this.page.screenshot({ path: 'test-results/ITC_5_4_customer_dashboard.png' });
      
      const bookingButton = this.page.locator('button:has-text("Book Service"), text=Book, text=Services');
      if (await bookingButton.isVisible()) {
        await bookingButton.click();
        await this.page.waitForTimeout(3000);
      }
      
      // Step 3: Select service and get quote
      await this.page.screenshot({ path: 'test-results/ITC_5_4_service_selection.png' });
      
      const serviceOption = this.page.locator('text=General Cleaning, text=Deep Clean, text=Carpet Cleaning');
      if (await serviceOption.isVisible()) {
        await serviceOption.click();
        await this.page.waitForTimeout(2000);
      }
      
      // Look for price quote
      const priceDisplay = this.page.locator('text=$, text=Price, text=Quote');
      const priceVisible = await priceDisplay.isVisible({ timeout: 5000 });
      
      let quotedPrice = '';
      if (priceVisible) {
        quotedPrice = await priceDisplay.textContent();
        console.log('✅ Quoted price: ' + quotedPrice);
        await this.page.screenshot({ path: 'test-results/ITC_5_4_price_quote.png' });
      }
      
      // Step 4: Proceed to booking confirmation
      const proceedButton = this.page.locator('button:has-text("Proceed"), button:has-text("Continue"), button:has-text("Book Now")');
      if (await proceedButton.isVisible()) {
        await proceedButton.click();
        await this.page.waitForTimeout(3000);
      }
      
      // Step 5: Fill booking details and confirm
      await this.page.screenshot({ path: 'test-results/ITC_5_4_booking_confirmation.png' });
      
      const confirmButton = this.page.locator('button:has-text("Confirm Booking"), button:has-text("Pay"), button:has-text("Complete")');
      if (await confirmButton.isVisible()) {
        await confirmButton.click();
        await this.page.waitForTimeout(5000); // Wait for payment processing
      }
      
      await this.page.screenshot({ path: 'test-results/ITC_5_4_booking_complete.png' });
      
      // Step 6: Switch to admin to check revenue report
      await this.page.goto('http://localhost:8080');
      await this.page.waitForTimeout(3000);
      await this.loginAsAdmin();
      
      // Navigate to Revenue Report
      const revenueReport = this.page.locator('text=Revenue, text=Reports, text=Analytics');
      if (await revenueReport.isVisible()) {
        await revenueReport.click();
        await this.page.waitForTimeout(3000);
      }
      
      await this.page.screenshot({ path: 'test-results/ITC_5_4_revenue_report.png' });
      
      // Look for the same amount in revenue report
      const revenueAmount = this.page.locator('text=$' + quotedPrice.replace('$', ''));
      const revenueMatch = await revenueAmount.isVisible({ timeout: 5000 });
      
      this.recordResult(
        'ITC 5.4: Fixed-Price Quote to Billing',
        revenueMatch && quotedPrice !== '',
        revenueMatch ? `Quote ${quotedPrice} matches revenue in report` : 'Price mismatch or quote not found'
      );
      
    } catch (error) {
      this.recordResult('ITC 5.4: Fixed-Price Quote to Billing', false, error.message);
    }
  }

  // ITC 5.5: Proxy Shift to Payroll Audit Trail
  async testProxyShiftToPayroll() {
    console.log('\n🧪 ITC 5.5: Proxy Shift to Payroll Audit Trail');
    
    try {
      // Step 1: Admin creates proxy shift via Temp Card
      await this.page.goto('http://localhost:8080');
      await this.page.waitForTimeout(3000);
      await this.loginAsAdmin();
      
      // Navigate to Temp Card / Proxy Shift
      const tempCard = this.page.locator('text=Temp Card, text=Proxy Shift, text=Manual Entry');
      if (await tempCard.isVisible()) {
        await tempCard.click();
        await this.page.waitForTimeout(3000);
      }
      
      await this.page.screenshot({ path: 'test-results/ITC_5_5_temp_card_page.png' });
      
      // Create proxy shift
      const createShiftButton = this.page.locator('button:has-text("Create Shift"), button:has-text("Add Shift")');
      if (await createShiftButton.isVisible()) {
        await createShiftButton.click();
        await this.page.waitForTimeout(3000);
      }
      
      // Fill shift details
      const shiftForm = this.page.locator('form');
      const staffSelect = shiftForm.locator('select[name="staff"]');
      const hoursInput = shiftForm.locator('input[name="hours"]');
      
      if (await staffSelect.isVisible()) {
        await staffSelect.selectOption({ label: 'John Staff' });
      }
      
      if (await hoursInput.isVisible()) {
        await hoursInput.fill('8');
      }
      
      // Submit proxy shift
      const submitShift = shiftForm.locator('button:has-text("Create"), button:has-text("Submit")');
      if (await submitShift.isVisible()) {
        await submitShift.click();
        await this.page.waitForTimeout(3000);
      }
      
      await this.page.screenshot({ path: 'test-results/ITC_5_5_proxy_shift_created.png' });
      
      // Step 2: Check payroll report - should show PENDING
      const payrollReport = this.page.locator('text=Payroll, text=Reports');
      if (await payrollReport.isVisible()) {
        await payrollReport.click();
        await this.page.waitForTimeout(3000);
      }
      
      await this.page.screenshot({ path: 'test-results/ITC_5_5_payroll_pending.png' });
      
      const pendingStatus = this.page.locator('text=PENDING, text=Pending');
      const pendingVisible = await pendingStatus.isVisible({ timeout: 5000 });
      
      // Step 3: Switch to staff app for approval
      await this.page.goto('http://localhost:8080');
      await this.page.waitForTimeout(3000);
      
      // Login as staff
      await this.page.mouse.click(640, 460); // Staff Access
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
      
      // Look for shift approval
      await this.page.screenshot({ path: 'test-results/ITC_5_5_staff_approval.png' });
      
      const approveButton = this.page.locator('button:has-text("Approve"), button:has-text("Confirm")');
      const approvalVisible = await approveButton.isVisible({ timeout: 5000 });
      
      if (approvalVisible) {
        await approveButton.click();
        await this.page.waitForTimeout(3000);
        
        await this.page.screenshot({ path: 'test-results/ITC_5_5_shift_approved.png' });
      }
      
      // Step 4: Check payroll again - should show APPROVED
      await this.page.goto('http://localhost:8080');
      await this.page.waitForTimeout(3000);
      await this.loginAsAdmin();
      
      const payrollReport2 = this.page.locator('text=Payroll, text=Reports');
      if (await payrollReport2.isVisible()) {
        await payrollReport2.click();
        await this.page.waitForTimeout(3000);
      }
      
      await this.page.screenshot({ path: 'test-results/ITC_5_5_payroll_approved.png' });
      
      const approvedStatus = this.page.locator('text=APPROVED, text=Approved');
      const approvedVisible = await approvedStatus.isVisible({ timeout: 5000 });
      
      this.recordResult(
        'ITC 5.5: Proxy Shift to Payroll Audit Trail',
        pendingVisible && approvedVisible,
        'Proxy shift shows PENDING initially, then APPROVED after staff approval'
      );
      
    } catch (error) {
      this.recordResult('ITC 5.5: Proxy Shift to Payroll Audit Trail', false, error.message);
    }
  }

  // ITC 5.6: Training Completion to Job Eligibility
  async testTrainingToJobEligibility() {
    console.log('\n🧪 ITC 5.6: Training Completion to Job Eligibility');
    
    try {
      // Step 1: Admin navigates to Training Tracker
      await this.page.goto('http://localhost:8080');
      await this.page.waitForTimeout(3000);
      await this.loginAsAdmin();
      
      const trainingTracker = this.page.locator('text=Training, text=Tracker, text=Staff Development');
      if (await trainingTracker.isVisible()) {
        await trainingTracker.click();
        await this.page.waitForTimeout(3000);
      }
      
      await this.page.screenshot({ path: 'test-results/ITC_5_6_training_tracker.png' });
      
      // Step 2: Find staff member and mark training as COMPLETE
      const staffRow = this.page.locator('tr, div').filter({ hasText: 'John Staff' }).first();
      if (await staffRow.isVisible()) {
        console.log('✅ Found staff member in training tracker');
        
        // Look for Carpet Cleaning training
        const carpetTraining = staffRow.locator('text=Carpet Cleaning');
        const trainingStatus = carpetTraining.locator('..').locator('select, [role="combobox"]');
        
        if (await trainingStatus.isVisible()) {
          await trainingStatus.selectOption({ label: 'COMPLETE' });
          await this.page.waitForTimeout(1000);
          
          // Save training status
          const saveButton = this.page.locator('button:has-text("Save"), button:has-text("Update")');
          if (await saveButton.isVisible()) {
            await saveButton.click();
            await this.page.waitForTimeout(2000);
          }
        }
      }
      
      await this.page.screenshot({ path: 'test-results/ITC_5_6_training_complete.png' });
      
      // Step 3: Navigate to Scheduler to check job eligibility
      const scheduler = this.page.locator('text=Scheduler, text=Job Assignment');
      if (await scheduler.isVisible()) {
        await scheduler.click();
        await this.page.waitForTimeout(3000);
      }
      
      await this.page.screenshot({ path: 'test-results/ITC_5_6_scheduler_page.png' });
      
      // Step 4: Create Carpet Cleaning job
      const createJobButton = this.page.locator('button:has-text("Create Job"), button:has-text("New Job")');
      if (await createJobButton.isVisible()) {
        await createJobButton.click();
        await this.page.waitForTimeout(3000);
      }
      
      // Fill job details for Carpet Cleaning
      const jobForm = this.page.locator('form');
      const serviceSelect = jobForm.locator('select[name="service"]');
      const staffSelect = jobForm.locator('select[name="staff"]');
      
      if (await serviceSelect.isVisible()) {
        await serviceSelect.selectOption({ label: 'Carpet Cleaning' });
      }
      
      // Check if John Staff is now eligible for Carpet Cleaning
      if (await staffSelect.isVisible()) {
        const staffOptions = await staffSelect.locator('option').allTextContents();
        const johnEligible = staffOptions.includes('John Staff');
        
        if (johnEligible) {
          await staffSelect.selectOption({ label: 'John Staff' });
          
          // Submit job
          const submitJob = jobForm.locator('button:has-text("Create"), button:has-text("Submit")');
          if (await submitJob.isVisible()) {
            await submitJob.click();
            await this.page.waitForTimeout(3000);
          }
          
          await this.page.screenshot({ path: 'test-results/ITC_5_6_carpet_job_assigned.png' });
        }
        
        this.recordResult(
          'ITC 5.6: Training Completion to Job Eligibility',
          johnEligible,
          johnEligible ? 'Staff with COMPLETE training immediately eligible for specialized jobs' : 'Staff not eligible despite completed training'
        );
      } else {
        this.recordResult('ITC 5.6: Training Completion to Job Eligibility', false, 'Staff selection not available in job creation');
      }
      
    } catch (error) {
      this.recordResult('ITC 5.6: Training Completion to Job Eligibility', false, error.message);
    }
  }

  async runAllTests() {
    console.log('🎯 Starting Complete Integration Test Suite...\n');
    
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
    console.log('\n📊 INTEGRATION TEST SUITE REPORT');
    console.log('=====================================');
    
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
      'test-results/integration_test_report.json',
      JSON.stringify(reportData, null, 2)
    );
    
    console.log('\n📄 Detailed report saved to: test-results/integration_test_report.json');
  }

  async cleanup() {
    if (this.browser) {
      await this.browser.close();
      console.log('\n🔚 Test suite completed, browser closed');
    }
  }
}

// Run the complete test suite
const testSuite = new IntegrationTestSuite();
testSuite.runAllTests().catch(console.error);
