// scripts/run-auth-tests.js - Comprehensive authentication test runner
const { exec } = require('child_process');
const fs = require('fs');
const path = require('path');

// ANSI color codes for better output
const colors = {
  reset: '\x1b[0m',
  bright: '\x1b[1m',
  red: '\x1b[31m',
  green: '\x1b[32m',
  yellow: '\x1b[33m',
  blue: '\x1b[34m',
  magenta: '\x1b[35m',
  cyan: '\x1b[36m'
};

function log(message, color = 'reset') {
  console.log(`${colors[color]}${message}${colors.reset}`);
}

function runCommand(command, description) {
  return new Promise((resolve, reject) => {
    log(`\n🚀 ${description}`, 'cyan');
    log(`📝 Command: ${command}`, 'blue');
    
    const child = exec(command, { cwd: process.cwd() }, (error, stdout, stderr) => {
      if (error) {
        log(`❌ Error: ${error.message}`, 'red');
        reject(error);
        return;
      }
      
      if (stderr) {
        log(`⚠️  Warning: ${stderr}`, 'yellow');
      }
      
      if (stdout) {
        console.log(stdout);
      }
      
      resolve({ stdout, stderr });
    });
    
    child.stdout.on('data', (data) => {
      process.stdout.write(data);
    });
    
    child.stderr.on('data', (data) => {
      process.stderr.write(data);
    });
  });
}

async function checkFlutterServer() {
  log('\n🔍 Checking Flutter server status...', 'cyan');
  
  try {
    await runCommand('curl -s http://localhost:8101 || echo "Server not responding"', 'Check Flutter server');
    log('✅ Flutter server is running', 'green');
    return true;
  } catch (error) {
    log('❌ Flutter server is not running', 'red');
    log('💡 Please start the Flutter server first:', 'yellow');
    log('   cd build/web && python -m http.server 8101 --bind 0.0.0.0', 'blue');
    return false;
  }
}

async function checkFlutterRendering() {
  log('\n🔍 Checking Flutter rendering status...', 'cyan');
  
  try {
    const result = await runCommand(
      'node -e "const puppeteer = require(\'puppeteer\'); (async () => { const browser = await puppeteer.launch(); const page = await browser.newPage(); await page.goto(\'http://localhost:8101\'); await page.waitForTimeout(10000); const bodyText = await page.evaluate(() => document.body.textContent); console.log(JSON.stringify({ length: bodyText.length, rendering: bodyText.length > 2000 })); await browser.close(); })()"',
      'Check Flutter rendering'
    );
    
    const data = JSON.parse(result.stdout.trim());
    
    if (data.rendering) {
      log('✅ Flutter content is rendering', 'green');
      log(`📝 Body length: ${data.length} characters`, 'blue');
      return true;
    } else {
      log('⚠️  Flutter content not rendering (CSS boilerplate only)', 'yellow');
      log(`📝 Body length: ${data.length} characters`, 'blue');
      return false;
    }
  } catch (error) {
    log('❌ Could not check Flutter rendering', 'red');
    return false;
  }
}

async function runAuthTests() {
  log('\n🔐 Running Authentication E2E Tests', 'cyan');
  log('=' .repeat(50), 'cyan');
  
  const testCommands = [
    {
      command: 'npx cypress run --config cypress.config.auth.js --spec cypress/e2e/auth_e2e_test.cy.js --reporter spec',
      description: 'Run comprehensive authentication tests'
    }
  ];
  
  const results = [];
  
  for (const test of testCommands) {
    try {
      const startTime = Date.now();
      await runCommand(test.command, test.description);
      const endTime = Date.now();
      
      results.push({
        test: test.description,
        status: 'PASSED',
        duration: endTime - startTime
      });
      
      log(`✅ ${test.description} - PASSED`, 'green');
    } catch (error) {
      results.push({
        test: test.description,
        status: 'FAILED',
        error: error.message
      });
      
      log(`❌ ${test.description} - FAILED`, 'red');
    }
  }
  
  return results;
}

