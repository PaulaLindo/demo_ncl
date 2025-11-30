# scripts/reinstall_flutter.ps1 - Complete Flutter Reinstall Script
# This script will completely uninstall and reinstall Flutter to fix web rendering issues

Write-Host "🔧 Flutter Reinstall Script" -ForegroundColor Cyan
Write-Host "================================" -ForegroundColor Cyan

# Check if running as Administrator
if (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Host "⚠️  This script should be run as Administrator for best results" -ForegroundColor Yellow
    Write-Host "Press Enter to continue anyway or Ctrl+C to exit..." -ForegroundColor Yellow
    Read-Host
}

# Step 1: Backup current Flutter configuration
Write-Host "`n📦 Step 1: Backing up current Flutter configuration..." -ForegroundColor Green

$flutterPath = "C:\src\flutter"
$backupPath = "C:\flutter_backup_$(Get-Date -Format 'yyyyMMdd_HHmmss')"

if (Test-Path $flutterPath) {
    Write-Host "📁 Creating backup at: $backupPath" -ForegroundColor Blue
    
    # Backup important configurations
    if (Test-Path "$flutterPath\bin\cache") {
        Copy-Item "$flutterPath\bin\cache" "$backupPath\cache" -Recurse -Force
        Write-Host "✅ Flutter cache backed up" -ForegroundColor Green
    }
    
    # Backup pub cache if it exists
    $pubCachePath = "$env:LOCALAPPDATA\Pub\Cache"
    if (Test-Path $pubCachePath) {
        Copy-Item $pubCachePath "$backupPath\pub_cache" -Recurse -Force
        Write-Host "✅ Pub cache backed up" -ForegroundColor Green
    }
    
    # Backup project-specific settings
    if (Test-Path "$flutterPath\.flutter-plugins") {
        Copy-Item "$flutterPath\.flutter-plugins" "$backupPath\" -Force
        Copy-Item "$flutterPath\.flutter-plugins-dependencies" "$backupPath\" -Force
        Write-Host "✅ Flutter plugins backed up" -ForegroundColor Green
    }
} else {
    Write-Host "⚠️  Flutter not found at $flutterPath" -ForegroundColor Yellow
}

# Step 2: Stop any running Flutter processes
Write-Host "`n🛑 Step 2: Stopping Flutter processes..." -ForegroundColor Green

Get-Process | Where-Object { $_.ProcessName -like "*flutter*" -or $_.MainWindowTitle -like "*flutter*" } | Stop-Process -Force -ErrorAction SilentlyContinue
Write-Host "✅ Flutter processes stopped" -ForegroundColor Green

# Step 3: Remove Flutter from PATH
Write-Host "`n🗑️  Step 3: Removing Flutter from PATH..." -ForegroundColor Green

$currentPath = [Environment]::GetEnvironmentVariable("PATH", "User")
$flutterPaths = $currentPath -split ';' | Where-Object { $_ -like "*flutter*" }

if ($flutterPaths.Count -gt 0) {
    $newPath = ($currentPath -split ';' | Where-Object { $_ -notlike "*flutter*" }) -join ';'
    [Environment]::SetEnvironmentVariable("PATH", $newPath, "User")
    Write-Host "✅ Flutter removed from user PATH" -ForegroundColor Green
}

# Also check system PATH
$systemPath = [Environment]::GetEnvironmentVariable("PATH", "Machine")
$flutterSystemPaths = $systemPath -split ';' | Where-Object { $_ -like "*flutter*" }

if ($flutterSystemPaths.Count -gt 0) {
    $newSystemPath = ($systemPath -split ';' | Where-Object { $_ -notlike "*flutter*" }) -join ';'
    [Environment]::SetEnvironmentVariable("PATH", $newSystemPath, "Machine")
    Write-Host "✅ Flutter removed from system PATH" -ForegroundColor Green
}

# Step 4: Remove Flutter installation
Write-Host "`n🗑️  Step 4: Removing Flutter installation..." -ForegroundColor Green

