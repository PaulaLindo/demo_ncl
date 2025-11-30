@echo off
echo 🚀 Setting up ChromeDriver for Flutter UI Testing...

REM Check if chromedriver exists
if exist "chromedriver.exe" (
    echo ✅ ChromeDriver already exists
    goto :run_tests
)

echo 📥 Downloading ChromeDriver...
powershell -Command "& {Invoke-WebRequest -Uri 'https://storage.googleapis.com/chrome-for-testing-public/119.0.6045.105/win64/chromedriver-win64.zip' -OutFile 'chromedriver.zip'}"

echo 📦 Extracting ChromeDriver...
powershell -Command "& {Add-Type -AssemblyName System.IO.Compression.FileSystem; [System.IO.Compression.ZipFile]::ExtractToDirectory('chromedriver.zip', '.')}"

echo 🧹 Cleaning up...
del chromedriver.zip

echo ✅ ChromeDriver setup complete!

:run_tests
echo 🌐 Starting ChromeDriver on port 4444...
start /B chromedriver.exe --port=4444

echo ⏳ Waiting for ChromeDriver to start...
timeout /t 3 /nobreak >nul

echo 🎯 Running Flutter E2E tests with ChromeDriver...
flutter drive --target=lib/main.dart --driver=test_driver/appium_e2e_test.dart

echo 🛑 Stopping ChromeDriver...
taskkill /f /im chromedriver.exe >nul 2>&1

echo ✅ Testing complete!
pause
