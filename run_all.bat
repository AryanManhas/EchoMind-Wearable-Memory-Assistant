@echo off
setlocal

REM Run backend and Flutter in separate terminals on Windows
cd /d "%~dp0backend"
if not exist ".venv\Scripts\activate" (
  echo Virtualenv not found. Run install first (python -m venv .venv & pip install -r requirements.txt)
  pause
  exit /b 1
)

start "EchoMInd Backend" cmd /k "cd /d %~dp0backend && .venv\Scripts\activate && python app.py"

cd /d "%~dp0mobile_app"
start "EchoMInd Mobile" cmd /k "cd /d %~dp0mobile_app && flutter pub get && flutter run -d chrome"

echo Launched backend and mobile app windows.
endlocal
