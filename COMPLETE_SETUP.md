# 🚀 EchoMInd Complete Setup - Text + Voice

## ✅ What's Ready

- ✅ **Backend:** Voice + text processing, all endpoints with error handling
- ✅ **Android App:** Voice recording + transcription + always-on listening
- ✅ **Database:** SQLite memory persistence
- ✅ **NLP:** Extract person, time, type, reminders from voice or text
- ✅ **Search:** Find memories by keyword (works with voice)
- ✅ **Assistant:** Ask questions, get answers from memories

---

## 🚀 5-Minute Quick Start

### Terminal 1: Backend Server
```powershell
cd C:\Users\PC\Downloads\EchoMInd
.\run_backend.ps1
# Waits for: * Running on http://127.0.0.1:5000
```

### Terminal 2: Android App
```powershell
cd mobile_app
flutter run
# Waits for: "app started" in terminal
```

### Android Emulator
- Open Android Studio → Device Manager → Click Play icon
- OR: `"$env:ANDROID_HOME\emulator\emulator.exe" -avd Pixel_6_API_33 -gpu on -audio-in default`

**App will launch with 5 tabs:**
1. **Today** - Daily brief + reminders
2. **Home** - Text input + voice recording
3. **Memories** - List all memories
4. **Search** - Find memories
5. **Assistant** - Ask questions

---

## 📝 Testing Text First (Easier)

### Test 1: Type & Save
```
Home Tab → Type: "Lunch with Sarah tomorrow at 12 PM"
→ Tap "Add Memory"
→ See: ✓ Response in green
```

### Test 2: View Saved
```
Memories Tab → Should show:
  - Text: "Lunch with Sarah tomorrow at 12 PM"
  - Type: meeting
  - Person: Sarah
  - Time: tomorrow at 12 PM
  - Reminder: yes
```

### Test 3: Search
```
Search Tab
→ Type: "Sarah"
→ Tap Search
→ See your memory in results
```

### Test 4: Ask
```
Assistant Tab
→ Type: "When is my lunch with Sarah?"
→ Tap "Analyze Conversation"
→ See: Answer + Citation to memory #1
```

---

## 🎤 Then Test Voice (If You Have Microphone)

### Setup Voice (One Time)
1. **Android emulator:** Start with `... -audio-in default`
2. **Permission:** Click "Allow" when app asks for microphone
3. **Backend:** Running (same as text testing)

### Test 1: Record & Save
```
Home Tab → Voice Module
→ Tap "Start Recording"
→ Speak: "Dinner with Parents Friday evening"
→ Tap "Stop Recording"
→ Tap "Send Voice Chunk"
→ Status: ✓ "Voice chunk #1 saved"
```

### Test 2: See Saved Voice
```
Memories Tab → Should show:
  - Text: (your voice transcribed)
  - Same extraction as text mode!
  - Person: Parents
  - Time: Friday evening
  - Type: meeting
```

### Test 3: Advanced - Always-On Mode
```
Home Tab → Voice Module
→ Toggle "Always-on mode" ON
→ Status: "Listening for 'Hey EchoMind'..."
→ Speak: "Hey EchoMind, remind me to call John"
→ System auto-records & saves
```

---

## ✅ Complete Testing Checklist

### Text Mode (No Microphone Needed)
- [ ] Add text memory
- [ ] View in Memories list
- [ ] Search by keyword
- [ ] Ask assistant question
- [ ] See daily brief

### Voice Mode (With Microphone)
- [ ] Grant microphone permission
- [ ] Record voice clip
- [ ] Send voice clip
- [ ] See transcription in Memories
- [ ] Search voice memory
- [ ] Enable always-on mode
- [ ] Say wake word "Hey EchoMind"

### Advanced
- [ ] Reminders marked if appropriate
- [ ] Assistant citations work
- [ ] Deep links to memory detail pages
- [ ] Search finds all memory types

---

## 🔧 Troubleshooting

### Backend won't start
```powershell
# Check if port 5000 is busy
netstat -ano | findstr :5000

# Check Python venv
cd backend && & .\.venv\Scripts\Activate.ps1
python -c "import flask; print('Flask OK')"
```

### App can't find backend
```
Mobile app endpoint should be: http://10.0.2.2:5000
Check: mobile_app/lib/api_service.dart line 52-60
```

### No recording permissions
```
Settings → Apps → Wearable Memory Assistant
→ Permissions → Microphone → Allow
→ Restart app
```

### Audio not working on emulator
```
Make sure emulator started with: -audio-in default
OR: Android Studio → Settings → Audio input: Auto-detect
```

---

## 📂 Key Files

| File | Purpose | Edit? |
|------|---------|-------|
| `backend/app.py` | API routes + voice handling | ✅ Done |
| `backend/services/audio_service.py` | Vosk transcription | ✅ Ready |
| `backend/services/nlp_service.py` | Extract person/time | ✅ Ready |
| `mobile_app/lib/main.dart` | UI + voice recording | ✅ Ready |
| `mobile_app/lib/api_service.dart` | Backend client | ✅ Ready |
| `mobile_app/android/AndroidManifest.xml` | Permissions | ✅ Done |

---

## 🧠 How It Works

### Text Flow
```
User Types → NLP Extract → Save DB → Search/Ask
```

