# 🚀 EchoMind Pipeline - Quick Start Guide

## Your Complete Pipeline Is Ready! 

Your EchoMind system now has a fully implemented 7-stage pipeline. Here's how to use it immediately.

---

## 📋 What Changed

### ✅ Backend Updates
- **New Endpoint**: `POST /pipeline/query` - Complete pipeline with all stages visible
- **New Endpoint**: `GET /pipeline/info` - Architecture info
- **All existing endpoints** continue to work (backward compatible)

### ✅ Mobile App Updates  
- **New Methods**: `pipelineQuery()` and `getPipelineInfo()` in ApiService
- **New Widget**: `PipelineVisualizationWidget` for visual pipeline display
- **New Screen**: `PipelineTestScreen` for testing

### ✅ Documentation
- `PIPELINE_ARCHITECTURE.md` - Complete technical guide
- `PIPELINE_QUICK_REF.md` - Quick reference (cheat sheet)
- `PIPELINE_TEST.md` - Testing guide with examples
- This file - Getting started guide

---

## 🎯 The Pipeline

```
🎙️ STAGE 1: Wearable Device (Mic)
   Input capture from device
   
   ↓
   
🗣️ STAGE 2: Speech-to-Text (ASR)
   Vosk transcription
   
   ↓
   
🧠 STAGE 3: LLM Processing
   Ollama/OpenAI for understanding
   
   ↓
   
📝 STAGE 4: Memory Structuring
   Extract: type, person, time, priority
   
   ↓
   
📊 STAGE 5: Vector Database
   FAISS embeddings & storage
   
   ↓
   
🔍 STAGE 6: Query System
   Semantic search retrieval
   
   ↓
   
💾 STAGE 7: Output (Recall + Reminders)
   Final answer + reminders summary
```

---

## ⚡ Quick Test (5 minutes)

### 1. Start the Backend
```bash
cd C:\Users\PC\Downloads\EchoMInd\backend
python app.py
```

### 2. In another terminal, add a memory
```bash
curl -X POST http://127.0.0.1:5000/add \
  -H "Content-Type: application/json" \
  -d '{"text": "Meet John tomorrow at 2 PM"}'
```

### 3. Query the complete pipeline
```bash
curl -X POST http://127.0.0.1:5000/pipeline/query \
  -H "Content-Type: application/json" \
  -d '{"query": "When do I meet John?"}'
```

### 4. View the response
You'll see:
- ✅ All 7 pipeline stages
- ✅ Extracted memory: type="meeting", person="John"
- ✅ Retrieved memories from vector DB
- ✅ LLM-generated answer
- ✅ Reminders list

**That's the complete pipeline running!** 🎉

---

## 🔗 Main Endpoints

| Endpoint | Purpose | Try It |
|----------|---------|--------|
| `GET /health` | System status | `curl http://127.0.0.1:5000/health` |
| `POST /add` | Add text memory | See Quick Test above |
| `POST /pipeline/query` | Complete pipeline | See Quick Test above |
| `GET /pipeline/info` | Architecture info | `curl http://127.0.0.1:5000/pipeline/info` |
| `GET /brief` | Quick summary | `curl http://127.0.0.1:5000/brief` |
| `POST /ask` | Ask with context | `curl -X POST http://127.0.0.1:5000/ask -H "Content-Type: application/json" -d '{"query": "What are my reminders?"}'` |

---

## 📊 Pipeline Query Response Structure

```json
{
  "pipeline": {
    "status": "complete",
    "stages": {
      "1_wearable_mic": "input_processed",
      "2_speech_to_text": "text_ready",
      "3_llm_processing": {
        "detected_type": "meeting",
        "detected_person": "John",
        "detected_time": "tomorrow 2 PM"
      },
      "4_memory_structuring": {
        "type": "meeting",
        "person": "John",
        "priority": "medium"
      },
      "5_vector_database": {
        "embedding_enabled": true,
        "total_memories": 1,
        "memories_with_embeddings": 1
      },
      "6_query_system": {
        "query_text": "When do I meet John?",
        "retrieved_count": 1,
        "search_type": "semantic"
      }
    }
  },
  
  "output": {
    "recall": {
      "answer": "You have a meeting with John tomorrow at 2 PM",
      "source": "ollama",
      "retrieved_memories": [...],
      "citations": [1]
    },
    "reminders": {
      "pending_count": 1,
      "relevant_reminders": [
        {
          "text": "Meet John tomorrow at 2 PM",
          "is_reminder": true,
          "priority": "medium"
        }
      ]
    }
  }
}
```

---

## 🎨 Mobile Integration

### Using in Flutter

