# 🎤 Voice Module - Ready to Test!

## What's New? ✨

**Voice Module is NOW FULLY INTEGRATED!**

- Record audio from Android app ✅
- Transcribe with speech-to-text ✅
- Extract info (who, when, what) ✅
- Save to database ✅
- Search voice memories ✅
- Always-on listening (wake-word) ✅

---

## 🚀 Start Testing Now (3 Steps)

### Step 1️⃣: Start Backend
```powershell
CD C:\Users\PC\Downloads\EchoMInd
.\run_backend.ps1
```
**Wait for:** `Running on http://127.0.0.1:5000`

### Step 2️⃣: Start Android Emulator
- Android Studio → Device Manager → Click Play ▶️
- Or run: `"$env:ANDROID_HOME\emulator\emulator.exe" -avd Pixel_6_API_33`

**Wait for:** Emulator fully booted (30-60 seconds)

### Step 3️⃣: Start App
```powershell
cd mobile_app
flutter run
```
**Wait for:** App appears on emulator screen

---

## 🧪 EZ Test Checklist

Choose **ONE** to test first:

### Option A: Text Only (No Mic Needed) ✅
``` 
✓ Home tab → Type: "Meet John tomorrow"
✓ Tap: Add Memory
✓ Check: Memories tab
✓ Search tab → Find: "John"
✓ Assistant tab → Ask: "When is my meeting?"
```

### Option B: Voice Only (With Mic) 🎤
```
✓ Grant microphone permission (Android popup)
✓ Home tab → Voice Module
✓ Tap: Start Recording
✓ Speak: "Call Mom Friday afternoon"
✓ Tap: Stop Recording
✓ Tap: Send Voice Chunk
✓ Check: Memories tab
```

### Option C: Advanced Voice 🌙
```
✓ Home tab → Voice Module
✓ Toggle: "Always-on mode" ON
✓ Speak: "Hey EchoMind, remind me to call Sarah"
✓ System auto-records
✓ Check: Status shows "saved"
```

---

## ❓ Quick FAQ

### Q: Can I test without microphone?
**A:** Yes! Use text input (Option A above). Works perfectly.

### Q: Will voice work on emulator?
**A:** Yes, if you start it with audio: `-audio-in default`

### Q: What if microphone doesn't work?
**A:** Check Settings → Apps → Wearable Memory Assistant → Permissions → Microphone → Allow

### Q: Can I use real Android phone?
**A:** Yes! Update IP in `mobile_app/lib/api_service.dart` line 50

### Q: Memory lost after restart?
**A:** No! Saved in `backend/data/memories.db` (SQLite)

### Q: How long do voice features take?
**A:** Recording: Real-time  
Transcription: 1-5 seconds  
Storage: Instant  
Search: <1 second

---

## 📊 What Each Tab Does

| Tab | What It Does | Need Voice? |
|-----|-------------|-------------|
| **Today** | See daily brief + reminders | No |
| **Home** | Add text OR record voice | Optional |
| **Memories** | View all saved memories | No |
| **Search** | Find memories by keyword | No |
| **Assistant** | Ask about memories | No |

---

## 🎤 Voice Features Explained

### Manual Recording
- Press: Record button
- Speak into your mic
- Press: Stop
- Press: Send
- ✓ Saved!

### Always-On Mode
- Toggle: ON
- Say: "Hey EchoMInd, ..."
- System: Auto-records
- ✓ Auto-saved!

### Wake Word
- Must say: **Exactly** "Hey EchoMind"
- Then: Say whatever you want
- Like: "Hey EchoMind, lunch with Sarah tomorrow"

---

## 🔧 If Something Breaks

### Backend won't start?
```
Check: Is Python venv activated?
Try: cd backend && & .\.venv\Scripts\Activate.ps1
```

### App can't find backend?
```
Check: Endpoint = http://10.0.2.2:5000 (for emulator)
File: mobile_app/lib/api_service.dart
```

### No microphone access?
```
Settings → Apps → Wearable Memory Assistant
→ Permissions → Microphone → Allow
Restart app
```

### Vosk can't transcribe?
```
Make sure folder exists: backend/vosk-model-small-en-us-0.15/
If not: Download from https://alphacephei.com/vosk/models
```

---

## 📱 Example Conversations

### Text Example
```
Type: "Dinner with Sarah Friday 7 PM"
        ↓
Saved as: type=meeting, person=Sarah, time=Friday 7 PM
        ↓
Search "Sarah" → Found!
        ↓
Ask "Dinner plans Friday?" → Answer shows memory
```

### Voice Example
```
Record: "Call John tomorrow morning"
        ↓
Transcribed: "Call John tomorrow morning"
        ↓
Saved as: type=call, person=John, time=tomorrow morning
        ↓
Same as text! All features work.
```

### Always-On Example
```
Wake word enabled
Say: "Hey EchoMind, remember meeting with team lead Thursday 2pm"
        ↓
System auto-records and transcribes
        ↓
Saves: type=meeting, person=team lead, time=Thursday 2pm
        ↓
Shows: "Voice chunk #1 saved. Reminder: yes (high)"
```

---

## 🎯 Success = When You See

✅ **Text Works When:**
- Type something
- See response in green
- Appears in Memories tab

✅ **Voice Works When:**
- Record audio
- See transcription
- Appears in Memories tab

✅ **Search Works When:**
- Find both text and voice memories
- By keyword, person name, or time

✅ **Ask Works When:**
- Get answer from your memories
- Shows memory ID references

---

## 📞 Need More Details?

**Full testing guide:** See `VOICE_TESTING.md`  
**Complete setup:** See `COMPLETE_SETUP.md`  
**Cheat sheet:** See `QUICK_REF.md`

---

## 🎉 You're Ready!

Everything is set up and ready to go.  
Just follow the 3 steps above and start testing!

**Pick your test:**
- 📝 Text only? (Easiest)
- 🎤 With voice? (With microphone)
- 🌙 Always-on? (Advanced)

**Let's go!** 🚀

---

**Status:** Voice Module ✅ READY  
**Edition:** Android Emulator Testing  
**Date:** April 1, 2026
