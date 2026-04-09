# EchoMind Pipeline Architecture

## Complete Data Flow Architecture

```
Wearable Device (Mic)
        ↓
Speech-to-Text (Whisper / ASR)
        ↓
LLM Processing (GPT / NLP)
        ↓
Memory Structuring (Tasks, Events, Entities)
        ↓
Vector Database (FAISS / Pinecone)
        ↓
Query System (Voice / Text)
        ↓
Output (Recall + Reminders)
```

## Pipeline Stages Explained

### Stage 1: Wearable Device (Mic)
**Input Capture** - Audio input from wearable device or mobile microphone
- **Endpoints**: `/add`, `/ingest_chunk`, `/ingest_audio_chunk`, `/ingest_audio_stream_chunk`
- **Service**: `AudioService`
- **Format**: WAV, MP3, or raw audio streams
- **Output**: Raw audio bytes

### Stage 2: Speech-to-Text (Whisper / ASR)
**Audio Transcription** - Convert audio to text using Vosk ASR
- **Service**: `AudioService.transcribe_audio()`
- **Model**: `vosk-model-small-en-us-0.15`
- **Features**: 
  - Offline processing (no internet required)
  - Real-time streaming support
  - Audio chunk processing
- **Output**: Transcribed text with confidence scores

**Wake Word Detection**: 
- Endpoint: `POST /detect_wake_word`
- Configured wake word: "hey echomind"

### Stage 3: LLM Processing (GPT / NLP)
**Intent & Context Processing** - Extract intent and structured data from text
- **Service**: `LLMService`
- **Provider**: Ollama (local) or OpenAI (configurable)
- **Model**: Configurable (default: local Ollama model)
- **Features**:
  - Context-aware question answering
  - Memory-grounded responses
  - Fallback to deterministic answer generation

**Endpoint**: `POST /ask`
```json
{
  "query": "Who did I meet with yesterday?",
  "memories": [...relevant_memories...]
}
```

### Stage 4: Memory Structuring
**Extract Tasks, Events, Entities** - Structure unstructured text into semantic components
- **Service**: `NLPService.extract_memory()`
- **Features**:
  - Entity extraction (Person, Date, Time)
  - Memory type classification (meeting, call, reminder, general)
  - Reminder detection (is_reminder flag)
  - Priority calculation
  - Time/date normalization

**Extracted Fields**:
```json
{
  "text": "Original transcribed text",
  "type": "meeting" | "call" | "reminder" | "general",
  "person": "Name of person/entity",
  "time": "Parsed time expression",
  "due_time": "ISO 8601 datetime",
  "is_reminder": true | false,
  "priority": "high" | "medium" | "low",
  "status": "pending" | "captured" | "completed",
  "importance_score": 0.0 - 1.0
}
```

### Stage 5: Vector Database (FAISS / Pinecone)
**Semantic Indexing & Storage** - Create embeddings and store memories
- **Service**: `EmbeddingService`
- **Models Supported**:
  - FAISS (local, fast)
  - Pinecone (cloud-based, scalable)
  - Sentence Transformers (embeddings)
- **Features**:
  - Semantic embedding generation
  - Vector storage and indexing
  - Cosine similarity search

**Endpoints**:
- `POST /add` - Add memory with embedding
- Database table: `memories` with `embedding` column (JSON)

### Stage 6: Query System (Voice / Text)
**Memory Retrieval** - Query using semantic or keyword search
- **Service**: `SearchService`
- **Search Types**:
  - **Semantic Search** (if embeddings enabled): Uses vector similarity
  - **Keyword/Fuzzy Search** (fallback): Text-based matching

**Endpoints**:
- `POST /search` - Search memories by query
- `GET /memories` - List all memories
- `GET /reminders/today` - Get today's reminders
- `GET /brief` - Get pending reminders brief

**Search Response**:
```json
{
  "query": "Meeting with John",
  "results": [
    {
      "id": 1,
      "text": "...",
      "type": "meeting",
      "person": "John",
      "time": "tomorrow at 2 PM",
      "score": 0.95,
      "is_reminder": true
    }
  ]
}
```

### Stage 7: Output (Recall + Reminders)
**Structured Response** - Return final results with recall and reminders
- **Components**:
  - **Recall**: Retrieved memories with LLM-generated answer
  - **Reminders**: Pending reminders relevant to query

**Main Endpoints**:

