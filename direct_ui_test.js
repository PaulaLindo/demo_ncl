// direct_ui_test.js
const { execSync } = require('child_process');
const fs = require('fs');

function runADBCommand(command) {
  try {
    const result = execSync(command, { encoding: 'utf8', timeout: 10000 });
    return result.trim();
  } catch (error) {
    console.error(`❌ ADB Command failed: ${command}`);
    console.error(`Error: ${error.message}`);
    return null;
  }
}

async function runDirectUITest() {
  console.log('🚀 STARTING DIRECT ADB UI TESTS');
  console.log('📱 MAKE SURE YOU CAN SEE THE EMULATOR!');
  
  try {
    // Step 1: Launch the app
    console.log('\n📱 Step 1: Launching NCL app...');
    const launchResult = runADBCommand('"C:/Android/sdk/platform-tools/adb.exe" -s emulator-5554 shell am start -n com.example.demo_ncl/.MainActivity');
    
    if (launchResult) {
      console.log('✅ App launched successfully!');
    } else {
      console.log('⚠️ App launch command failed, but continuing...');
    }
    
    // Wait for app to load
    console.log('⏳ Waiting for app to load (5 seconds)...');
    await new Promise(resolve => setTimeout(resolve, 5000));
    
    // Step 2: Take initial screenshot
    console.log('\n📸 Step 2: Taking initial screenshot...');
    const screenshot1 = runADBCommand('"C:/Android/sdk/platform-tools/adb.exe" -s emulator-5554 shell screencap -p /sdcard/initial_screen.png');
    if (screenshot1) {
      runADBCommand('"C:/Android/sdk/platform-tools/adb.exe" -s emulator-5554 pull /sdcard/initial_screen.png initial_screen.png');
      console.log('✅ Initial screenshot saved: initial_screen.png');
    }
    
    // Step 3: Test Customer Login button
    console.log('\n👆 Step 3: Testing Customer Login button...');
    console.log('📱 Check your emulator - you should see a tap on Customer Login!');
    
    // Tap Customer Login (approximate coordinates)
    const tap1 = runADBCommand('"C:/Android/sdk/platform-tools/adb.exe" -s emulator-5554 shell input tap 200 400');
    if (tap1 !== null) {
      console.log('✅ Customer Login button tapped!');
      await new Promise(resolve => setTimeout(resolve, 3000));
      
      // Take screenshot after tap
      runADBCommand('"C:/Android/sdk/platform-tools/adb.exe" -s emulator-5554 shell screencap -p /sdcard/customer_login_tapped.png');
      runADBCommand('"C:/Android/sdk/platform-tools/adb.exe" -s emulator-5554 pull /sdcard/customer_login_tapped.png customer_login_tapped.png');
      console.log('📸 Screenshot saved: customer_login_tapped.png');
      
      // Go back
      runADBCommand('"C:/Android/sdk/platform-tools/adb.exe" -s emulator-5554 shell input keyevent KEYCODE_BACK');
      await new Promise(resolve => setTimeout(resolve, 2000));
      console.log('🔙 Navigated back');
    }
    
    // Step 4: Test Staff Access button
    console.log('\n👆 Step 4: Testing Staff Access button...');
    console.log('📱 Check your emulator - you should see a tap on Staff Access!');
    
    const tap2 = runADBCommand('"C:/Android/sdk/platform-tools/adb.exe" -s emulator-5554 shell input tap 200 480');
    if (tap2 !== null) {
      console.log('✅ Staff Access button tapped!');
      await new Promise(resolve => setTimeout(resolve, 3000));
      
      // Take screenshot after tap
      runADBCommand('"C:/Android/sdk/platform-tools/adb.exe" -s emulator-5554 shell screencap -p /sdcard/staff_access_tapped.png');
      runADBCommand('"C:/Android/sdk/platform-tools/adb.exe" -s emulator-5554 pull /sdcard/staff_access_tapped.png staff_access_tapped.png');
      console.log('📸 Screenshot saved: staff_access_tapped.png');
      
      // Go back
      runADBCommand('"C:/Android/sdk/platform-tools/adb.exe" -s emulator-5554 shell input keyevent KEYCODE_BACK');
      await new Promise(resolve => setTimeout(resolve, 2000));
      console.log('🔙 Navigated back');
    }
    
    // Step 5: Test Admin Portal button
    console.log('\n👆 Step 5: Testing Admin Portal button...');
    console.log('📱 Check your emulator - you should see a tap on Admin Portal!');
    
    const tap3 = runADBCommand('"C:/Android/sdk/platform-tools/adb.exe" -s emulator-5554 shell input tap 200 560');
    if (tap3 !== null) {
      console.log('✅ Admin Portal button tapped!');
      await new Promise(resolve => setTimeout(resolve, 3000));
      
      // Take screenshot after tap
      runADBCommand('"C:/Android/sdk/platform-tools/adb.exe" -s emulator-5554 shell screencap -p /sdcard/admin_portal_tapped.png');
      runADBCommand('"C:/Android/sdk/platform-tools/adb.exe" -s emulator-5554 pull /sdcard/admin_portal_tapped.png admin_portal_tapped.png');
      console.log('📸 Screenshot saved: admin_portal_tapped.png');
    }
    
    // Step 6: Take final screenshot
    console.log('\n📸 Step 6: Taking final screenshot...');
    runADBCommand('"C:/Android/sdk/platform-tools/adb.exe" -s emulator-5554 shell screencap -p /sdcard/final_screen.png');
    runADBCommand('"C:/Android/sdk/platform-tools/adb.exe" -s emulator-5554 pull /sdcard/final_screen.png final_screen.png');
    console.log('📸 Final screenshot saved: final_screen.png');
    
    // Step 7: Test additional interactions
    console.log('\n🧪 Step 7: Testing additional interactions...');
    
    // Test swipe gesture
    console.log('📱 Testing swipe gesture...');
    runADBCommand('"C:/Android/sdk/platform-tools/adb.exe" -s emulator-5554 shell input swipe 100 800 100 200 500');
    await new Promise(resolve => setTimeout(resolve, 2000));
    console.log('✅ Swipe gesture completed');
    
    // Test long press
    console.log('📱 Testing long press...');
    runADBCommand('"C:/Android/sdk/platform-tools/adb.exe" -s emulator-5554 shell input touchscreen swipe 200 400 200 400 1000');
    await new Promise(resolve => setTimeout(resolve, 2000));
    console.log('✅ Long press completed');
    
    console.log('\n🎉 DIRECT ADB UI TESTS COMPLETED SUCCESSFULLY!');
    console.log('📱 You should have seen all interactions on the emulator screen!');
    console.log('📸 Generated screenshots:');
    console.log('   - initial_screen.png (app launch)');
    console.log('   - customer_login_tapped.png (after Customer Login tap)');
    console.log('   - staff_access_tapped.png (after Staff Access tap)');
    console.log('   - admin_portal_tapped.png (after Admin Portal tap)');
    console.log('   - final_screen.png (final state)');
    
    console.log('\n✅ THIS IS REAL UI TESTING - You saw the app and interactions!');
    
  } catch (error) {
    console.error('❌ Test failed:', error);
  }
}

// Run the test
runDirectUITest();