```dart
import 'api_service.dart';

final api = ApiService();

// Query the complete pipeline
final result = await api.pipelineQuery("When do I meet John?");

// Get pipeline configuration
final info = await api.getPipelineInfo();

// Display in UI
showDialog(
  context: context,
  builder: (_) => PipelineVisualizationWidget(
    pipelineData: result,
  ),
);
```

---

## 🧪 Testing Scenarios

### Test 1: Text Input
```bash
curl -X POST http://127.0.0.1:5000/add \
  -H "Content-Type: application/json" \
  -d '{"text": "Call Sarah on Friday"}'
```

### Test 2: Audio Input (if file available)
```bash
curl -X POST http://127.0.0.1:5000/ingest_audio_chunk \
  -F "audio=@audio.wav" \
  -F "session_id=test_1" \
  -F "speaker=user"
```

### Test 3: Query Various Types
```bash
# Meeting query
curl -X POST http://127.0.0.1:5000/pipeline/query \
  -H "Content-Type: application/json" \
  -d '{"query": "What meetings do I have?"}'

# Person query
curl -X POST http://127.0.0.1:5000/pipeline/query \
  -H "Content-Type: application/json" \
  -d '{"query": "What do I need to do with John?"}'

# Reminder query
curl -X POST http://127.0.0.1:5000/pipeline/query \
  -H "Content-Type: application/json" \
  -d '{"query": "What are my pending reminders?"}'
```

---

## 📚 Documentation

For detailed information, see:

1. **PIPELINE_ARCHITECTURE.md** 
   - Detailed explanation of each stage
   - Database schema
   - Configuration options
   - Performance metrics

2. **PIPELINE_QUICK_REF.md**
   - API reference
   - Memory structure
   - Common queries
   - Troubleshooting

3. **PIPELINE_TEST.md**
   - 8+ test scenarios
   - Expected responses
   - Validation checklist
   - Multi-stage workflows

---

## 🔧 Configuration

No additional setup needed! Uses existing settings in `backend/config.py`:

```python
ENABLE_EMBEDDINGS = True          # Vector DB
EMBEDDING_MODEL = "..."           # Sentence transformers
ENABLE_LLM = True                 # LLM processing
LLM_PROVIDER = "ollama"          # or "openai"
VOSK_MODEL_PATH = "./vosk-..."   # Speech-to-text
DB_PATH = "./data/memories.db"   # Database
```

---

## ✨ Key Features

- ✅ **Complete Transparency**: See all 7 stages in each response
- ✅ **Recall + Reminders**: Final output includes both
- ✅ **Memory Structuring**: Automatic type, person, time extraction
- ✅ **Semantic Search**: Vector embeddings powered retrieval
- ✅ **LLM Integration**: Context-aware answer generation
- ✅ **Backward Compatible**: All old endpoints still work
- ✅ **Flexible Input**: Text, audio, streaming support

---

## 🚨 Troubleshooting

### "Query is required"
- Make sure you send: `{"query": "your question"}`

### Empty results
- Add memories first with `/add` endpoint
- Then query them

### LLM not responding
- Check if Ollama is running
- Fallback answer will be generated automatically

### Embedding issues
- Set `ENABLE_EMBEDDINGS = False` to use keyword search instead

---

## 📊 Performance

Expected response times:
- **Pipeline Query**: 1-10 seconds (depending on LLM)
- **Quick Brief**: <500ms
- **Search**: <100ms
- **Memory Add**: <500ms

---

## 🎯 Example Workflow

```
User speaks: "Meet John tomorrow at 2 PM"
    ↓
[Pipeline runs through all 7 stages]
    ↓
System responds: "Saved: meeting with John tomorrow at 2 PM"
    ↓
User asks: "When do I meet John?"
    ↓
[Pipeline executes query through all stages]
    ↓
System returns:
  - Answer: "You have a meeting with John tomorrow at 2 PM"
  - Reminders: [John meeting at 2 PM tomorrow]
  - Source: LLM powered answer
```

---

## 🔗 Next: Dive Deeper

Now that you're running the pipeline:

1. **Test all endpoints** (see PIPELINE_TEST.md)
2. **Review architecture** (see PIPELINE_ARCHITECTURE.md)
3. **Integrate with UI** (see PipelineVisualizationWidget)
4. **Monitor metrics** (see performance section)

---

## 💡 Tips

- Use `/pipeline/info` to understand your configuration
- Use `/pipeline/query` for full transparency
- Use `/brief` for quick summaries
- Check memory field: `is_reminder` to distinguish reminders
- Check `priority` for importance ranking

---

## ✅ You're All Set!

Your complete 7-stage pipeline is ready:
1. ✅ Wearable input capture
2. ✅ Speech-to-text conversion
3. ✅ LLM processing
4. ✅ Memory structuring
5. ✅ Vector database storage
6. ✅ Semantic query system
7. ✅ Recall + Reminders output

**Start with the Quick Test above and explore!** 🚀