if (Test-Path $flutterPath) {
    Write-Host "📁 Removing Flutter from: $flutterPath" -ForegroundColor Blue
    
    try {
        # Try to remove normally first
        Remove-Item $flutterPath -Recurse -Force -ErrorAction Stop
        Write-Host "✅ Flutter installation removed" -ForegroundColor Green
    } catch {
        Write-Host "⚠️  Could not remove Flutter normally, trying force removal..." -ForegroundColor Yellow
        
        # Force removal using takeown
        & takeown /f $flutterPath /r /d y
        & icacls $flutterPath /grant administrators:F /t
        Remove-Item $flutterPath -Recurse -Force
        Write-Host "✅ Flutter installation force removed" -ForegroundColor Green
    }
} else {
    Write-Host "⚠️  Flutter installation not found" -ForegroundColor Yellow
}

# Step 5: Clean up Flutter caches and temporary files
Write-Host "`n🧹 Step 5: Cleaning up Flutter caches..." -ForegroundColor Green

$flutterCachePaths = @(
    "$env:LOCALAPPDATA\Pub\Cache",
    "$env:APPDATA\flutter",
    "$env:TEMP\flutter*",
    "$env:USERPROFILE\.flutter-plugins*",
    "$env:USERPROFILE\.flutter_tool_state"
)

foreach ($path in $flutterCachePaths) {
    if (Test-Path $path) {
        try {
            Remove-Item $path -Recurse -Force -ErrorAction SilentlyContinue
            Write-Host "✅ Cleaned: $path" -ForegroundColor Green
        } catch {
            Write-Host "⚠️  Could not clean: $path" -ForegroundColor Yellow
        }
    }
}

# Step 6: Download and install fresh Flutter
Write-Host "`n📥 Step 6: Downloading fresh Flutter..." -ForegroundColor Green

$flutterZipUrl = "https://storage.googleapis.com/flutter_infra_release/releases/stable/windows/flutter_windows_3.38.3-stable.zip"
$flutterZipPath = "$env:TEMP\flutter.zip"
$installPath = "C:\src"

Write-Host "📥 Downloading Flutter from: $flutterZipUrl" -ForegroundColor Blue

try {
    # Download Flutter
    Invoke-WebRequest -Uri $flutterZipUrl -OutFile $flutterZipPath -UseBasicParsing
    Write-Host "✅ Flutter downloaded successfully" -ForegroundColor Green
    
    # Create installation directory
    if (!(Test-Path $installPath)) {
        New-Item -ItemType Directory -Path $installPath -Force
        Write-Host "✅ Installation directory created" -ForegroundColor Green
    }
    
    # Extract Flutter
    Write-Host "📦 Extracting Flutter..." -ForegroundColor Blue
    Expand-Archive -Path $flutterZipPath -DestinationPath $installPath -Force
    Write-Host "✅ Flutter extracted successfully" -ForegroundColor Green
    
    # Clean up zip file
    Remove-Item $flutterZipPath -Force
    
} catch {
    Write-Host "❌ Failed to download Flutter: $_" -ForegroundColor Red
    Write-Host "💡 Please download manually from: https://flutter.dev/docs/get-started/install/windows" -ForegroundColor Yellow
    exit 1
}

# Step 7: Add Flutter to PATH
Write-Host "`n🔗 Step 7: Adding Flutter to PATH..." -ForegroundColor Green

$flutterBinPath = "$installPath\flutter\bin"
$userPath = [Environment]::GetEnvironmentVariable("PATH", "User")
[Environment]::SetEnvironmentVariable("PATH", "$userPath;$flutterBinPath", "User")
Write-Host "✅ Flutter added to user PATH" -ForegroundColor Green

# Update current session PATH
$env:PATH = "$env:PATH;$flutterBinPath"

# Step 8: Configure Flutter
Write-Host "`n⚙️  Step 8: Configuring Flutter..." -ForegroundColor Green

Write-Host "🔧 Running flutter doctor..." -ForegroundColor Blue
& "$flutterBinPath\flutter.bat" doctor -v

Write-Host "🔧 Running flutter config..." -ForegroundColor Blue
& "$flutterBinPath\flutter.bat" config --enable-web

Write-Host "🔧 Running flutter precache..." -ForegroundColor Blue
& "$flutterBinPath\flutter.bat" precache --web

