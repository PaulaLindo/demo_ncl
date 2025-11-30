@echo off
REM Simple Flutter Reinstall Script
echo 🔧 Flutter Reinstall Script
echo ================================

REM Step 1: Stop Flutter processes
echo.
echo 🛑 Stopping Flutter processes...
taskkill /f /im flutter.exe 2>nul
taskkill /f /im dart.exe 2>nul
echo ✅ Flutter processes stopped

REM Step 2: Remove Flutter from user PATH
echo.
echo 🗑️  Removing Flutter from PATH...
for /f "tokens=*" %%i in ('reg query "HKEY_CURRENT_USER\Environment" /v PATH 2^>nul') do set oldpath=%%i
set oldpath=%oldpath:*\=%
set oldpath=%oldpath:* =%
set newpath=%oldpath%
:loop
for /f "tokens=1,* delims=;" %%a in ("%newpath%") do (
    if /i "%%a"=="C:\src\flutter\bin" (
        set newpath=%%b
        goto loop
    )
    if /i "%%a"=="C:\flutter\bin" (
        set newpath=%%b
        goto loop
    )
    if /i "%%a"=="flutter\bin" (
        set newpath=%%b
        goto loop
    )
    set "newpath=%%a;%%b"
    goto loop
)
reg add "HKEY_CURRENT_USER\Environment" /v PATH /t REG_EXPAND_SZ /d "%newpath%" /f >nul 2>&1
echo ✅ Flutter removed from user PATH

REM Step 3: Remove Flutter installation
echo.
echo 🗑️  Removing Flutter installation...
if exist "C:\src\flutter" (
    echo 📁 Removing C:\src\flutter...
    rmdir /s /q "C:\src\flutter" 2>nul
    echo ✅ Flutter installation removed
) else (
    echo ⚠️  Flutter installation not found at C:\src\flutter
)

if exist "C:\flutter" (
    echo 📁 Removing C:\flutter...
    rmdir /s /q "C:\flutter" 2>nul
    echo ✅ Flutter installation removed
) else (
    echo ⚠️  Flutter installation not found at C:\flutter
)

REM Step 4: Clean up caches
echo.
echo 🧹 Cleaning up Flutter caches...
if exist "%LOCALAPPDATA%\Pub\Cache" (
    rmdir /s /q "%LOCALAPPDATA%\Pub\Cache" 2>nul
    echo ✅ Pub cache cleaned
)
if exist "%APPDATA%\flutter" (
    rmdir /s /q "%APPDATA%\flutter" 2>nul
    echo ✅ Flutter app data cleaned
)
if exist "%USERPROFILE%\.flutter-plugins" (
    del "%USERPROFILE%\.flutter-plugins" 2>nul
    del "%USERPROFILE%\.flutter-plugins-dependencies" 2>nul
    echo ✅ Flutter plugins cleaned
)

REM Step 5: Download and install fresh Flutter
echo.
echo 📥 Downloading fresh Flutter...
set "flutterUrl=https://storage.googleapis.com/flutter_infra_release/releases/stable/windows/flutter_windows_3.38.3-stable.zip"
set "zipPath=%TEMP%\flutter.zip"
set "installPath=C:\src"

echo 📥 Downloading from: %flutterUrl%
powershell -Command "Invoke-WebRequest -Uri '%flutterUrl%' -OutFile '%zipPath%' -UseBasicParsing"

if exist "%zipPath%" (
    echo ✅ Flutter downloaded successfully
    
    if not exist "%installPath%" mkdir "%installPath%"
    
    echo 📦 Extracting Flutter...
    powershell -Command "Expand-Archive -Path '%zipPath%' -DestinationPath '%installPath%' -Force"
    
    del "%zipPath%"
    echo ✅ Flutter extracted successfully
) else (
    echo ❌ Failed to download Flutter
    pause
    exit /b 1
)

REM Step 6: Add Flutter to PATH
echo.
echo 🔗 Adding Flutter to PATH...
set "flutterBin=%installPath%\flutter\bin"
reg add "HKEY_CURRENT_USER\Environment" /v PATH /t REG_EXPAND_SZ /d "%PATH%;%flutterBin%" /f >nul 2>&1
echo ✅ Flutter added to PATH

REM Step 7: Configure Flutter
echo.
echo ⚙️  Configuring Flutter...
cd /d "c:\dev\demo_ncl"

echo 🧹 Running flutter clean...
"%flutterBin%\flutter.bat" clean

echo 📦 Running flutter pub get...
"%flutterBin%\flutter.bat" pub get

echo 🔧 Running flutter doctor...
"%flutterBin%\flutter.bat" doctor

echo 🎉 Flutter reinstall complete!
echo ================================
echo.
echo 📋 Summary:
echo ✅ Old Flutter installation removed
echo ✅ Fresh Flutter 3.38.3 installed
echo ✅ Flutter added to PATH
echo ✅ Project dependencies updated
echo.
echo 🚀 Next steps:
echo 1. Close this window and open a new terminal
echo 2. Run: flutter run -d web-server
echo 3. Test your authentication system
echo.
pause
