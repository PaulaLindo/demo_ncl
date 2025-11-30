@echo off
echo 📅 Schedule Flutter Folder Deletion
echo ==================================

echo This will schedule the Flutter folder to be deleted in 2 minutes...
echo.

REM Create a delayed deletion script
set "delayedScript=%TEMP%\delayed_delete_flutter.bat"
echo @echo off > "%delayedScript%"
echo echo 🗑️  Scheduled Flutter folder deletion... >> "%delayedScript%"
echo timeout /t 120 /nobreak >> "%delayedScript%"
echo echo 📁 Time to delete Flutter folder... >> "%delayedScript%"
echo cd /d C:\src >> "%delayedScript%"
echo if exist "flutter" ( >> "%delayedScript%"
echo     echo 📁 Flutter folder found, attempting deletion... >> "%delayedScript%"
echo     takeown /f flutter /r /d y >> "%delayedScript%"
echo     icacls flutter /grant administrators:F /t >> "%delayedScript%"
echo     rmdir /s /q flutter >> "%delayedScript%"
echo     if exist "flutter" ( >> "%delayedScript%"
echo         echo ❌ Delete failed, trying alternative method... >> "%delayedScript%"
echo         ren flutter flutter_old_%%random%% >> "%delayedScript%"
echo         rmdir /s /q flutter_old_* 2^>nul >> "%delayedScript%"
echo         if exist "flutter" ( >> "%delayedScript%"
echo             echo ❌ All deletion methods failed >> "%delayedScript%"
echo         ) else ( >> "%delayedScript%"
echo             echo ✅ Flutter folder deleted (renamed method) >> "%delayedScript%"
echo         ) >> "%delayedScript%"
echo     ) else ( >> "%delayedScript%"
echo         echo ✅ Flutter folder deleted successfully! >> "%delayedScript%"
echo     ) >> "%delayedScript%"
echo ) else ( >> "%delayedScript%"
echo     echo ⚠️  Flutter folder not found >> "%delayedScript%"
echo ) >> "%delayedScript%"
echo echo 🎉 Scheduled deletion complete! >> "%delayedScript%"
echo del "%%~f0" >> "%delayedScript%"

REM Schedule the task
schtasks /create /tn "DeleteFlutter" /tr "\"%delayedScript%\"" /sc once /st >nul 2>&1

if %errorlevel% equ 0 (
    echo ✅ Deletion task scheduled successfully
    echo 📅 The Flutter folder will be deleted in 2 minutes
    echo 💾 You can continue working or close this window
    echo 📝 A command window will appear when deletion starts
    echo.
    echo 💡 To cancel the scheduled task, run:
    echo    schtasks /delete /tn "DeleteFlutter" /f
) else (
    echo ❌ Failed to schedule deletion task
    echo 💡 You may need to run this as Administrator
)

echo.
echo 📊 Current status:
dir "C:\src\flutter" >nul 2>&1
if %errorlevel% equ 0 (
    echo 📁 Flutter folder still exists
    echo ⏰ Will be deleted in 2 minutes
) else (
    echo 📁 Flutter folder not found
)

echo.
pause
