# EchoMind Pipeline Testing Guide

## Complete End-to-End Pipeline Test

This guide demonstrates testing the complete pipeline from input to final output (Recall + Reminders).

### Prerequisites
1. Backend running on `http://10.0.2.2:5000` (Android) or `http://127.0.0.1:5000` (Web/iOS)
2. Ollama running (optional, for LLM processing)
3. curl installed (for testing)

---

## Test 1: Pipeline Info - Get Architecture Details

**Purpose**: Verify pipeline configuration and enabled stages

```bash
curl -X GET http://127.0.0.1:5000/pipeline/info
```

**Expected Response**:
```json
{
  "pipeline_name": "EchoMind Memory Assistant",
  "version": "1.0.0",
  "stages": [
    {
      "stage": 1,
      "name": "Wearable Device (Mic)",
      "description": "Audio input capture from wearable device",
      "enabled": true
    },
    {
      "stage": 2,
      "name": "Speech-to-Text (Whisper/ASR)",
      "description": "Convert audio to text using Vosk ASR",
      "enabled": true,
      "model": "vosk-model-small-en-us-0.15"
    },
    ...all 7 stages...
  ],
  "database": {
    "type": "SQLite",
    "path": "./data/memories.db"
  }
}
```

---

## Test 2: Complete Pipeline Query - Full Flow

**Purpose**: Execute complete pipeline with a query and see all 7 stages

### Step 1: Add Some Sample Memories First

```bash
curl -X POST http://127.0.0.1:5000/add \
  -H "Content-Type: application/json" \
  -d '{"text": "Meet with John tomorrow at 2 PM to discuss project timeline"}'
```

```bash
curl -X POST http://127.0.0.1:5000/add \
  -H "Content-Type: application/json" \
  -d '{"text": "Call Sarah on Friday morning about the marketing campaign"}'
```

```bash
curl -X POST http://127.0.0.1:5000/add \
  -H "Content-Type: application/json" \
  -d '{"text": "Remember to submit expense report by next Monday"}'
```

### Step 2: Execute Pipeline Query

```bash
curl -X POST http://127.0.0.1:5000/pipeline/query \
  -H "Content-Type: application/json" \
  -d '{"query": "When do I meet John?"}'
```

**Expected Response**: Complete pipeline flow showing:

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
        "time": "tomorrow",
        "priority": "medium"
      },
      "5_vector_database": {
        "embedding_enabled": true,
        "total_memories": 3,
        "memories_with_embeddings": 3
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
      "answer": "You have a meeting with John tomorrow at 2 PM to discuss the project timeline.",
      "source": "ollama",
      "retrieved_memories": [
        {
          "id": 1,
          "text": "Meet with John tomorrow at 2 PM to discuss project timeline",
          "type": "meeting",
          "person": "John",
          "time": "tomorrow at 2 PM",
          "is_reminder": true,
          "priority": "medium",
          "status": "pending"
        }
      ],
      "citations": [1]
    },
    "reminders": {
      "pending_count": 2,
      "relevant_reminders": [
        {
          "id": 1,
          "text": "Meet with John tomorrow at 2 PM to discuss project timeline",
          "is_reminder": true,
          "priority": "medium"
        }
      ],
      "all_pending": [
        {
          "id": 1,
          "text": "Meet with John tomorrow at 2 PM to discuss project timeline",
          "is_reminder": true,
          "priority": "medium"
        },
        {
          "id": 3,
          "text": "Remember to submit expense report by next Monday",
          "is_reminder": true,
          "priority": "high"
        }
      ]
    }
  },
  "metadata": {
    "query": "When do I meet John?",
    "timestamp": "2026-04-01T10:30:00.000000"
  }
}
```

---

## Test 3: Audio Input Pipeline

**Purpose**: Test complete pipeline starting from audio (Stage 1 → 2 → ... → 7)

```bash
# Assuming you have an audio file 'reminder.wav'
curl -X POST http://127.0.0.1:5000/ingest_audio_chunk \
  -F "audio=@reminder.wav" \
  -F "session_id=test_session_1" \
  -F "chunk_index=0" \
  -F "speaker=user"
```

**Expected Response** - Shows stages 1-4 completion:
```json
{
  "saved": true,
  "id": 4,
  "session_id": "test_session_1",
  "chunk_index": 0,
  "speaker": "user",
  "transcript": "Meet with John tomorrow at 2 PM",
  "is_reminder": true,
  "priority": "medium",
  "response": "Saved: meeting with John tomorrow at 2 PM"
}
```

---

## Test 4: Query with Reminders

**Purpose**: Test Stage 7 output specifically (Recall + Reminders)

```bash
curl -X POST http://127.0.0.1:5000/pipeline/query \
  -H "Content-Type: application/json" \
  -d '{"query": "What are my pending reminders?"}'