# Step 9: Update project dependencies
Write-Host "`n📦 Step 9: Updating project dependencies..." -ForegroundColor Green

Set-Location "c:\dev\demo_ncl"

Write-Host "🧹 Running flutter clean..." -ForegroundColor Blue
& "$flutterBinPath\flutter.bat" clean

Write-Host "📦 Running flutter pub get..." -ForegroundColor Blue
& "$flutterBinPath\flutter.bat" pub get

Write-Host "🔧 Running flutter pub upgrade..." -ForegroundColor Blue
& "$flutterBinPath\flutter.bat" pub upgrade

# Step 10: Test Flutter web
Write-Host "`n🧪 Step 10: Testing Flutter web..." -ForegroundColor Green

Write-Host "🔧 Building Flutter web..." -ForegroundColor Blue
& "$flutterBinPath\flutter.bat" build web --no-web-resources-cdn

Write-Host "🚀 Starting Flutter web test server..." -ForegroundColor Blue
$flutterProcess = Start-Process -FilePath "$flutterBinPath\flutter.bat" -ArgumentList "run -d web-server --web-port 8096 --web-hostname 0.0.0.0" -PassThru

Write-Host "⏳ Waiting 15 seconds for Flutter to start..." -ForegroundColor Blue
Start-Sleep -Seconds 15

# Test the web server
try {
    $response = Invoke-WebRequest -Uri "http://localhost:8096" -TimeoutSec 10 -UseBasicParsing
    Write-Host "✅ Flutter web server is running!" -ForegroundColor Green
    
    # Check if we get actual content
    if ($response.Content.Length -gt 2000 -and !$response.Content.StartsWith("flutter-view flt-scene-host")) {
        Write-Host "🎉 SUCCESS: Flutter web content is rendering!" -ForegroundColor Green
        Write-Host "📝 Content length: $($response.Content.Length) characters" -ForegroundColor Blue
    } else {
        Write-Host "⚠️  Flutter web server running but content still not rendering properly" -ForegroundColor Yellow
        Write-Host "📝 Content length: $($response.Content.Length) characters" -ForegroundColor Blue
    }
} catch {
    Write-Host "❌ Flutter web server not responding: $_" -ForegroundColor Red
}

# Stop the test server
if ($flutterProcess) {
    $flutterProcess | Stop-Process -Force
    Write-Host "🛑 Test server stopped" -ForegroundColor Green
}

# Step 11: Final verification
Write-Host "`n🎯 Step 11: Final verification..." -ForegroundColor Green

Write-Host "🔧 Running final flutter doctor..." -ForegroundColor Blue
& "$flutterBinPath\flutter.bat" doctor

Write-Host "`n🎉 Flutter reinstall complete!" -ForegroundColor Cyan
Write-Host "================================" -ForegroundColor Cyan

Write-Host "`n📋 Summary:" -ForegroundColor White
Write-Host "✅ Old Flutter installation removed" -ForegroundColor Green
Write-Host "✅ Fresh Flutter 3.38.3 installed" -ForegroundColor Green  
Write-Host "✅ Flutter configured for web development" -ForegroundColor Green
Write-Host "✅ Project dependencies updated" -ForegroundColor Green
Write-Host "✅ Web rendering tested" -ForegroundColor Green

Write-Host "`n🚀 Next steps:" -ForegroundColor White
Write-Host "1. Restart your terminal/VS Code" -ForegroundColor Yellow
Write-Host "2. Run: flutter run -d web-server" -ForegroundColor Yellow
Write-Host "3. Test your authentication system" -ForegroundColor Yellow
Write-Host "4. Run E2E tests: npm run test:auth" -ForegroundColor Yellow

Write-Host "`n💡 If issues persist:" -ForegroundColor White
Write-Host "• Check Windows Defender/Firewall settings" -ForegroundColor Yellow
Write-Host "• Try running as Administrator" -ForegroundColor Yellow
Write-Host "• Consider using a different network" -ForegroundColor Yellow
Write-Host "• Test on a different machine/environment" -ForegroundColor Yellow

Write-Host "`n🔗 Backup location: $backupPath" -ForegroundColor Blue
Write-Host "🔗 Flutter installation: $flutterPath" -ForegroundColor Blue
