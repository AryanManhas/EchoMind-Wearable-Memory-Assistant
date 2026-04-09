#!/usr/bin/env pwsh
# EchoMInd Android Testing Setup Script

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "EchoMInd Android Testing Setup" -ForegroundColor Green
Write-Host "========================================`n"

# Check Flutter installation
Write-Host "[1/4] Checking Flutter installation..." -ForegroundColor Yellow
$flutterCheck = flutter doctor 2>&1 | Select-String "Flutter"
if ($flutterCheck) {
    Write-Host "✓ Flutter found" -ForegroundColor Green
} else {
    Write-Host "✗ Flutter not found" -ForegroundColor Red
    exit 1
}

# Check connected devices
Write-Host "`n[2/4] Checking available devices..." -ForegroundColor Yellow
$devices = flutter devices 2>&1
Write-Host $devices
Write-Host ""

# Check backend
Write-Host "[3/4] Testing backend connection..." -ForegroundColor Yellow
try {
    $response = Invoke-WebRequest -Uri "http://127.0.0.1:5000/health" -ErrorAction Stop
    Write-Host "✓ Backend is running on http://127.0.0.1:5000" -ForegroundColor Green
} catch {
    Write-Host "⚠ Backend not running (this is normal on first setup)" -ForegroundColor Yellow
    Write-Host "  Start backend with: START_BACKEND.bat or run_backend.ps1" -ForegroundColor Cyan
}

# Summary
Write-Host "`n[4/4] Setup Summary" -ForegroundColor Yellow
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Next steps:" -ForegroundColor Green
Write-Host "1. Start Android emulator via Android Studio or:" -ForegroundColor White
Write-Host "   `"$env:ANDROID_HOME\emulator\emulator.exe`" -avd Pixel_6_API_33" -ForegroundColor Cyan
Write-Host ""
Write-Host "2. Start backend server:" -ForegroundColor White
Write-Host "   .\START_BACKEND.bat  OR  .\run_backend.ps1" -ForegroundColor Cyan
Write-Host ""
Write-Host "3. Run app on Android:" -ForegroundColor White
Write-Host "   cd mobile_app" -ForegroundColor Cyan
Write-Host "   flutter run" -ForegroundColor Cyan
Write-Host ""
Write-Host "4. Test features (without voice for now):" -ForegroundColor White
Write-Host "   - Type memory in Home tab" -ForegroundColor Cyan
Write-Host "   - View in Memories tab" -ForegroundColor Cyan
Write-Host "   - Search in Search tab" -ForegroundColor Cyan
Write-Host "   - Ask in Assistant tab" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

Read-Host "Press Enter to continue"