```

**Expected Response** - Emphasizes reminders:
```json
{
  "output": {
    "recall": {
      "answer": "You have 2 pending reminders: meeting with John tomorrow, and submit expense report by Monday.",
      "source": "ollama",
      "retrieved_memories": [...]
    },
    "reminders": {
      "pending_count": 2,
      "relevant_reminders": [
        {
          "id": 1,
          "text": "Meet with John tomorrow at 2 PM to discuss project timeline",
          "is_reminder": true,
          "priority": "medium"
        },
        {
          "id": 3,
          "text": "Remember to submit expense report by next Monday",
          "is_reminder": true,
          "priority": "high"
        }
      ],
      "all_pending": [...]
    }
  }
}
```

---

## Test 5: Quick Brief (Fast Recall)

**Purpose**: Test quick summary (Stage 7 optimized for speed)

```bash
curl -X GET http://127.0.0.1:5000/brief
```

**Expected Response**:
```json
{
  "message": "You have 2 pending reminders. Top item: Meet with John tomorrow at 2 PM to discuss project timeline",
  "reminders": [
    {
      "id": 1,
      "text": "Meet with John tomorrow at 2 PM to discuss project timeline",
      "is_reminder": true,
      "priority": "medium"
    },
    {
      "id": 3,
      "text": "Remember to submit expense report by next Monday",
      "is_reminder": true,
      "priority": "high"
    }
  ]
}
```

---

## Test 6: Semantic Search (Stage 6)

**Purpose**: Test query system with semantic search

```bash
curl -X POST http://127.0.0.1:5000/search \
  -H "Content-Type: application/json" \
  -d '{"query": "meetings this week"}'
```

**Expected Response** - Shows Stage 6 retrieval:
```json
{
  "query": "meetings this week",
  "results": [
    {
      "id": 1,
      "text": "Meet with John tomorrow at 2 PM to discuss project timeline",
      "type": "meeting",
      "person": "John",
      "score": 0.92,
      "is_reminder": true
    },
    {
      "id": 2,
      "text": "Call Sarah on Friday morning about the marketing campaign",
      "type": "call",
      "person": "Sarah",
      "score": 0.85,
      "is_reminder": true
    }
  ]
}
```

---

## Test 7: Today's Reminders

**Purpose**: Test reminder filtering for current day

```bash
curl -X GET http://127.0.0.1:5000/reminders/today
```

**Expected Response** - Only today's reminders:
```json
{
  "count": 1,
  "reminders": [
    {
      "id": 1,
      "text": "Meet with John tomorrow at 2 PM to discuss project timeline",
      "type": "meeting",
      "person": "John",
      "is_reminder": true,
      "priority": "medium",
      "due_time": "2026-04-02T14:00:00"
    }
  ]
}
```

---

## Test 8: Ask Assistant (LLM Processing)

**Purpose**: Test Stage 3 LLM processing with context

```bash
curl -X POST http://127.0.0.1:5000/ask \
  -H "Content-Type: application/json" \
  -d '{"query": "Who should I contact about the marketing campaign?"}'
```

**Expected Response** - Shows LLM reasoning:
```json
{
  "query": "Who should I contact about the marketing campaign?",
  "answer": "Based on your memories, you should contact Sarah. You have a call scheduled with her on Friday morning about the marketing campaign.",
  "source": "ollama",
  "citations": [2],
  "retrieved": [
    {
      "id": 2,
      "text": "Call Sarah on Friday morning about the marketing campaign",
      "type": "call",
      "person": "Sarah"
    }
  ]
}
```

---

## Expected Pipeline Behavior

### Input → Processing → Output Flow

1. **Text Input** → `/add` → Stored as memory
2. **Audio Input** → `/ingest_audio_chunk` → ASR → Stored as memory
3. **Query Input** → `/pipeline/query` → 7-stage processing → Recall + Reminders

### Stage Performance

| Stage | Processing Time | Status |
|-------|-----------------|--------|
| 1. Wearable Mic | Instant | Input ready |
| 2. Speech-to-Text | 1-2s | Vosk ASR |
| 3. LLM Processing | 2-5s | Ollama |
| 4. Memory Structure | <100ms | NLP extraction |
| 5. Vector DB | ~50ms | Embeddings |
| 6. Query System | <100ms | Semantic search |
| 7. Output | <500ms | Recall + Reminders |

### Validation Checklist

- ✅ All 7 stages present in pipeline/query response
- ✅ Memories correctly extracted with type, person, time
- ✅ Embeddings created and searchable
- ✅ Semantic search returns relevant results
- ✅ LLM answer includes citations
- ✅ Reminders identified correctly
- ✅ Priority scoring working
- ✅ Due times in ISO 8601 format
- ✅ Audio transcription accurate
- ✅ Error handling graceful

---

## Troubleshooting

### Pipeline Query Returns Empty Results
- Check if memories have been added
- Verify embeddings are enabled: `curl http://127.0.0.1:5000/health`
- Check database connection

### LLM Not Responding
- Verify Ollama is running: `curl http://127.0.0.1:11434/api/tags`
- Check OLLAMA_URL in config.py
- Fallback to deterministic answers

### Audio Transcription Failing
- Check Vosk model exists
- Verify audio format is supported
- Check VOSK_MODEL_PATH in config.py

### Embeddings Not Working
- Verify embedding service is enabled
- Check sentence-transformers installation
- Monitor for CUDA/GPU issues

---

## Example Multi-Stage Test

**Complete workflow**:

```bash
# 1. Add memory
curl -X POST http://127.0.0.1:5000/add \
  -H "Content-Type: application/json" \
  -d '{"text": "Meet with John tomorrow at 2 PM"}'

# 2. Get pipeline info
curl -X GET http://127.0.0.1:5000/pipeline/info

# 3. Query complete pipeline
curl -X POST http://127.0.0.1:5000/pipeline/query \
  -H "Content-Type: application/json" \
  -d '{"query": "When is my next meeting?"}'

# 4. Get quick brief
curl -X GET http://127.0.0.1:5000/brief

# 5. Ask assistant with context
curl -X POST http://127.0.0.1:5000/ask \
  -H "Content-Type: application/json" \
  -d '{"query": "Who am I meeting?"}'
```

**Success**: All endpoints respond with complete pipeline data including recall and reminders.
