# EchoMind Pipeline Quick Reference

## Pipeline Overview

```
🎙️ Wearable Mic → 🗣️ Speech-to-Text → 🧠 LLM → 📝 Structure → 🗂️ Vector DB → 🔍 Query → 💾 Recall + ⏰ Reminders
```

## Quick Start

### 1. Add Memory (Text)
```bash
curl -X POST http://10.0.2.2:5000/add \
  -H "Content-Type: application/json" \
  -d '{"text": "Meet John tomorrow at 2 PM"}'
```

### 2. Query Pipeline (Full Flow)
```bash
curl -X POST http://10.0.2.2:5000/pipeline/query \
  -H "Content-Type: application/json" \
  -d '{"query": "When do I meet John?"}'
```

### 3. Get Pipeline Info
```bash
curl -X GET http://10.0.2.2:5000/pipeline/info
```

## API Endpoints

| Endpoint | Method | Purpose | Stage |
|----------|--------|---------|-------|
| `/health` | GET | Check system status | - |
| `/add` | POST | Add text memory | 1-4 |
| `/ingest_audio_chunk` | POST | Add audio memory | 1-4 |
| `/detect_wake_word` | POST | Detect "hey echomind" | 2 |
| `/search` | POST | Semantic search | 6 |
| `/brief` | GET | Quick summary | 7 |
| `/ask` | POST | LLM answer | 3,6,7 |
| `/pipeline/query` | POST | Complete pipeline | All |
| `/pipeline/info` | GET | Architecture info | - |
| `/memories` | GET | List all memories | 4,5 |
| `/reminders/today` | GET | Today's reminders | 7 |
| `/memories/<id>` | GET | Get memory by ID | - |

## Memory Structure

All memories have this structure:

```json
{
  "id": 1,
  "text": "Original text",
  "type": "meeting|call|reminder|general",
  "person": "John",
  "time": "tomorrow at 2 PM",
  "is_reminder": true,
  "priority": "high|medium|low",
  "due_time": "2026-04-02T14:00:00",
  "status": "pending|captured|completed",
  "embedding": [0.1, 0.2, ...],
  "timestamp": "2026-04-01T10:00:00"
}
```

## Pipeline Query Response

```json
{
  "pipeline": {
    "status": "complete",
    "stages": {
      "1_wearable_mic": "input_processed",
      "2_speech_to_text": "text_ready",
      "3_llm_processing": {...},
      "4_memory_structuring": {...},
      "5_vector_database": {...},
      "6_query_system": {...}
    }
  },
  "output": {
    "recall": {
      "answer": "...",
      "source": "ollama|fallback",
      "retrieved_memories": [...]
    },
    "reminders": {
      "pending_count": 5,
      "relevant_reminders": [...]
    }
  }
}
```

## Memory Types

| Type | Keywords | Example |
|------|----------|---------|
| **meeting** | meet, discuss, sync, review | "Meet John tomorrow" |
| **call** | call, contact, reach out | "Call Sarah Friday" |
| **reminder** | remind, remember, don't forget | "Remember to submit report" |
| **general** | other | "The café opened today" |

## Priority Scoring

| Level | Score | Conditions |
|-------|-------|-----------|
| High | 0.7-1.0 | Meeting + Named person + Time |
| Medium | 0.4-0.7 | Reminder with time |
| Low | 0.0-0.4 | General notes |

## Flask Configuration

```python
# config.py
ENABLE_EMBEDDINGS = True
EMBEDDING_MODEL = "sentence-transformers/all-MiniLM-L6-v2"
ENABLE_LLM = True
LLM_PROVIDER = "ollama"  # or "openai"
LLM_MODEL = "neural-chat"
OLLAMA_URL = "http://127.0.0.1:11434/api/generate"
VOSK_MODEL_PATH = "./vosk-model-small-en-us-0.15"
DB_PATH = "./data/memories.db"
```

## Flutter Integration

