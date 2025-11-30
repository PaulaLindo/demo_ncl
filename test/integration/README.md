# NCL Integration Test Suite

This directory contains comprehensive end-to-end integration tests for the NCL (Natal Cleaning Services) Flutter application, covering all three user roles: Admin, Customer, and Staff.

## 🎯 Test Coverage

### Critical Integration Test Cases (ITC)
- ✅ **ITC 5.1**: Schedule-to-Job Assignment Flow (Hotel Sync → Scheduler → Staff App)
- ✅ **ITC 5.2**: Managed Logistics to Punctuality (Scheduler → Uber API → Live Tracking → Admin Dashboard)
- ✅ **ITC 5.3**: Quality-Gated Payroll Integration (Digital Checklist → Clock-Out → Payroll Module)
- ✅ **ITC 5.4**: Fixed-Price Quote to Billing (Dynamic Quoting → Booking Confirmation → Client Invoice)
- ✅ **ITC 5.5**: Proxy Shift to Payroll Audit Trail (Temp Card → Staff Approval → Payroll Report)
- ✅ **ITC 5.6**: Training Completion to Job Eligibility (Training Tracker → Staff Profile → Scheduler)

### Admin Flows
- ✅ Hotel Partner Onboarding
- ✅ Continuous Quality Assurance  
- ✅ Staff Empowerment & Retention
- ✅ B2B Lead Management
- ✅ Temp Card Management

### Customer Flows
- ✅ Customer Registration
- ✅ Service Category Selection
- ✅ Scope Definition & Fixed Pricing
- ✅ Scheduling & Confirmation
- ✅ Staff Vetting Transparency
- ✅ Post-Service Experience
- ✅ Subscription Management

### Staff Flows
- ✅ Availability Management
- ✅ Job Offer & Acceptance
- ✅ Pre-Shift Transport (Uber Integration)
- ✅ On-Site Service Execution
- ✅ Post-Shift Transport
- ✅ Timekeeping with Geofencing

## 🚀 Running Tests

### Prerequisites
1. Ensure Flutter is installed and configured
2. Set up an emulator or physical device
3. Install dependencies:
   ```bash
   flutter pub get
   ```

### Run All Tests
```bash
# Run all integration tests
flutter test integration_test/

# Or use the test runner
dart test/integration/test_runner.dart
```

### Run Specific Test Suites
```bash
# Critical integration tests only
flutter test integration_test/critical_integration_tests.dart

# App tests only
flutter test integration_test/app_test.dart

# Staff flow tests only
flutter test integration_test/staff_flows_test.dart

# Customer flow tests only
flutter test integration_test/customer_flows_test.dart

# Admin flow tests only
flutter test integration_test/admin_flows_test.dart
```

### Run on Specific Device
```bash
# List available devices
flutter devices

# Run on specific device
flutter test integration_test/ -d <device_id>
```

## 📱 Test Data & Mocking

### Mock Services
- **Firebase Auth**: `MockFirebaseAuth` for authentication testing
- **Firestore**: `FakeFirebaseFirestore` for database operations
- **Network Images**: `network_image_mock` for image loading tests

### Test Users
```dart
// Staff
email: staff@example.com
password: staff123

// Customer  
email: customer@example.com
password: customer123

// Admin
email: admin@example.com
password: admin123
```

### Mock Data Structure
- Test users with all roles
- Sample jobs and bookings
- Hotel partner data
- Temp card scenarios
- B2B lead data

## 🔧 Test Configuration

### Test Config File
`test/test_config.dart` contains:
- Test user credentials
- Mock data generators
- Helper methods for common operations
- Test environment setup/cleanup

### Key Features
- **Automatic Test Environment Setup**
- **Mock Data Generation**
- **Helper Methods for Common Operations**
- **Test Cleanup**
- **Error Handling**

## 📊 Test Results

### Expected Test Count
- **App Tests**: 3 tests
- **Staff Flow Tests**: 6 tests  
- **Customer Flow Tests**: 6 tests
- **Admin Flow Tests**: 5 tests
- **Total**: 20 integration tests

### Success Criteria
- All tests should pass ✅
- No critical errors in app functionality
- All user journeys complete successfully
- Mock data behaves correctly

## 🐛 Debugging Failed Tests

### Common Issues
1. **Device Connection**: Ensure emulator/device is running
2. **Network Issues**: Mock services should handle offline scenarios
3. **Timing Issues**: Use `pumpAndSettle()` with appropriate durations
4. **Widget Finding**: Use proper keys and widget types

### Debugging Tips
```bash
# Run with verbose output
flutter test integration_test/ --verbose

# Run specific test with debugging
flutter test integration_test/app_test.dart --verbose

# Run on device with logs
flutter test integration_test/ -d <device_id> --verbose
```

### Test Debugging
```dart
// Add debugging prints in tests
print('Current widget tree: ${tester.widget(find.byType(MaterialApp))}');

// Take screenshots for failed tests
await takeScreenshot(tester, 'test_name');
```

## 🔄 Continuous Integration

### GitHub Actions Setup
```yaml
# Example CI configuration
- name: Run Integration Tests
  run: |
    flutter pub get
    flutter test integration_test/
```

### Test Reports
- Test results are automatically summarized
- Failed tests provide detailed error messages
- Coverage reports can be generated

## 📝 Adding New Tests

### Test Structure
```dart
testWidgets('Test Description', (WidgetTester tester) async {
  // 1. Setup test environment
  await _setupTest();
  
  // 2. Execute test actions
  await tester.tap(find.text('Button'));
  await tester.pumpAndSettle();
  
  // 3. Verify results
  expect(find.text('Expected Text'), findsOneWidget);
});
```

### Best Practices
1. **Descriptive Test Names**: Clear, specific test descriptions
2. **Setup/Teardown**: Use `setUp` and `tearDown` methods
3. **Mock Data**: Use `TestConfig` for consistent test data
4. **Assertions**: Verify both positive and negative cases
5. **Documentation**: Comment complex test scenarios

## 🚨 Important Notes

### Test Environment
- Tests use mock Firebase services
- No real database connections
- Network calls are mocked
- Images are mocked

### Data Persistence
- Test data is isolated
- No impact on production data
- Automatic cleanup after tests
- Fresh data for each test run

### Performance
- Tests run in sequence
- Each test cleans up after itself
- Device state is reset between tests
- Memory usage is monitored

## 📞 Support

For issues with the integration test suite:

1. Check Flutter doctor: `flutter doctor -v`
2. Verify device connection: `flutter devices`
3. Clean and rebuild: `flutter clean && flutter pub get`
4. Review test logs for specific error messages

## 🔄 Maintenance

### Regular Updates
- Update test dependencies in `pubspec.yaml`
- Review and update mock data
- Add tests for new features
- Remove deprecated tests

### Test Health
- Monitor test execution time
- Check test reliability
- Update test data as needed
- Maintain test documentation