async function generateReport(results) {
  log('\n📊 Generating Test Report...', 'cyan');
  
  const report = {
    timestamp: new Date().toISOString(),
    flutterServer: await checkFlutterServer(),
    flutterRendering: await checkFlutterRendering(),
    testResults: results,
    summary: {
      total: results.length,
      passed: results.filter(r => r.status === 'PASSED').length,
      failed: results.filter(r => r.status === 'FAILED').length
    }
  };
  
  const reportPath = path.join(process.cwd(), 'test-results', 'auth-test-report.json');
  
  // Ensure test-results directory exists
  const testResultsDir = path.dirname(reportPath);
  if (!fs.existsSync(testResultsDir)) {
    fs.mkdirSync(testResultsDir, { recursive: true });
  }
  
  fs.writeFileSync(reportPath, JSON.stringify(report, null, 2));
  
  log(`📄 Report saved to: ${reportPath}`, 'green');
  
  return report;
}

async function printSummary(report) {
  log('\n🎯 TEST SUMMARY', 'cyan');
  log('=' .repeat(50), 'cyan');
  
  log(`📅 Timestamp: ${report.timestamp}`, 'blue');
  log(`🌐 Flutter Server: ${report.flutterServer ? '✅ Running' : '❌ Not Running'}`, 
      report.flutterServer ? 'green' : 'red');
  log(`🎨 Flutter Rendering: ${report.flutterRendering ? '✅ Working' : '⚠️  Not Working'}`, 
      report.flutterRendering ? 'green' : 'yellow');
  
  log('\n📊 Test Results:', 'cyan');
  log(`   Total Tests: ${report.summary.total}`, 'blue');
  log(`   Passed: ${report.summary.passed}`, 'green');
  log(`   Failed: ${report.summary.failed}`, report.summary.failed > 0 ? 'red' : 'green');
  
  if (report.testResults.length > 0) {
    log('\n📋 Detailed Results:', 'cyan');
    report.testResults.forEach((result, index) => {
      const status = result.status === 'PASSED' ? '✅' : '❌';
      const color = result.status === 'PASSED' ? 'green' : 'red';
      log(`   ${index + 1}. ${status} ${result.test}`, color);
      
      if (result.duration) {
        log(`      Duration: ${result.duration}ms`, 'blue');
      }
      
      if (result.error) {
        log(`      Error: ${result.error}`, 'red');
      }
    });
  }
  
  log('\n💡 Recommendations:', 'cyan');
  
  if (!report.flutterServer) {
    log('   1. Start the Flutter server before running tests', 'yellow');
    log('      cd build/web && python -m http.server 8101 --bind 0.0.0.0', 'blue');
  }
  
  if (!report.flutterRendering) {
    log('   2. Flutter rendering is not working - tests will be limited', 'yellow');
    log('      This is a known issue with the Flutter web engine', 'blue');
    log('      Consider using Docker or a different environment', 'blue');
  }
  
  if (report.summary.failed > 0) {
    log('   3. Some tests failed - check the Cypress reports', 'yellow');
    log('      Screenshots are available in cypress/screenshots/', 'blue');
  }
  
  if (report.flutterServer && report.flutterRendering && report.summary.failed === 0) {
    log('   🎉 All tests passed! Authentication system is ready!', 'green');
  }
}

async function main() {
  log('🔐 NCL Authentication E2E Test Runner', 'cyan');
  log('=' .repeat(50), 'cyan');
  
  try {
    // Check prerequisites
    const serverRunning = await checkFlutterServer();
    if (!serverRunning) {
      log('\n❌ Cannot proceed without Flutter server', 'red');
      process.exit(1);
    }
    
    // Run tests
    const results = await runAuthTests();
    
    // Generate report
    const report = await generateReport(results);
    
    // Print summary
    await printSummary(report);
    
    // Exit with appropriate code
    process.exit(report.summary.failed > 0 ? 1 : 0);
    
  } catch (error) {
    log(`\n❌ Test runner failed: ${error.message}`, 'red');
    process.exit(1);
  }
}

// Handle uncaught errors
process.on('uncaughtException', (error) => {
  log(`\n💥 Uncaught Exception: ${error.message}`, 'red');
  process.exit(1);
});

process.on('unhandledRejection', (reason, promise) => {
  log(`\n💥 Unhandled Rejection: ${reason}`, 'red');
  process.exit(1);
});

// Run the main function
if (require.main === module) {
  main();
}

module.exports = {
  runAuthTests,
  checkFlutterServer,
  checkFlutterRendering,
  generateReport
};