```dart
// api_service.dart
final api = ApiService();

// Get full pipeline output
final pipelineResult = await api.pipelineQuery("When do I meet John?");

// Get pipeline architecture
final pipelineInfo = await api.getPipelineInfo();

// Quick ask
final reply = await api.askAssistant("What are my reminders?");
```

## Example: Complete Flow

### 1. User speaks to device
```
"Hey EchoMind, meet with John tomorrow at 2 PM"
```

### 2. Pipeline processes:
- Stage 1: Audio captured from mic
- Stage 2: Vosk transcribes to text
- Stage 3: LLM detects meeting type, person "John"
- Stage 4: Structured as meeting reminder
- Stage 5: Embedding created and stored
- Stage 6: Ready for semantic search
- Stage 7: Output reminder to user

### 3. Response includes:
✅ Detected type: "meeting"  
✅ Detected person: "John"  
✅ Detected time: "tomorrow at 2 PM"  
✅ Priority: "medium"  
✅ Status: "pending"  

### 4. User queries:
```
"When do I meet John?"
```

### 5. Pipeline executes:
- Retrieves stored meeting from vector DB
- LLM generates contextual answer
- Returns answer + reminders

---

## Common Queries

### Add via text
```bash
POST /add
{"text": "Meet John tomorrow"}
```

### Add via audio
```bash
POST /ingest_audio_chunk  
-F audio=audio.wav
-F session_id=session_1
-F speaker=user
```

### Query with LLM
```bash
POST /ask
{"query": "Who am I meeting?"}
```

### Get pipeline trace
```bash
POST /pipeline/query
{"query": "Show me my meetings"}
```

### Quick summary
```bash
GET /brief
```

### List all reminders
```bash
GET /reminders/today
```

---

## Performance Targets

| Operation | Target Time | Actual |
|-----------|------------|--------|
| Speech-to-text | 1-2s | ✅ With Vosk |
| LLM generation | 2-5s | ✅ With Ollama |
| Vector search | <100ms | ✅ FAISS |
| Memory structure | <100ms | ✅ NLP |
| Full pipeline | <10s | ✅ End-to-end |

---

## Troubleshooting

### "Query is required"
```
POST /ask without {"query": "..."}
Fix: Provide query in JSON body
```

### "No related memories found"
```
LLM fallback answer used
Check: Add memories first, then query
```

### "Audio transcription failed"
```
Vosk ASR error
Check: Audio format, Vosk model path
```

### Empty embeddings
```
Vector DB not available
Check: config.py ENABLE_EMBEDDINGS
Fix: pip install sentence-transformers
```

---

## Pipeline Endpoints Cheat Sheet

```bash
# Info
GET /health
GET /pipeline/info

# Add
POST /add                    # Text
POST /ingest_audio_chunk     # Audio file
POST /detect_wake_word       # Check for "hey echomind"

# Query & Retrieve
POST /search                 # Semantic search
POST /ask                    # LLM powered answer
POST /pipeline/query         # Full pipeline trace

# Browse
GET /memories                # All memories
GET /memories/<id>           # Single memory
GET /reminders/today         # Today's reminders
GET /brief                   # Quick summary
```

---

## Data Flow Example

```
User Input: "Meet John tomorrow at 2 PM"
    ↓
[Stage 2] Transcribed from audio ✓
    ↓
[Stage 3] LLM: Type=meeting, Person=John ✓
    ↓
[Stage 4] Structured:
  - type: "meeting"
  - person: "John"
  - time: "tomorrow at 2 PM"
  - priority: "medium"
  - due_time: "2026-04-02T14:00:00"
    ↓
[Stage 5] Embedding created: [0.12, 0.45, ...] ✓
    ↓
[Stage 6] Stored in vector DB, searchable ✓
    ↓
[Stage 7] Output:
  - Recall: "You have a meeting with John tomorrow at 2 PM"
  - Reminders: [John meeting scheduled tomorrow]
    ↓✅ Done
```

