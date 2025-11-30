@echo off
setlocal enabledelayedexpansion

echo 🔧 Force Delete Flutter Folder
echo ================================

REM Check if folder exists
if not exist "C:\src\flutter" (
    echo ⚠️  Flutter folder not found at C:\src\flutter
    pause
    exit /b 0
)

echo 📁 Target folder: C:\src\flutter
echo.

REM Method 1: Kill all related processes
echo 🛑 Method 1: Killing all related processes...
taskkill /f /im flutter.exe 2>nul
taskkill /f /im dart.exe 2>nul
taskkill /f /im java.exe 2>nul
taskkill /f /im chrome.exe 2>nul
taskkill /f /im msedge.exe 2>nul
taskkill /f /im firefox.exe 2>nul
timeout /t 3 /nobreak >nul

REM Method 2: Stop Windows services that might lock files
echo 🛑 Method 2: Stopping Windows services...
net stop "Windows Search" 2>nul
net stop "Windows Indexer" 2>nul
timeout /t 2 /nobreak >nul

REM Method 3: Take ownership of the folder
echo 🔑 Method 3: Taking ownership...
takeown /f "C:\src\flutter" /r /d y 2>nul
icacls "C:\src\flutter" /grant administrators:F /t 2>nul
timeout /t 2 /nobreak >nul

REM Method 4: Unlock with handle.exe (if available)
echo 🔓 Method 4: Attempting to unlock files...
where handle.exe >nul 2>&1
if %errorlevel% equ 0 (
    echo Found handle.exe, unlocking files...
    handle.exe "C:\src\flutter" /accepteula >nul 2>&1
    for /f "tokens=2,3" %%a in ('handle.exe "C:\src\flutter" ^| findstr /i "pid:"') do (
        echo Killing process %%a (PID: %%b)
        taskkill /f /pid %%b 2>nul
    )
) else (
    echo handle.exe not found, skipping unlock method
)

REM Method 5: Rename first, then delete
echo 🔄 Method 5: Rename and delete strategy...
set "oldPath=C:\src\flutter"
set "newPath=C:\src\flutter_old_%random%"
if exist "%oldPath%" (
    echo Renaming to %newPath%...
    ren "%oldPath%" "flutter_old_%random%" 2>nul
    if exist "%newPath%" (
        echo ✅ Rename successful, deleting renamed folder...
        rmdir /s /q "%newPath%" 2>nul
        if exist "%newPath%" (
            echo ❌ Delete failed after rename
        ) else (
            echo ✅ Delete successful after rename
        )
    ) else (
        echo ❌ Rename failed
    )
)

REM Method 6: PowerShell force delete
echo 💪 Method 6: PowerShell force delete...
powershell -Command "try { Remove-Item 'C:\src\flutter' -Recurse -Force -ErrorAction Stop; Write-Host '✅ PowerShell delete successful' } catch { Write-Host '❌ PowerShell delete failed:' $_.Exception.Message }"

REM Method 7: Robocopy purge method (very aggressive)
echo 🗑️  Method 7: Robocopy purge method...
mkdir "%TEMP%\empty_folder" 2>nul
robocopy "%TEMP%\empty_folder" "C:\src\flutter" /purge /NFL /NDL /NJH /NJS /NC /NS /NP
rmdir "%TEMP%\empty_folder" 2>nul
rmdir /s /q "C:\src\flutter" 2>nul

REM Check final result
echo.
echo 🎯 Checking final result...
if exist "C:\src\flutter" (
    echo ❌ Flutter folder still exists
    echo.
    echo 🔍 Trying to identify what's locking it...
    
    REM Try to list open handles (if possible)
    powershell -Command "try { $handles = Get-Process | Where-Object { $_.MainModule.FileName -like '*flutter*' -or $_.ProcessName -like '*dart*' }; if ($handles) { $handles | ForEach-Object { Write-Host 'Process:' $_.ProcessName 'PID:' $_.Id }; } else { Write-Host 'No obvious Flutter processes found' } } catch { Write-Host 'Could not check processes:' $_.Exception.Message }"
    
    echo.
    echo 💡 Last resort options:
    echo 1. Restart computer and delete immediately after login
    echo 2. Use Safe Mode to delete
    echo 3. Use a third-party unlock tool like LockHunter
    echo 4. Delete from recovery environment
    echo.
    echo 🔧 Would you like me to prepare a restart script?
    
) else (
    echo ✅ SUCCESS: Flutter folder deleted successfully!
    echo.
    echo 🎉 Ready for fresh Flutter installation!
)

REM Restart services we stopped
echo 🔄 Restarting services...
net start "Windows Search" 2>nul
net start "Windows Indexer" 2>nul

echo.
echo ================================
echo ✅ Force delete operation complete
pause
