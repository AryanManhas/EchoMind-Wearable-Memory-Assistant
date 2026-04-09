@echo off
REM Start EchoMInd Backend Server
REM This script activates the Python environment and runs the Flask server

cd /d "%~dp0backend"
call .venv\Scripts\activate.bat
echo.
echo ============================================
echo Starting EchoMInd Backend Server...
echo ============================================
echo Flask will run on http://127.0.0.1:5000
echo.
python app.py

pause
