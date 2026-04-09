# 🚀 EchoMInd Dev Quick Reference

## ⚡ Start Development (3 Steps)

```powershell
# 1. Terminal 1 - Backend
.\run_backend.ps1
# Waits for http://127.0.0.1:5000/health to be ready

# 2. Terminal 2 - Android Emulator (via Android Studio)
# Or: "$env:ANDROID_HOME\emulator\emulator.exe" -avd Pixel_6_API_33

# 3. Terminal 3 - App
cd mobile_app
flutter run
```

---

## 🧪 Quick Tests

### Test 1: Type Memory
```
Tab: Home → Field: "Meet John tomorrow at 2 PM" → Button: "Add Memory"
Check: Memories tab shows it
```

### Test 2: Search
```
Tab: Search → Field: "John" → Button: "Search"
Check: Memory appears in results
```

### Test 3: Ask Assistant
```
Tab: Assistant → Field: "When am I meeting John?" → Button: "Analyze"
Check: Answer shows memory citation
```

---

## 🔧 Common Commands

```powershell
# Backend
.\run_backend.ps1                    # Start server
curl http://127.0.0.1:5000/health   # Check status

# Flutter
cd mobile_app
flutter clean                        # Clean build
flutter pub get                      # Get deps
flutter run                          # Run app
flutter logs                         # View logs

# Android
flutter devices                      # List devices
"$env:ANDROID_HOME\emulator\emulator.exe" -list-avds  # List AVDs
```

---

## 📱 API Quick Test

```powershell
# Add memory (PowerShell)
$body = @{text="Test memory"} | ConvertTo-Json
curl -uri http://127.0.0.1:5000/add -Method POST -Body $body -ContentType "application/json"

# List memories
curl http://127.0.0.1:5000/memories

# Search
$search = @{query="Test"} | ConvertTo-Json
curl -uri http://127.0.0.1:5000/search -Method POST -Body $search -ContentType "application/json"
```

---

## 🎯 Important Endpoints

| Endpoint | Use |
|----------|-----|
| `http://127.0.0.1:5000/health` | Backend status |
| `http://10.0.2.2:5000` | From Android (emulator) |
| `http://192.168.x.x:5000` | From physical Android device |

---

## 📂 Key Files

| File | Purpose |
|------|---------|
| `backend/app.py` | API routes |
| `mobile_app/lib/main.dart` | App UI |
| `mobile_app/lib/api_service.dart` | Backend client |
| `backend/services/*` | NLP, DB, Search|

---

## ✅ Checklist

- [ ] Android Studio + SDK installed
- [ ] Android AVD created
- [ ] Backend starts without errors
- [ ] App runs on emulator
- [ ] Can add text memory
- [ ] Can search memories
- [ ] Can ask assistant
- [ ] Brief shows on Today tab

---

## 🆘 Quick Fixes

| Issue | Fix |
|-------|-----|
| Backend won't start | Check Python venv: `.\.venv\Scripts\Activate.ps1` |
| App can't reach backend | Endpoint in `api_service.dart` = `10.0.2.2:5000` |
| No devices | Start Android emulator first |
| Build fails | `flutter clean && flutter pub get` |

---

## 📚 Full Docs

- [ANDROID_SETUP.md](ANDROID_SETUP.md) - Complete setup guide
- [TESTING_GUIDE.md](TESTING_GUIDE.md) - Testing instructions
- [ANDROID_READY.md](ANDROID_READY.md) - Full implementation guide

---

## 🎯 Next Phase

Voice module will be added after app is stable on Android.
Currently testing: **Text memory workflows only**

---

**Status:** Ready for Android Development ✅
**Date:** April 1, 2026
