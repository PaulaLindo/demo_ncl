// run-tests.js - Test runner for mobile and desktop tests
const { execSync } = require('child_process');
const fs = require('fs');
const path = require('path');

// ANSI color codes for console output
const colors = {
  reset: '\x1b[0m',
  bright: '\x1b[1m',
  red: '\x1b[31m',
  green: '\x1b[32m',
  yellow: '\x1b[33m',
  blue: '\x1b[34m',
  magenta: '\x1b[35m',
  cyan: '\x1b[36m',
};

function log(message, color = 'reset') {
  console.log(`${colors[color]}${message}${colors.reset}`);
}

function logSection(title) {
  log('\n' + '='.repeat(60), 'cyan');
  log(`  ${title}`, 'cyan');
  log('='.repeat(60), 'cyan');
}

function logStep(step) {
  log(`\n📋 ${step}`, 'yellow');
}

function logSuccess(message) {
  log(`✅ ${message}`, 'green');
}

function logError(message) {
  log(`❌ ${message}`, 'red');
}

function logInfo(message) {
  log(`ℹ️  ${message}`, 'blue');
}

// Check if Flutter app is running
function checkFlutterApp() {
  logStep('Checking if Flutter app is running...');
  
  try {
    const response = execSync('curl -s -o /dev/null -w "%{http_code}" http://localhost:8098', { 
      encoding: 'utf8',
      timeout: 5000 
    });
    
    if (response === '200') {
      logSuccess('Flutter app is running on http://localhost:8098');
      return true;
    } else {
      logError(`Flutter app responded with status: ${response}`);
      return false;
    }
  } catch (error) {
    logError('Flutter app is not running on http://localhost:8098');
    logInfo('Please start the Flutter app first:');
    logInfo('  flutter run -d web-server --web-port=8098 -t lib/main_auth_simple.dart');
    return false;
  }
}

// Check if Playwright is installed
function checkPlaywright() {
  logStep('Checking Playwright installation...');
  
  try {
    execSync('npx playwright --version', { encoding: 'utf8' });
    logSuccess('Playwright is installed');
    return true;
  } catch (error) {
    logError('Playwright is not installed');
    logInfo('Install Playwright with:');
    logInfo('  npm install @playwright/test');
    logInfo('  npx playwright install');
    return false;
  }
}

// Run Playwright tests
function runPlaywrightTests(testType = 'all') {
  logSection('Running Playwright Tests');
  
  const testFile = 'playwright.mobile-desktop-tests.js';
  
  if (!fs.existsSync(testFile)) {
    logError(`Test file not found: ${testFile}`);
    return false;
  }
  
  let command = `npx playwright test ${testFile}`;
  
  switch (testType) {
    case 'mobile':
      command += ' --grep "Mobile"';
      break;
    case 'desktop':
      command += ' --grep "Desktop"';
      break;
    case 'cross-platform':
      command += ' --grep "Cross-Platform"';
      break;
    case 'errors':
      command += ' --grep "Error Handling"';
      break;
  }
  
  command += ' --reporter=list';
  
  logInfo(`Running command: ${command}`);
  
  try {
    execSync(command, { 
      stdio: 'inherit',
      encoding: 'utf8',
      cwd: process.cwd()
    });
    logSuccess('Playwright tests completed');
    return true;
  } catch (error) {
    logError('Playwright tests failed');
    logInfo('Check the test output above for details');
    return false;
  }
}

// Run Flutter widget tests
function runFlutterTests() {
  logSection('Running Flutter Widget Tests');
  
  const testFiles = [
    'test/integration/mobile_simulation_test.dart',
    'test/integration/simple_login_test.dart',
    'test/integration/enhanced_mobile_dashboard_test.dart'
  ];
  
  let allPassed = true;
  
  for (const testFile of testFiles) {
    if (fs.existsSync(testFile)) {
      logInfo(`Running: flutter test ${testFile}`);
      
      try {
        execSync(`flutter test ${testFile} --reporter=compact`, { 
          stdio: 'inherit',
          encoding: 'utf8',
          cwd: process.cwd()
        });
        logSuccess(`✅ ${testFile} passed`);
      } catch (error) {
        logError(`❌ ${testFile} failed`);
        allPassed = false;
      }
    } else {
      logInfo(`⚠️  ${testFile} not found, skipping`);
    }
  }
  
  return allPassed;
}

// Generate test report
function generateReport(results) {
  logSection('Test Report Summary');
  
  const timestamp = new Date().toISOString();
  const report = {
    timestamp,
    flutterApp: results.flutterApp,
    playwrightInstalled: results.playwrightInstalled,
    playwrightTests: results.playwrightTests,
    flutterTests: results.flutterTests,
    summary: {
      total: Object.values(results).filter(r => r === true).length,
      passed: Object.values(results).filter(r => r === true).length,
      failed: Object.values(results).filter(r => r === false).length,
    }
  };
  
  const reportPath = 'test-report.json';
  fs.writeFileSync(reportPath, JSON.stringify(report, null, 2));
  
  logInfo(`Test report saved to: ${reportPath}`);
  
  // Display summary
  log(`\n📊 Summary:`, 'bright');
  log(`   Total Checks: ${report.summary.total}`);
  log(`   Passed: ${colors.green}${report.summary.passed}${colors.reset}`);
  log(`   Failed: ${colors.red}${report.summary.failed}${colors.reset}`);
  
  if (report.summary.failed === 0) {
    logSuccess('🎉 All tests passed!');
  } else {
    logError('❌ Some tests failed. Check the output above.');
  }
}

// Main execution
function main() {
  const args = process.argv.slice(2);
  const testType = args[0] || 'all';
  
  logSection('NCL App Test Runner');
  log(`Running tests for: ${testType}`, 'bright');
  
  const results = {};
  
  // Check prerequisites
  results.flutterApp = checkFlutterApp();
  if (!results.flutterApp) {
    logError('Cannot proceed without running Flutter app');
    process.exit(1);
  }
  
  results.playwrightInstalled = checkPlaywright();
  if (!results.playwrightInstalled) {
    logError('Cannot proceed without Playwright');
    process.exit(1);
  }
  
  // Run tests
  if (testType === 'all' || testType === 'playwright') {
    results.playwrightTests = runPlaywrightTests(testType === 'all' ? 'all' : testType);
  }
  
  if (testType === 'all' || testType === 'flutter') {
    results.flutterTests = runFlutterTests();
  }
  
  // Generate report
  generateReport(results);
}

// Show usage information
function showUsage() {
  logSection('Test Runner Usage');
  log('node run-tests.js [test-type]', 'bright');
  log('\nAvailable test types:', 'bright');
  log('  all          - Run all tests (default)', 'green');
  log('  playwright   - Run only Playwright tests', 'green');
  log('  mobile       - Run only mobile tests', 'green');
  log('  desktop      - Run only desktop tests', 'green');
  log('  cross-platform - Run cross-platform tests', 'green');
  log('  errors       - Run error handling tests', 'green');
  log('  flutter      - Run only Flutter widget tests', 'green');
  log('\nExamples:', 'bright');
  log('  node run-tests.js', 'cyan');
  log('  node run-tests.js mobile', 'cyan');
  log('  node run-tests.js playwright', 'cyan');
  log('  node run-tests.js flutter', 'cyan');
}

// Check for help flag
if (process.argv.includes('--help') || process.argv.includes('-h')) {
  showUsage();
  process.exit(0);
}

// Run main function
main().catch((error) => {
  logError(`Unexpected error: ${error.message}`);
  process.exit(1);
});
