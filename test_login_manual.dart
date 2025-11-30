// test_login_manual.dart - Simple script to test login functionality
import 'package:demo_ncl/services/mock_data_service.dart';
import 'package:demo_ncl/providers/auth_provider.dart';
import 'package:demo_ncl/models/auth_model.dart';

void main() async {
  print('🧪 Testing Login Functionality...\n');
  
  // Initialize services
  final mockDataService = MockDataService();
  final authProvider = AuthProvider(mockDataService);
  
  // Test 1: Valid customer login
  print('📝 Test 1: Valid Customer Login');
  try {
    final result = await authProvider.login(
      email: 'customer@example.com',
      password: 'customer123',
    );
    
    if (result && authProvider.isAuthenticated) {
      print('✅ SUCCESS: Customer login works');
      print('   Email: ${authProvider.currentUser?.email}');
      print('   Role: ${authProvider.currentUser?.role}');
      print('   Password removed: ${authProvider.currentUser?.password == null ? "Yes" : "No"}');
    } else {
      print('❌ FAILED: Customer login failed');
      print('   Error: ${authProvider.errorMessage}');
    }
  } catch (e) {
    print('❌ ERROR: $e');
  }
  
  print('\n' + '='*50 + '\n');
  
  // Test 2: Valid staff login
  print('📝 Test 2: Valid Staff Login');
  await authProvider.logout(); // Reset
  
  try {
    final result = await authProvider.login(
      email: 'staff@example.com',
      password: 'staff123',
    );
    
    if (result && authProvider.isAuthenticated) {
      print('✅ SUCCESS: Staff login works');
      print('   Email: ${authProvider.currentUser?.email}');
      print('   Role: ${authProvider.currentUser?.role}');
      print('   Password removed: ${authProvider.currentUser?.password == null ? "Yes" : "No"}');
    } else {
      print('❌ FAILED: Staff login failed');
      print('   Error: ${authProvider.errorMessage}');
    }
  } catch (e) {
    print('❌ ERROR: $e');
  }
  
  print('\n' + '='*50 + '\n');
  
  // Test 3: Valid admin login
  print('📝 Test 3: Valid Admin Login');
  await authProvider.logout(); // Reset
  
  try {
    final result = await authProvider.login(
      email: 'admin@example.com',
      password: 'admin123',
    );
    
    if (result && authProvider.isAuthenticated) {
      print('✅ SUCCESS: Admin login works');
      print('   Email: ${authProvider.currentUser?.email}');
      print('   Role: ${authProvider.currentUser?.role}');
      print('   Password removed: ${authProvider.currentUser?.password == null ? "Yes" : "No"}');
    } else {
      print('❌ FAILED: Admin login failed');
      print('   Error: ${authProvider.errorMessage}');
    }
  } catch (e) {
    print('❌ ERROR: $e');
  }
  
  print('\n' + '='*50 + '\n');
  
  // Test 4: Invalid password
  print('📝 Test 4: Invalid Password');
  await authProvider.logout(); // Reset
  
  try {
    final result = await authProvider.login(
      email: 'customer@example.com',
      password: 'wrongpassword',
    );
    
    if (!result && !authProvider.isAuthenticated) {
      print('✅ SUCCESS: Invalid password correctly rejected');
      print('   Error message: ${authProvider.errorMessage}');
    } else {
      print('❌ FAILED: Should have rejected invalid password');
    }
  } catch (e) {
    print('❌ ERROR: $e');
  }
  
  print('\n' + '='*50 + '\n');
  
  // Test 5: Non-existent user
  print('📝 Test 5: Non-existent User');
  await authProvider.logout(); // Reset
  
  try {
    final result = await authProvider.login(
      email: 'nonexistent@example.com',
      password: 'password123',
    );
    
    if (!result && !authProvider.isAuthenticated) {
      print('✅ SUCCESS: Non-existent user correctly rejected');
      print('   Error message: ${authProvider.errorMessage}');
    } else {
      print('❌ FAILED: Should have rejected non-existent user');
    }
  } catch (e) {
    print('❌ ERROR: $e');
  }
  
  print('\n' + '='*50 + '\n');
  
  // Test 6: Direct MockDataService test
  print('📝 Test 6: Direct MockDataService Test');
  
  try {
    // Test valid user
    final validResult = await mockDataService.authenticateUser(
      'customer@example.com',
      'customer123',
    );
    
    if (validResult.isSuccess) {
      print('✅ SUCCESS: MockDataService authenticates valid user');
      print('   User email: ${validResult.user?.email}');
      print('   Password removed: ${validResult.user?.password == null ? "Yes" : "No"}');
    } else {
      print('❌ FAILED: MockDataService failed valid user');
      print('   Error: ${validResult.error}');
    }
    
    // Test invalid password
    final invalidResult = await mockDataService.authenticateUser(
      'customer@example.com',
      'wrongpassword',
    );
    
    if (!invalidResult.isSuccess) {
      print('✅ SUCCESS: MockDataService rejects invalid password');
      print('   Error: ${invalidResult.error}');
    } else {
      print('❌ FAILED: MockDataService should reject invalid password');
    }
    
    // Test non-existent user
    final nonExistentResult = await mockDataService.authenticateUser(
      'nonexistent@example.com',
      'password123',
    );
    
    if (!nonExistentResult.isSuccess) {
      print('✅ SUCCESS: MockDataService rejects non-existent user');
      print('   Error: ${nonExistentResult.error}');
    } else {
      print('❌ FAILED: MockDataService should reject non-existent user');
    }
    
  } catch (e) {
    print('❌ ERROR: $e');
  }
  
  // Clean up
  authProvider.dispose();
  
  print('\n🎉 Login testing complete!');
}