#### `/ask` - LLM-Powered Answer
```json
{
  "query": "What did I discuss?",
  "answer": "You discussed project timeline...",
  "source": "ollama" | "fallback",
  "citations": [1, 2, 3],
  "retrieved": [memory_objects...]
}
```

#### `/pipeline/query` - Complete Pipeline Output
Comprehensive endpoint showing all pipeline stages:
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
      "4_memory_structuring": {...},
      "5_vector_database": {...},
      "6_query_system": {...}
    }
  },
  "output": {
    "recall": {
      "answer": "...",
      "source": "...",
      "retrieved_memories": [...],
      "citations": [...]
    },
    "reminders": {
      "pending_count": 5,
      "relevant_reminders": [...],
      "all_pending": [...]
    }
  },
  "metadata": {
    "query": "...",
    "timestamp": "2026-04-01T..."
  }
}
```

#### `/pipeline/info` - Pipeline Architecture Info
Get complete pipeline configuration and metadata

#### `/brief` - Quick Recall Summary
```json
{
  "message": "You have 5 pending reminders. Top item: Call John tomorrow",
  "reminders": [...]
}
```

## Database Schema

### memories table
```
id                INTEGER PRIMARY KEY
text              TEXT NOT NULL
type              TEXT (meeting|call|reminder|general)
person            TEXT
time              TEXT (parsed time expression)
is_reminder       INTEGER (0|1)
priority          TEXT (high|medium|low)
due_time          TEXT (ISO 8601)
status            TEXT (captured|pending|completed)
embedding         TEXT (JSON array of floats)
timestamp         TEXT (ISO 8601)
```

## Configuration

### Environment Variables (config.py)
```python
ENABLE_EMBEDDINGS = True  # Enable vector database
EMBEDDING_MODEL = "sentence-transformers/all-MiniLM-L6-v2"
ENABLE_LLM = True         # Enable LLM service
LLM_PROVIDER = "ollama"   # "ollama" or "openai"
LLM_MODEL = "neural-chat" # Local or OpenAI model
OLLAMA_URL = "http://127.0.0.1:11434/api/generate"
VOSK_MODEL_PATH = "./vosk-model-small-en-us-0.15"
DB_PATH = "./data/memories.db"
```

## Usage Example: End-to-End Pipeline

### 1. Capture Audio
```bash
curl -X POST http://10.0.2.2:5000/add \
  -H "Content-Type: application/json" \
  -d '{"text": "Meet with John tomorrow at 2 PM"}'
```

### 2. Query Complete Pipeline
```bash
curl -X POST http://10.0.2.2:5000/pipeline/query \
  -H "Content-Type: application/json" \
  -d '{"query": "When do I meet John?"}'
```

**Response Shows**:
- Stage 3: Detected "meeting" type, Person "John"
- Stage 4: Structured memory with all fields
- Stage 5: Vector database status
- Stage 6: Semantic search results
- Stage 7: Final recall answer + reminders

### 3. Get Quick Brief
```bash
curl http://10.0.2.2:5000/brief
```

### 4. Voice Input (Complete Flow)
```bash
curl -X POST http://10.0.2.2:5000/ingest_audio_chunk \
  -F "audio=@audio.wav" \
  -F "session_id=session_1" \
  -F "chunk_index=1"
```

## Performance Metrics

- **Stage 2 (ASR)**: ~1-2 seconds per utterance
- **Stage 3 (LLM)**: ~2-5 seconds (with Ollama)
- **Stage 4 (NLP)**: <100ms
- **Stage 5 (Embeddings)**: ~50ms per text
- **Stage 6 (Search)**: <100ms (semantic) / <50ms (keyword)
- **Stage 7 (Output)**: <500ms

## Error Handling

Each stage has error handling:
- **Audio errors**: ASR failures, unsupported formats
- **NLP errors**: Extraction failures logged with fallbacks
- **Embedding errors**: Gracefully falls back to keyword search
- **LLM errors**: Deterministic fallback answer generation

## Privacy & Security

- All processing on-device (Vosk, local Ollama)
- No cloud dependencies required
- Embeddings stored in SQLite
- No external API calls for core pipeline

## Future Enhancements

1. **Multi-language support**: Add more Vosk models
2. **Custom LLM fine-tuning**: Personal memory assistant models
3. **Distributed embeddings**: Redis/Qdrant for scaling
4. **Advanced reminders**: Scheduling, notifications, recurring tasks
5. **Real-time streaming**: Continuous listening mode
6. **Mobile optimization**: On-device inference

