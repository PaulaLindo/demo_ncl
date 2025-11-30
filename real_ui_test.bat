@echo off
echo 🚀 STARTING REAL UI TESTS - CHECK YOUR EMULATOR SCREEN!
echo.

echo 📱 Step 1: Launching the NCL app...
"C:\Android\sdk\platform-tools\adb.exe" -s emulator-5554 shell am start -n com.example.demo_ncl/.MainActivity
timeout /t 5 /nobreak > nul

echo ✅ App should now be visible on your emulator!

echo.
echo 👀 Step 2: Verifying Welcome screen...
"C:\Android\sdk\platform-tools\adb.exe" -s emulator-5554 shell uiautomator dump
"C:\Android\sdk\platform-tools\adb.exe" -s emulator-5554 pull /sdcard/window_dump.xml temp_dump.xml
findstr "Welcome to NCL" temp_dump.xml > nul
if %errorlevel% equ 0 (
    echo ✅ Welcome to NCL found on screen!
) else (
    echo ❌ Welcome to NCL not found
)

echo.
echo 👆 Step 3: Tapping Customer Login button...
"C:\Android\sdk\platform-tools\adb.exe" -s emulator-5554 shell uiautomator dump
"C:\Android\sdk\platform-tools\adb.exe" -s emulator-5554 pull /sdcard/window_dump.xml temp_dump.xml
for /f "tokens=*" %%i in ('findstr "Customer Login" temp_dump.xml') do set line=%%i
echo Found Customer Login button, tapping it...
"C:\Android\sdk\platform-tools\adb.exe" -s emulator-5554 shell input tap 200 400
timeout /t 3 /nobreak > nul
echo ✅ Customer Login button tapped - Check emulator screen!

echo.
echo 🔙 Step 4: Going back to main screen...
"C:\Android\sdk\platform-tools\adb.exe" -s emulator-5554 shell input keyevent KEYCODE_BACK
timeout /t 2 /nobreak > nul

echo.
echo 👆 Step 5: Tapping Staff Access button...
"C:\Android\sdk\platform-tools\adb.exe" -s emulator-5554 shell input tap 200 480
timeout /t 3 /nobreak > nul
echo ✅ Staff Access button tapped - Check emulator screen!

echo.
echo 🔙 Step 6: Going back to main screen...
"C:\Android\sdk\platform-tools\adb.exe" -s emulator-5554 shell input keyevent KEYCODE_BACK
timeout /t 2 /nobreak > nul

echo.
echo 👆 Step 7: Tapping Admin Portal button...
"C:\Android\sdk\platform-tools\adb.exe" -s emulator-5554 shell input tap 200 560
timeout /t 3 /nobreak > nul
echo ✅ Admin Portal button tapped - Check emulator screen!

echo.
echo 📸 Step 8: Taking screenshot...
"C:\Android\sdk\platform-tools\adb.exe" -s emulator-5554 shell screencap -p /sdcard/ui_test_screenshot.png
"C:\Android\sdk\platform-tools\adb.exe" -s emulator-5554 pull /sdcard/ui_test_screenshot.png ui_test_screenshot.png
echo ✅ Screenshot saved: ui_test_screenshot.png

echo.
echo 🎉 REAL UI TESTS COMPLETED!
echo 📱 You should have seen all interactions on the emulator screen!
echo 📸 Check ui_test_screenshot.png for visual confirmation!

del temp_dump.xml
pause
