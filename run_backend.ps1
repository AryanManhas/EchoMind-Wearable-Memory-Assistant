#!/usr/bin/env pwsh
# Start EchoMInd Backend Server
# This script activates the Python environment and runs Flask

$backendPath = Join-Path $PSScriptRoot "backend"
$venvPath = Join-Path $backendPath ".venv"
$activatePath = Join-Path $venvPath "Scripts\Activate.ps1"

if (-not (Test-Path $activatePath)) {
    Write-Host "Virtual environment not found at: $venvPath" -ForegroundColor Red
    Write-Host "Run: python -m venv $venvPath" -ForegroundColor Yellow
    exit 1
}

# Activate virtual environment
Write-Host "Activating Python environment..." -ForegroundColor Cyan
& $activatePath

# Change to backend directory
Set-Location $backendPath

Write-Host "`n========================================" -ForegroundColor Green
Write-Host "Starting EchoMInd Backend" -ForegroundColor Yellow
Write-Host "========================================" -ForegroundColor Green
Write-Host "Backend will run on:" -ForegroundColor Cyan
Write-Host "  http://127.0.0.1:5000" -ForegroundColor White
Write-Host "  http://10.0.2.2:5000 (Android Emulator)" -ForegroundColor White
Write-Host "`nPress Ctrl+C to stop the server" -ForegroundColor Yellow
Write-Host "========================================`n" -ForegroundColor Green

# Run Flask app
python app.py
