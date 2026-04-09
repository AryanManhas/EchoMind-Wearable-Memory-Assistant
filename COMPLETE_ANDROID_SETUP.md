# 🚀 Complete Setup: Android Studio + Emulator + Flutter

## Current Status
- ✅ **Backend:** Running on `http://127.0.0.1:5000`
- ✅ **Flutter:** Installed (3.41.6)
- ❌ **Android Studio:** Not installed
- ❌ **Android SDK:** Not configured
- ❌ **Emulator:** Not available

---

## Step 1: Install Android Studio

### Download Android Studio:
1. Go to: https://developer.android.com/studio
2. Click **"Download Android Studio"**
3. Download the Windows version (EXE file)
4. Run the installer as Administrator

### Installation Steps:
1. **Welcome Screen:** Click "Next"
2. **Choose Components:** Select all components (Android Studio, Android SDK, Android Virtual Device)
3. **Configuration Settings:** Accept defaults
4. **Choose Start Menu Folder:** Accept default
5. **Select Installation Location:** Accept default (`C:\Program Files\Android\Android Studio`)
6. **Install:** Wait 5-10 minutes

---

## Step 2: Configure Android SDK

### First Launch Setup:
1. **Open Android Studio** (it should open automatically after installation)
2. **Welcome Screen:** Click "Next"
3. **Install Type:** Choose "Standard" (recommended)
4. **Select UI Theme:** Choose your preference
5. **SDK Components Setup:** Click "Next" (installs Android SDK, emulator, etc.)
6. **License Agreement:** Accept all licenses
7. **Verify Settings:** Click "Finish"

**Wait 10-20 minutes** for SDK download and installation.

---

## Step 3: Configure Flutter for Android

### Set Android SDK Path:
```bash
# Find your Android SDK location (usually):
# C:\Users\[YourUsername]\AppData\Local\Android\Sdk

# Configure Flutter to use it:
flutter config --android-sdk "C:\Users\PC\AppData\Local\Android\Sdk"
```

### Verify Setup:
```bash
flutter doctor --android-licenses
# Accept all licenses (press 'y' for each)
```

---

## Step 4: Create Android Virtual Device (AVD)

### Via Android Studio:
1. **Open Android Studio**
2. **Tools → Device Manager**
3. **Click "+" → Create Virtual Device**
4. **Choose Device:**
   - Category: Phone
   - Select: Pixel 4 or Pixel 6
   - Click "Next"
5. **Choose System Image:**
   - Download: API 33 (Android 13) or API 34 (Android 14)
   - Click "Next" (wait for download)
6. **AVD Configuration:**
   - AVD Name: `EchoMind_Test`
   - Click "Finish"

### Via Command Line (Alternative):
```bash
# List available system images
flutter emulators --create

# Or use Android Studio's AVD Manager
```

---

## Step 5: Start Everything

### Start Backend (if not running):
```bash
cd backend
python app.py
```

### Start Android Emulator:
```bash
# Via Android Studio:
# Tools → Device Manager → Click play button (▶️) next to your AVD

# Via Command Line:
flutter emulators --launch EchoMind_Test
```

### Start Flutter App:
```bash
cd mobile_app
flutter run
```

---

## Step 6: Test Everything

### Backend Tests:
```bash
# Test health
curl http://127.0.0.1:5000/health

# Test Phase 1 NLP
curl -X POST http://127.0.0.1:5000/add -H "Content-Type: application/json" -d '{"text": "Coffee with Sarah"}'
```

### Android App Tests:
1. **Text Input:** Type "Coffee with Sarah" → Should show "Meeting with Sarah"
2. **Voice Input:** Tap microphone → Say "Email report ASAP" → Should extract reminder
3. **Search:** Go to Search tab → Search "meeting"
4. **Today:** Go to Today tab → View reminders

---

## 🔧 Troubleshooting

### Android SDK Path Issues:
```bash
# Check current config
flutter config

# Set correct path
flutter config --android-sdk "C:\Users\PC\AppData\Local\Android\Sdk"

# Verify
flutter doctor
```

### Emulator Won't Start:
```bash
# Check available emulators
flutter emulators

# Launch specific emulator
flutter emulators --launch EchoMind_Test

# Or use Android Studio Device Manager
```

### Build Failures:
```bash
# Clean and rebuild
cd mobile_app
flutter clean
flutter pub get
flutter run
```

### Permission Issues:
- **Microphone:** Settings → Apps → YourApp → Permissions → Allow
- **Storage:** Same as above

---

## 📋 Expected Timeline

- **Android Studio Install:** 10-15 minutes
- **SDK Download:** 10-20 minutes
- **Emulator Setup:** 5-10 minutes
- **First Flutter Build:** 5-10 minutes
- **Total Time:** ~30-60 minutes

---

## 🎯 What You Need

1. **Android Studio:** https://developer.android.com/studio
2. **Stable internet:** For SDK downloads
3. **Admin rights:** For installation
4. **Patience:** First setup takes time

---

## 🚀 Quick Verification

After setup, run:
```bash
flutter doctor
```

Should show:
```
[√] Flutter
[√] Windows Version
[√] Android toolchain
[√] Android Studio
[√] Connected device
[√] Network resources
```

---

## 💡 Alternative: Use Physical Android Device

If emulator is slow, you can use a real Android phone:

1. **Enable Developer Options:** Settings → About Phone → Tap Build Number 7 times
2. **Enable USB Debugging:** Settings → Developer Options → USB Debugging
3. **Connect via USB**
4. **Allow USB debugging** on phone
5. **Run:** `flutter devices` (should show your phone)

---

## 🎉 Ready to Test!

Once everything is set up:

**Backend:** ✅ Running  
**Android Studio:** ✅ Installed  
**Emulator:** ✅ Created  
**Flutter App:** ✅ Ready  

**Test commands:**
```bash
# Backend test
curl -X POST http://127.0.0.1:5000/add -H "Content-Type: application/json" -d '{"text": "Coffee with Sarah"}'

# Start app
cd mobile_app && flutter run
```

**Let me know when Android Studio is installed and I'll help with the next steps!** 🚀