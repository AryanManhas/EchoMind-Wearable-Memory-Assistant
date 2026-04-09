# 🧪 Testing Both: Backend API + Android App

## ✅ Backend Status: RUNNING
Server is running at `http://127.0.0.1:5000`

---

## 1️⃣ Test Backend API First

### Quick API Tests (Copy-paste these commands):

```bash
# Test basic functionality
curl -X POST http://127.0.0.1:5000/add -H "Content-Type: application/json" -d '{"text": "Call John tomorrow"}'

# Test NEW Phase 1 improvements
curl -X POST http://127.0.0.1:5000/add -H "Content-Type: application/json" -d '{"text": "Coffee with Sarah"}'

curl -X POST http://127.0.0.1:5000/add -H "Content-Type: application/json" -d '{"text": "Email report ASAP"}'

curl -X POST http://127.0.0.1:5000/add -H "Content-Type: application/json" -d '{"text": "Lunch with team next week"}'

# Test search
curl -X POST http://127.0.0.1:5000/search -H "Content-Type: application/json" -d '{"query": "meeting"}'

# Test today's reminders
curl http://127.0.0.1:5000/today
```

### Expected Results:

**Before Phase 1:**
- "Coffee with Sarah" → `{"type": "general"}` ❌

**After Phase 1:**
- "Coffee with Sarah" → `{"type": "meeting"}` ✅
- "Email report ASAP" → `{"time": "today"}` ✅
- "Lunch with team next week" → `{"time": "+7 days"}` ✅

---

## 2️⃣ Test Android App

### Setup Android Testing:

1. **Start Android Emulator:**
   ```bash
   # In Android Studio: Tools → Device Manager → Start your emulator
   # Or use command line:
   emulator -avd YourEmulatorName
   ```

2. **Build and Run Flutter App:**
   ```bash
   cd mobile_app
   flutter run
   ```

3. **Network Configuration:**
   - Android emulator uses `10.0.2.2:5000` to reach host machine
   - Your backend is running on `127.0.0.1:5000` (host)
   - Android app should automatically use correct endpoint

### Test Scenarios in Android App:

#### 🗣️ Voice Testing:
1. **Tap microphone button** on Home screen
2. **Say:** "Coffee with Sarah tomorrow"
   - Should extract: Type=meeting, Person=Sarah, Time=tomorrow ✅
3. **Say:** "Email the report ASAP"
   - Should extract: Type=reminder, Time=today ✅
4. **Say:** "Lunch with team next week"
   - Should extract: Type=meeting, Time=+7 days ✅

#### ✍️ Text Testing:
1. **Type in text field:** "Discuss budget with Mark"
   - Should extract: Type=meeting, Person=Mark ✅
2. **Type:** "Call John soon"
   - Should extract: Type=call, Person=John, Time=+3 days ✅

#### 🔍 Search Testing:
1. **Go to Search tab**
2. **Search:** "meeting"
   - Should find all meeting-type memories ✅

#### 📅 Today Tab Testing:
1. **Go to Today tab**
2. **Should show today's reminders**
3. **Add:** "Call mom tonight"
   - Should appear in Today tab ✅

---

## 3️⃣ Voice Module Testing

### Wake Word Detection:
```bash
# Test wake word endpoint
curl -X POST http://127.0.0.1:5000/detect_wake_word -H "Content-Type: application/json" -d '{"audio_data": "base64_encoded_audio_here"}'
```

### Full Voice Flow (Android):
1. **Enable always-on mode** (switch in app)
2. **Say:** "Hey EchoMind, coffee with Sarah"
   - Should detect wake word ✅
   - Should transcribe "coffee with Sarah" ✅
   - Should extract: Type=meeting, Person=Sarah ✅

---

## 4️⃣ Troubleshooting

### If Backend Not Responding:
```bash
# Check if backend is running
curl http://127.0.0.1:5000/
# Should return: {"message": "EchoMind API", "status": "running"}
```

### If Android Can't Connect:
- **Check emulator network:** Android uses `10.0.2.2` for host
- **Verify backend IP:** Should be `127.0.0.1:5000` on host
- **Check firewall:** May need to allow port 5000

### If Voice Not Working:
```bash
# Test voice endpoints
curl -X POST http://127.0.0.1:5000/ingest_audio_chunk -F "audio=@test.wav"
```

---

## 5️⃣ Success Criteria

### ✅ API Tests Pass:
- [ ] "Coffee with Sarah" returns `{"type": "meeting"}`
- [ ] "Email ASAP" returns `{"time": "today"}`
- [ ] Search works and returns results
- [ ] Today endpoint returns reminders

### ✅ Android App Tests Pass:
- [ ] Text input works with new NLP
- [ ] Voice recording works
- [ ] Search tab shows results
- [ ] Today tab shows reminders
- [ ] Wake word detection works (if enabled)

### ✅ Voice Module Tests Pass:
- [ ] Audio transcription works
- [ ] Wake word detection works
- [ ] Streaming audio works
- [ ] Always-on mode works

---

## 🎯 Quick Test Script

Run this to test all endpoints:

```bash
#!/bin/bash
echo "🧪 Testing EchoMind API..."

# Test basic add
echo "Testing basic add..."
curl -s -X POST http://127.0.0.1:5000/add -H "Content-Type: application/json" -d '{"text": "Test memory"}' | jq .

# Test Phase 1 improvements
echo "Testing Phase 1: Coffee with Sarah..."
curl -s -X POST http://127.0.0.1:5000/add -H "Content-Type: application/json" -d '{"text": "Coffee with Sarah"}' | jq .

echo "Testing Phase 1: Email ASAP..."
curl -s -X POST http://127.0.0.1:5000/add -H "Content-Type: application/json" -d '{"text": "Email report ASAP"}' | jq .

# Test search
echo "Testing search..."
curl -s -X POST http://127.0.0.1:5000/search -H "Content-Type: application/json" -d '{"query": "meeting"}' | jq .

echo "✅ API tests complete!"
```

---

## 🚀 Ready to Test!

**Start with API tests first** - they're faster and easier to debug.

**Then test Android app** - use the emulator for voice testing.

**Report back:** What works? What doesn't? Any errors?

Let's make sure everything is working before moving to Phase 1-2! 🎉