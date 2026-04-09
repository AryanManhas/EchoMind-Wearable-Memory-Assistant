# 📥 Android Studio Installation Guide

## Step 1: Download Android Studio

✅ **Browser opened:** https://developer.android.com/studio

### On the website:
1. Click **"Download Android Studio"** (large button)
2. **Choose:** "Windows" (EXE file)
3. **Accept terms:** Check the agreement box
4. **Download:** Click "Download Android Studio"

**File to download:** `android-studio-2024.1.1.13-windows.exe` (or latest version)

---

## Step 2: Run the Installer

### When download completes:
1. **Locate the file:** Usually in `Downloads` folder
2. **Right-click → Run as administrator**
3. **User Account Control:** Click "Yes"

### Installation Wizard:

#### 1. Welcome Screen
- Click **"Next"**

#### 2. Choose Components
- ✅ **Android Studio** (checked)
- ✅ **Android SDK** (checked)
- ✅ **Android Virtual Device** (checked)
- Click **"Next"**

#### 3. Configuration Settings
- Accept defaults
- Click **"Next"**

#### 4. Choose Start Menu Folder
- Accept default: `Android Studio`
- Click **"Next"**

#### 5. Select Installation Location
- **Recommended:** `C:\Program Files\Android\Android Studio`
- Click **"Next"**

#### 6. Install
- Click **"Install"**
- **Wait 5-10 minutes** for installation
- Progress bar will show components being installed

#### 7. Complete
- Click **"Next"**
- Click **"Finish"**

---

## Step 3: First Launch Setup

### Android Studio will open automatically:

#### 1. Welcome Screen
- Click **"Next"**

#### 2. Install Type
- Choose **"Standard"** (recommended)
- Click **"Next"**

#### 3. Select UI Theme
- Choose **"Light"** or **"Dark"** (your preference)
- Click **"Next"**

#### 4. SDK Components Setup
- Click **"Next"**
- **Wait 10-20 minutes** for SDK download
- Components downloading:
  - Android SDK
  - Android SDK Platform
  - Android SDK Build-Tools
  - Android Emulator
  - etc.

#### 5. License Agreement
- Check **"Accept"** for all licenses
- Click **"Finish"**

#### 6. Downloading Components
- **Wait 10-20 minutes** for downloads
- Progress shown in bottom bar
- Do NOT close Android Studio during this process

#### 7. Welcome to Android Studio
- Click **"Finish"** when complete

---

## Step 4: Verify Installation

### Open Command Prompt/PowerShell:
```bash
# Check if Android Studio is installed
where studio
# Should show: C:\Program Files\Android\Android Studio\bin\studio.exe

# Check Android SDK location
dir "C:\Users\%USERNAME%\AppData\Local\Android\Sdk"
```

### Configure Flutter:
```bash
# Set Android SDK path for Flutter
flutter config --android-sdk "C:\Users\PC\AppData\Local\Android\Sdk"

# Accept Android licenses
flutter doctor --android-licenses
# Press 'y' for each license
```

### Verify setup:
```bash
flutter doctor
```
Should now show:
```
[√] Android toolchain - develop for Android devices
[√] Android Studio
```

---

## Step 5: Create Android Virtual Device (AVD)

### In Android Studio:
1. **Open Android Studio** (if not open)
2. **Tools → Device Manager**
3. **Click "+" → Create Virtual Device**

#### Choose Device:
- **Category:** Phone
- **Device:** Pixel 4 (recommended) or Pixel 6
- **Click "Next"**

#### Choose System Image:
- **Download:** API 33 (Android 13) or API 34 (Android 14)
- **Click "Download"** next to the API level
- **Wait 5-10 minutes** for download
- **Click "Next"**

#### AVD Configuration:
- **AVD Name:** `EchoMind_Test`
- **Startup orientation:** Portrait
- **Accept other defaults**
- **Click "Finish"**

### Verify Emulator:
```bash
flutter emulators
# Should show: EchoMind_Test • android
```

---

## Step 6: Test Everything

### Start Backend (if not running):
```bash
cd backend
python app.py
```

### Start Android Emulator:
```bash
# Via Android Studio:
# Tools → Device Manager → Click play button (▶️) next to EchoMind_Test

# Via Command Line:
flutter emulators --launch EchoMind_Test
```

### Start Flutter App:
```bash
cd mobile_app
flutter run
```

---

## 🔧 Troubleshooting

### Installation Issues:
- **Run as Administrator:** Right-click installer → Run as administrator
- **Antivirus:** Temporarily disable during installation
- **Space:** Ensure 5GB+ free space

### SDK Download Issues:
- **Stable internet:** Required for large downloads
- **Proxy:** Configure if behind corporate proxy
- **Retry:** If download fails, restart Android Studio

### Flutter Configuration:
```bash
# If flutter doctor shows issues:
flutter config --android-sdk "C:\Users\PC\AppData\Local\Android\Sdk"
flutter doctor --android-licenses
```

### Emulator Issues:
- **HAXM:** Install Intel HAXM if prompted
- **Virtualization:** Enable VT-x in BIOS if emulator is slow
- **RAM:** Ensure 4GB+ RAM available

---

## 📋 Expected Timeline

- **Download:** 5-10 minutes (depends on internet)
- **Installation:** 5-10 minutes
- **SDK Download:** 15-30 minutes
- **Emulator Setup:** 10 minutes
- **Total Time:** ~45-60 minutes

---

## 🎯 Success Indicators

### Flutter Doctor Output:
```
[√] Flutter (Channel stable, 3.41.6, on Microsoft Windows...)
[√] Windows Version (Windows 11 or higher...)
[√] Android toolchain - develop for Android devices
[√] Android Studio
[√] Connected device (1 available)  ← Emulator running
[√] Network resources
```

### Emulator Running:
```bash
flutter devices
# Shows: android • emulator-5554 • android-x86 • Android SDK built for x86
```

---

## 🚀 Ready to Test!

Once everything is installed:

**Backend:** ✅ Running  
**Android Studio:** ✅ Installed  
**Android SDK:** ✅ Configured  
**Emulator:** ✅ Created  
**Flutter:** ✅ Ready  

**Test commands:**
```bash
# Test backend
curl http://127.0.0.1:5000/health

# Start emulator
flutter emulators --launch EchoMind_Test

# Run app
cd mobile_app && flutter run
```

---

## 💡 During Installation

While Android Studio installs, you can:

1. **Test backend:** `curl -X POST http://127.0.0.1:5000/add -H "Content-Type: application/json" -d '{"text": "Coffee with Sarah"}'`
2. **Review code:** Check the mobile_app/lib/ directory
3. **Read docs:** Look at the created documentation files

---

## 🎉 Next Steps

After installation completes:

1. **Create AVD** (Android Virtual Device)
2. **Start emulator**
3. **Run `flutter run`**
4. **Test voice features**

**Let me know when Android Studio installation completes and I'll help with the next steps!** 🚀

**Installation progress:** Check the Android Studio window for download progress.