### Voice Flow
```
User Records → Vosk Transcribe → NLP Extract → Save DB → Search/Ask
```

### Wake-Word Flow
```
Always-On Listening → "Hey EchoMind" Detected → Auto-Record → Save
```

---

## 🎯 Common Tasks

### Add Memory (Text)
1. Home tab
2. Type in "Typed memory" field
3. Tap "Add Memory"
4. See status response

### Add Memory (Voice)
1. Home tab → Voice Module
2. Tap "Start Recording"
3. Speak clearly
4. Tap "Stop Recording"
5. Tap "Send Voice Chunk"
6. See transcription in green

### Find Memory
1. Search tab
2. Type keyword (person name, action, etc.)
3. Tap Search
4. Results sorted by relevance

### Ask Question
1. Assistant tab
2. Type question about memories
3. Tap "Analyze Conversation"
4. See answer + source citations

---

## 🔑 Voice Endpoints (Backend)

| Endpoint | Input | Output |
|----------|-------|--------|
| `/ingest_audio_chunk` | Audio file | Transcription + Memory ID |
| `/detect_wake_word` | Audio file | Detected: true/false |
| `/ingest_audio_stream_chunk` | Raw audio bytes | Partial transcription |
| `/finalize_audio_session` | Session ID | Final transcription + Memory |

All endpoints return JSON with error messages on failure.

---

## 💾 Database

**Location:** `backend/data/memories.db`

**Schema:**
```sql
memories (
  id INTEGER PRIMARY KEY,
  text TEXT,                    -- Transcribed or typed
  type TEXT,                    -- meeting, call, reminder, general
  person TEXT,                  -- Extracted name
  time TEXT,                    -- Extracted time
  is_reminder INTEGER,          -- 0 or 1
  priority TEXT,                -- high, medium, low
  due_time TEXT,                -- ISO datetime for reminders
  status TEXT,                  -- captured, pending, completed
  embedding TEXT,               -- Vector for semantic search (optional)
  timestamp TEXT                -- Creation time
)
```

Auto-created on first run. Migrations handled automatically.

---

## 🌐 Network Endpoints

| Device | Endpoint | Use |
|--------|----------|-----|
| Android Emulator | `http://10.0.2.2:5000` | Default (auto-configured) |
| Physical Android | `http://192.168.x.x:5000` | Update `_lanIp` in app |
| PC / Testing | `http://127.0.0.1:5000` | Local testing |

---

## 📊 Status

| Component | Status | Notes |
|-----------|--------|-------|
| Backend API | ✅ Ready | All endpoints with error handling |
| Voice Recording | ✅ Ready | Uses `record` package |
| Speech-to-Text | ✅ Ready | Uses Vosk (offline) |
| Wake Word Detection | ✅ Ready | "Hey EchoMind" pattern match |
| NLP Extraction | ✅ Ready | spaCy + regex fallback |
| Memory Storage | ✅ Ready | SQLite database |
| Search | ✅ Ready | Keyword + semantic (optional) |
| Assistant | ✅ Ready | Deterministic + LLM (optional) |

---

## 🚀 Next Steps

1. **Text testing first** (easier, no mic needed)
2. **Voice testing** (if microphone available)
3. **Always-on mode** (advanced, drains battery)
4. **Physical device** (better voice quality)
5. **Optimize** (add settings, noise suppression, etc.)

---

## 📖 Full Documentation

- [ANDROID_SETUP.md](ANDROID_SETUP.md) - Detailed Android setup
- [TESTING_GUIDE.md](TESTING_GUIDE.md) - Testing without voice
- [VOICE_TESTING.md](VOICE_TESTING.md) - Voice module testing
- [QUICK_REF.md](QUICK_REF.md) - One-page cheat sheet

---

## 🎓 Example Conversations

### Example 1: Text + Search
```
Add: "Meet Rahul tomorrow at 4 PM"
Search: "Rahul"
Result: Memory with type=meeting, person=Rahul, time=tomorrow at 4 PM
```

### Example 2: Voice + Ask
```
Record: "Dinner with Sarah Friday evening"
Ask: "What am I doing Friday evening?"
Answer: "The most relevant memory is about dinner with Sarah Friday evening"
Citation: Memory #2
```

### Example 3: Wake Word + Always-On
```
Enable: Always-on mode (listens continuously)
Say: "Hey EchoMind, remember to call Mom"
System: Auto-saves as reminder, type=call, person=Mom
Shows: "Voice chunk #3 saved. Reminder: yes (high)"
```

---

## 🎉 You're All Set!

Everything is configured and ready to test. Choose:

**Easy Start:** Text only (no microphone)
```powershell
.\run_backend.ps1  # Terminal 1
# Then:
cd mobile_app && flutter run  # Terminal 2
# Then: Type memories in Home tab
```

**Full Featured:** Text + Voice (with microphone)
```powershell
# Same as above, plus grant microphone permission when prompted
# Then: Record voice memories in Home tab
```

**Advanced:** Always-on mode
```
Home tab → Voice Module → Toggle "Always-on mode"
Say: "Hey EchoMind, <your message>"
System auto-records and saves!
```

---

**Ready to start?** Pick your approach and go! 🚀

Created: April 1, 2026
