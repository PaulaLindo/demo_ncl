@echo off
echo 🔄 Restart and Delete Flutter Folder
echo ==================================

echo This script will:
echo 1. Schedule a task to delete Flutter folder on restart
echo 2. Restart your computer
echo 3. Delete the folder immediately after login
echo.

set /p confirm="Are you sure you want to restart? (y/n): "
if /i not "%confirm%"=="y" (
    echo Cancelled.
    pause
    exit /b 0
)

echo.
echo 🔧 Creating restart delete task...

REM Create a batch file to run on startup
set "deleteScript=%TEMP%\delete_flutter_on_restart.bat"
echo @echo off > "%deleteScript%"
echo echo 🗑️  Deleting Flutter folder after restart... >> "%deleteScript%"
echo timeout /t 10 /nobreak >> "%deleteScript%"
echo if exist "C:\src\flutter" ( >> "%deleteScript%"
echo     echo 📁 Found Flutter folder, deleting... >> "%deleteScript%"
echo     takeown /f "C:\src\flutter" /r /d y >> "%deleteScript%"
echo     icacls "C:\src\flutter" /grant administrators:F /t >> "%deleteScript%"
echo     rmdir /s /q "C:\src\flutter" >> "%deleteScript%"
echo     if exist "C:\src\flutter" ( >> "%deleteScript%"
echo         echo ❌ Delete failed >> "%deleteScript%"
echo     ) else ( >> "%deleteScript%"
echo         echo ✅ Flutter folder deleted successfully! >> "%deleteScript%"
echo     ) >> "%deleteScript%"
echo ) else ( >> "%deleteScript%"
echo     echo ⚠️  Flutter folder not found >> "%deleteScript%"
echo ) >> "%deleteScript%"
echo echo 🎉 Operation complete! >> "%deleteScript%"
echo timeout /t 5 >> "%deleteScript%"
echo del "%%~f0" >> "%deleteScript%"

REM Add to startup registry
reg add "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\RunOnce" /v "DeleteFlutter" /t REG_SZ /d "\"%deleteScript%\"" /f >nul 2>&1

if %errorlevel% equ 0 (
    echo ✅ Restart delete task created successfully
) else (
    echo ❌ Failed to create restart task
    pause
    exit /b 1
)

echo.
echo 🚀 Your computer will restart now...
echo 📁 The Flutter folder will be deleted automatically after restart
echo 💾 Save any important work before continuing
echo.

set /p final="Ready to restart? (y/n): "
if /i not "%final%"=="y" (
    echo Cancelled. Removing restart task...
    reg delete "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\RunOnce" /v "DeleteFlutter" /f >nul 2>&1
    echo Task removed.
    pause
    exit /b 0
)

echo 🔄 Restarting computer...
shutdown /r /t 10 /c "Restarting to delete Flutter folder"

echo.
echo ⏳ Computer will restart in 10 seconds...
echo 🎯 After restart, the Flutter folder will be automatically deleted
echo 📝 A command window will show the deletion progress
pause
