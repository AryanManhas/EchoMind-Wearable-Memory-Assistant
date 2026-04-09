# Android Testing & Development Guide

## ✅ Setup Complete

You now have:
- ✓ Enhanced backend with error handling
- ✓ CORS properly configured for mobile/Android
- ✓ Startup scripts for easy execution
- ✓ Complete Android setup instructions

---

## 🚀 Quick Start (5 Minutes)

### Step 1: Install Android Studio (If Not Already Done)
See [ANDROID_SETUP.md](ANDROID_SETUP.md) Phase 1 for detailed instructions.

### Step 2: Start Backend Server
**Option A - PowerShell (Recommended):**
```powershell
.\run_backend.ps1
```

**Option B - Batch file:**
```cmd
START_BACKEND.bat
```

Expected output:
```
 * Serving Flask app 'app'
 * Running on http://127.0.0.1:5000
 * Debug mode: on
```

### Step 3: Start Android Emulator
- Open Android Studio
- Device Manager → Click Play on your AVD
- Wait 30-60 seconds for boot

### Step 4: Build & Run App
```powershell
cd mobile_app
flutter run
```

Wait 2-5 minutes for first build.

---

## 🧪 Testing Without Voice (Current Phase)

Since voice module will be added later, test these flows:

### Test 1: Add Text Memory
1. **Go to Home tab** (microphone icon)
2. **Type in first field:** `Meet Rahul tomorrow at 4 PM`
3. **Tap "Add Memory"**
4. **Expected response:** `Meeting with Rahul tomorrow at 4 PM` in green

### Test 2: View Memories
1. **Go to Memories tab**
2. **Should see:** Your saved memory with:
   - Type: `meeting`
   - Person: `Rahul`
   - Time: `tomorrow at 4 PM`
   - Reminder: `yes`
   - Priority: `medium` or `high`

### Test 3: Search Memories
1. **Go to Search tab**
2. **Type:** `Rahul`
3. **Tap Search**
4. **Expected:** Memory appears with relevance score

### Test 4: Daily Brief
1. **Go to Today tab**
2. **Should show:**
   - Daily brief message
   - Today's reminders (if due today)

### Test 5: Ask Assistant
1. **Go to Assistant tab**
2. **Type:** `What's my meeting about?` or `When is my meeting with Rahul?`
3. **Tap "Analyze Conversation"**
4. **Expected:** 
   - Answer from saved memories
   - Source: `fallback` (since LLM is disabled)
   - Citations showing memory IDs

### Test 6: Search from Assistant
1. **In Assistant tab, tap "Open memory deep link"**
2. **Paste:** `memory://id/1` (use actual memory ID from citations)
3. **Should open:** Individual memory detail page

---

## 📝 Test Data Examples

Add these to populate memories:

```
1. "Call John on Friday morning"
   → Type: call, Person: John, Time: Friday morning

2. "Dinner with Parents tomorrow at 6 PM"
   → Type: meeting, Person: Parents, Time: tomorrow at 6 PM

3. "Birthday party next Saturday at 7 PM"
   → Type: general, Time: next Saturday at 7 PM

4. "Remember to send proposal to Mike"
   → Type: reminder, Person: Mike, is_reminder: true

5. "Monthly team meeting every second Tuesday at 10 AM"
   → Type: meeting, Time: Tuesday at 10 AM
```

---

## 🐛 Debugging & Troubleshooting

### Issue: "Failed to connect to backend"

**Check 1: Is backend running?**
```powershell
curl http://127.0.0.1:5000/health
```
Should return JSON with status "ok"

**Check 2: Check Android endpoint**
- For Android Emulator (correct): `http://10.0.2.2:5000`
- Edit [mobile_app/lib/api_service.dart](mobile_app/lib/api_service.dart)
- For physical device: use your PC's LAN IP (192.168.x.x)

**Check 3: Check firewall**
```powershell
# Check if port 5000 is open
netstat -ano | findstr :5000
```

### Issue: "No connected devices"
```powershell
# Check devices
flutter devices

# List available emulators
"$env:ANDROID_HOME\emulator\emulator.exe" -list-avds

# Start emulator manually
"$env:ANDROID_HOME\emulator\emulator.exe" -avd Pixel_6_API_33 -wipe-data
```

### Issue: Build fails with dependency errors
```powershell
cd mobile_app
flutter clean
flutter pub get
flutter run
```

### View app logs
```powershell
flutter logs
```

### View backend logs
Check the terminal where backend is running - Flask logs all requests.

---

## 📱 Testing on Physical Android Device

When you have a real Android phone:

1. **Enable USB Debugging:**
   - Settings → Developer Options → USB Debugging → ON
   - Connect phone via USB

2. **Update API endpoint:**
   Edit [mobile_app/lib/api_service.dart](mobile_app/lib/api_service.dart):
   ```dart
   static const String _lanIp = "192.168.X.X";  // Your PC's IPv4
   ```

3. **Find your PC's IP:**
   ```powershell
   ipconfig
   # Look for IPv4 Address under your network adapter
   ```

4. **Run app on phone:**
   ```powershell
   flutter devices  # Should show your phone
   flutter run -d <device-id>
   ```

---

## 🎯 Next Phase: Adding Voice Module

Once text-based testing is working smoothly:

1. **Voice recording** - Already partially configured with `record` package
2. **Wake word detection** - "Hey EchoMind" 
3. **Stream transcription** - Vosk speech-to-text
4. **Always-on mode** - Continuous listening

We'll enable these features when ready.

---

## ✨ Key Testing Endpoints

Test backend directly (for debugging):

```powershell
# Health check
curl http://127.0.0.1:5000/health

# Add memory (text)
$body = @{text="Test memory"} | ConvertTo-Json
curl -uri http://127.0.0.1:5000/add -Method POST -Body $body -ContentType "application/json"

# List memories
curl http://127.0.0.1:5000/memories

# Search
$search = @{query="Test"} | ConvertTo-Json
curl -uri http://127.0.0.1:5000/search -Method POST -Body $search -ContentType "application/json"

# Get today's reminders
curl http://127.0.0.1:5000/reminders/today

# Get daily brief
curl http://127.0.0.1:5000/brief

# Ask assistant
$ask = @{query="What memories do I have?"} | ConvertTo-Json
curl -uri http://127.0.0.1:5000/ask -Method POST -Body $ask -ContentType "application/json"
```

---

## 📚 File References

| File | Purpose |
|------|---------|
| [backend/app.py](backend/app.py) | Flask routes & API endpoints |
| [mobile_app/lib/main.dart](mobile_app/lib/main.dart) | App UI & screens |
| [mobile_app/lib/api_service.dart](mobile_app/lib/api_service.dart) | Backend client |
| [ANDROID_SETUP.md](ANDROID_SETUP.md) | Detailed Android setup guide |

---

## 📞 Support

If you encounter issues:
1. Check [ANDROID_SETUP.md](ANDROID_SETUP.md) troubleshooting section
2. View backend logs (terminal where it's running)
3. Run `flutter logs` to see app logs
4. Test backend directly with curl commands above

