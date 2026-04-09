# 🚀 How to Start EchoMInd Project

## Quick Start (3 Steps)

### Step 1: Start Backend Server
```bash
cd backend
python app.py
```
**Expected output:**
```
* Serving Flask app 'app'
* Running on http://127.0.0.1:5000 (Press CTRL+C to quit)
```

### Step 2: Start Android Emulator
```bash
# Option A: Android Studio
# Open Android Studio → Tools → Device Manager → Start your AVD

# Option B: Command line (if Android SDK in PATH)
emulator -avd YourEmulatorName
```

### Step 3: Start Flutter App
```bash
cd mobile_app
flutter run
```
**Expected output:**
```
Launching lib/main.dart on Android SDK built for x86 in debug mode...
✓ Built build/app/outputs/flutter-apk/app-debug.apk
Installing build/app/outputs/flutter-apk/app-debug.apk...
```

---

## 📋 Detailed Instructions

### Backend Setup

#### Prerequisites:
- Python 3.8+ installed
- Virtual environment activated

#### Start Backend:
```bash
# Navigate to backend directory
cd backend

# Activate virtual environment (if not already)
.\.venv\Scripts\Activate.ps1  # Windows PowerShell
# or
source .venv/bin/activate     # Linux/Mac

# Start the server
python app.py
```

#### Verify Backend is Running:
```bash
# Test health endpoint
curl http://127.0.0.1:5000/health

# Should return:
{
  "status": "ok",
  "embeddings": {...},
  "vosk_model": "...",
  "llm_enabled": false,
  "llm_model": null,
  "database": "ready"
}
```

### Mobile App Setup

#### Prerequisites:
- Flutter SDK installed
- Android Studio with Android SDK
- Android emulator or physical device

#### Start Android Emulator:
1. **Via Android Studio:**
   - Open Android Studio
   - Tools → Device Manager
   - Create AVD if needed (Pixel 4, API 33+ recommended)
   - Click ▶️ to start emulator

2. **Via Command Line:**
   ```bash
   # List available emulators
   emulator -list-avds

   # Start specific emulator
   emulator -avd Pixel_4_API_33
   ```

#### Start Flutter App:
```bash
# Navigate to mobile app directory
cd mobile_app

# Get dependencies (first time only)
flutter pub get

# Run on connected device/emulator
flutter run

# Or specify device
flutter run -d emulator-5554
```

#### Verify Flutter Setup:
```bash
# Check Flutter doctor
flutter doctor

# List connected devices
flutter devices

# Should show your emulator
```

---

## 🔧 Troubleshooting

### Backend Issues

#### "Module not found" error:
```bash
# Install dependencies
cd backend
pip install -r requirements.txt
```

#### Port 5000 already in use:
```bash
# Kill process using port 5000
netstat -ano | findstr :5000
taskkill /PID <PID> /F

# Or use different port
python app.py --port 5001
```

#### Database issues:
```bash
# Delete and recreate database
cd backend
rm data/memories.db
python -c "from services.db_service import DBService; from pathlib import Path; DBService(Path('data/memories.db'))"
```

### Android/Flutter Issues

#### Emulator not starting:
```bash
# Check Android SDK path
flutter config --android-sdk "C:\Users\YourUser\AppData\Local\Android\Sdk"

# Or wherever your Android SDK is installed
```

#### Build failures:
```bash
# Clean and rebuild
flutter clean
flutter pub get
flutter run
```

#### Permission issues:
```bash
# Grant microphone permissions in emulator
# Settings → Apps → YourApp → Permissions → Allow microphone
```

#### Network connection issues:
- Android emulator uses `10.0.2.2:5000` to reach host
- Backend runs on `127.0.0.1:5000` (host machine)
- App automatically handles this mapping

---

## 🎯 Testing Your Setup

### Backend Tests:
```bash
# Test basic functionality
curl -X POST http://127.0.0.1:5000/add -H "Content-Type: application/json" -d '{"text": "Test memory"}'

# Test Phase 1 improvements
curl -X POST http://127.0.0.1:5000/add -H "Content-Type: application/json" -d '{"text": "Coffee with Sarah"}'
# Should return: "type": "meeting"
```

### App Tests:
1. **Text Input:** Type "Coffee with Sarah" → Should show "Meeting with Sarah"
2. **Voice Input:** Tap mic → Say "Lunch with team" → Should extract meeting
3. **Search:** Go to Search tab → Search "meeting" → Should find memories
4. **Today:** Go to Today tab → Should show today's reminders

---

## 📁 Project Structure

```
EchoMInd/
├── backend/                    # Flask API server
│   ├── app.py                 # Main Flask app
│   ├── services/              # Business logic
│   │   ├── nlp_service.py     # NLP processing (Phase 1 enhanced)
│   │   ├── audio_service.py   # Voice transcription
│   │   ├── db_service.py      # SQLite database
│   │   └── ...
│   ├── data/                  # Database and models
│   └── requirements.txt       # Python dependencies
├── mobile_app/                # Flutter Android app
│   ├── lib/                   # Dart source code
│   │   ├── main.dart          # App entry point
│   │   ├── api_service.dart   # Backend communication
│   │   └── models.dart        # Data models
│   ├── android/               # Android-specific config
│   └── pubspec.yaml           # Flutter dependencies
└── docs/                      # Documentation
```

---

## 🚀 Ready to Go!

**Backend:** `http://127.0.0.1:5000`  
**Mobile App:** Running on Android emulator  
**Voice Features:** Ready with wake word detection  
**NLP:** Enhanced with Phase 1 improvements  

**Next:** Test the features and let me know how it works! 🎉