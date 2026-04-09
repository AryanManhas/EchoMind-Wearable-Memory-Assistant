# Android Setup & Testing Guide for EchoMInd

## Phase 1: Install Android SDK (Required First Step)

### Option A: Install Android Studio (Recommended)
1. Download Android Studio: https://developer.android.com/studio
2. Run installer and follow setup wizard
3. Install these components during setup:
   - Android SDK
   - Android SDK Platform (API 33+)
   - Android Virtual Device (AVD) - for emulator

4. After installation, open Android Studio and create a default Android Virtual Device (AVD):
   - Tools → Device Manager → Create Virtual Device
   - Select Pixel 6 with Android 13+ (API 33+)
   - Allocate 4GB RAM, 100GB storage

### Option B: Quick SDK Setup (if you already have Android Studio)
```powershell
# Check if Android Studio is installed and SDK is found
cd C:\Users\PC\Downloads\EchoMInd
flutter doctor --android-licenses
flutter doctor
```

## Phase 2: Verify Flutter Android Setup

```powershell
cd C:\Users\PC\Downloads\EchoMInd
flutter clean
flutter pub get
flutter config --enable-android
```

## Phase 3: List Available Android Devices

```powershell
flutter devices
```

**Expected output:**
```
You have 2 connected devices:

1. Android emulator name (emulator-5554) • 10.0.2.2:5554 • Android 13 (API 33)
2. Windows (windows)                      • windows       • windows-x64
```

## Phase 4: Start Android Emulator

### If using Android Studio:
- Open Android Studio
- Tools → Device Manager
- Click Play button next to your AVD

### Or from command line:
```powershell
# List available emulators
"$env:ANDROID_HOME\emulator\emulator.exe" -list-avds

# Start emulator (replace with your AVD name)
"$env:ANDROID_HOME\emulator\emulator.exe" -avd Pixel_6_API_33 -wipe-data
```

Wait 30-60 seconds for emulator to fully boot.

## Phase 5: Start Backend Server

Open **new PowerShell window** and run:

```powershell
cd C:\Users\PC\Downloads\EchoMInd\backend

# Activate virtual environment
& .\.venv\Scripts\Activate.ps1

# Start Flask server
python app.py
```

Expected output:
```
 * Running on http://127.0.0.1:5000
 * WARNING in app.run(): This is a development server. Do not use it in production deployments.
```

## Phase 6: Configure App for Android Emulator

The app already has correct emulator endpoint (`10.0.2.2:5000`), but you can customize:

Edit [mobile_app/lib/api_service.dart](mobile_app/lib/api_service.dart):

```dart
// For Android emulator, use:
return "http://10.0.2.2:5000";

// For real device on same Wi-Fi, update this IP:
static const String _lanIp = "192.168.X.X";  // Your PC's local IP
```

To find your PC's LAN IP:
```powershell
ipconfig
# Look for "IPv4 Address" under your active network (usually 192.168.x.x)
```

## Phase 7: Build & Run on Android Emulator

```powershell
cd C:\Users\PC\Downloads\EchoMInd\mobile_app

# Build APK and install on emulator
flutter run -d emulator-5554

# Or let Flutter pick the device automatically
flutter run
```

First build takes 2-5 minutes. Subsequent runs are faster (~30 seconds).

## Phase 8: Test Basic Flows (Without Voice)

### Test Text Memory Input:
1. App opens with 5 tabs: Today, Home (📱), Memories, Search, Assistant
2. Go to **Home** tab
3. Type in "Typed memory" field: `Meet Rahul tomorrow at 4 PM`
4. Tap **Add Memory**
5. Check **Memories** tab - memory should appear

### Test Search:
1. Go to **Search** tab
2. Type: `Rahul`
3. Tap **Search**
4. You should see your saved memory

### Test Assistant:
1. Go to **Assistant** tab
2. Type: `When is my meeting with Rahul?`
3. Tap **Analyze Conversation**
4. Backend should return answer from saved memories

### Test Daily Brief:
1. Go to **Today** tab
2. You should see daily brief and today's reminders

## Phase 9: Mock Voice for Testing (Until Voice Module Ready)

Voice will be added later. For now, test text input workflows.

When you're ready for voice:
1. Enable microphone permission on emulator
2. Generate test audio files
3. Integrate actual voice recording module

## Troubleshooting

### "No connected devices"
```powershell
flutter devices
adb devices  # Should show emulator-XXXX
```

### Backend 404/500 errors
1. Check backend is running on port 5000:
   ```powershell
   netstat -ano | findstr :5000
   ```
2. Check CORS is enabled in [backend/app.py](backend/app.py)
3. Restart backend server

### App can't reach backend
1. Verify emulator endpoint in [api_service.dart](mobile_app/lib/api_service.dart)
2. For physical device: update `_lanIp` to your PC's IPv4 address
3. Ensure firewall allows port 5000

### Slow build time
- First build: 2-5 minutes (normal)
- Subsequent: 30-60 seconds
- Use `flutter run --release` for optimized APK

## Next Steps: Adding Voice Module Later

Once you have Android app running smoothly, we'll:
1. Add actual voice recording with [record](https://pub.dev/packages/record)
2. Integrate Vosk speech-to-text
3. Add wake-word detection
4. Enable always-on listening mode

---

## Quick Command Reference

```powershell
# Start backend
cd backend && & .\.venv\Scripts\Activate.ps1 && python app.py

# Start emulator
"$env:ANDROID_HOME\emulator\emulator.exe" -avd Pixel_6_API_33

# Build & run app
flutter run

# View logs
flutter logs

# Rebuild
flutter clean && flutter pub get && flutter run

# Test backend health
curl http://127.0.0.1:5000/health
```
