# EchoMind Pipeline - Visual Diagram & Architecture

## Complete End-to-End Pipeline Flow

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                          ECHOMIND PIPELINE SYSTEM                          │
│                     (7-Stage Memory Processing Pipeline)                    │
└─────────────────────────────────────────────────────────────────────────────┘

┌──────────────┐     ┌──────────────┐     ┌──────────────┐     ┌────────────┐
│              │     │              │     │              │     │            │
│   INPUT      │────▶│  PROCESSING  │────▶│  STORAGE &   │────▶│   OUTPUT   │
│              │     │              │     │   RETRIEVAL  │     │            │
└──────────────┘     └──────────────┘     └──────────────┘     └────────────┘

   STAGES:           STAGES:              STAGES:               STAGES:
   1,2                3,4                  5                      6,7


═════════════════════════════════════════════════════════════════════════════

DETAILED PIPELINE WITH SERVICES & ENDPOINTS:

═════════════════════════════════════════════════════════════════════════════

   ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
   ┃ STAGE 1️⃣  : WEARABLE DEVICE (MIC)                                   ┃
   ┃ 🎙️ INPUT CAPTURE                                                    ┃
   ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛
   
   Audio Input Sources:
   ├─ Wearable Device Microphone
   ├─ Mobile Phone Microphone
   ├─ Real-time Audio Stream
   └─ Pre-recorded Audio Files
   
   APIs:
   ├─ POST /add (text/json)
   ├─ POST /ingest_audio_chunk
   ├─ POST /ingest_audio_stream_chunk
   └─ POST /detect_wake_word
   
                              ↓ Audio Data ↓
   

   ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
   ┃ STAGE 2️⃣  : SPEECH-TO-TEXT (WHISPER / ASR)                          ┃
   ┃ 🗣️ TRANSCRIPTION                                                     ┃
   ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛
   
   Service: AudioService
   Model: Vosk (vosk-model-small-en-us-0.15)
   
   Processing:
   ├─ Offline ASR (no internet required)
   ├─ Real-time streaming support
   ├─ Confidence scoring
   └─ Chunk-based processing
   
   Output:
   {
     "text": "Meet with John tomorrow at 2 PM",
     "chunks": [...audio segments...],
     "confidence": 0.92
   }
   
                     ↓ Transcribed Text ↓
   

   ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
   ┃ STAGE 3️⃣  : LLM PROCESSING (GPT / NLP)                              ┃
   ┃ 🧠 INTENT & CONTEXT UNDERSTANDING                                    ┃
   ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛
   
   Service: LLMService
   
   Providers:
   ├─ Ollama (Local, offline)
   |  └─ Model: neural-chat or custom
   └─ OpenAI (Cloud, optional)
      └─ Model: GPT-3.5, GPT-4
   
   Processing:
   ├─ Intent detection
   ├─ Context understanding
   ├─ Memory-grounded responses
   └─ Answer generation from context
   
   Output:
   {
     "type": "meeting",
     "intent": "schedule_meeting",
     "entities": {
       "person": "John",
       "action": "meet",
       "time": "tomorrow at 2 PM"
     }
   }
   
                  ↓ Extracted Intent & Entities ↓
   

   ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
   ┃ STAGE 4️⃣  : MEMORY STRUCTURING (TASKS, EVENTS, ENTITIES)             ┃
   ┃ 📝 INFORMATION EXTRACTION                                             ┃
   ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛
   
   Service: NLPService
   Features:
   ├─ Named Entity Recognition (NER)
   ├─ Temporal Expression Parsing
   ├─ Memory Type Classification
   ├─ Priority Scoring
   └─ Time Normalization
   
   Extracted Fields:
   ├─ type: meeting|call|reminder|general
   ├─ person: Named entities
   ├─ time: Natural language time
   ├─ priority: high|medium|low
   ├─ status: pending|captured|completed
   ├─ is_reminder: true|false
   └─ due_time: ISO 8601 timestamp
   
   Example Output:
   {
     "text": "Meet with John tomorrow at 2 PM",
     "type": "meeting",
     "person": "John",
     "time": "tomorrow at 2 PM",
     "priority": "medium",
     "due_time": "2026-04-02T14:00:00",
     "is_reminder": true,
     "status": "pending",
     "importance_score": 0.75
   }
   
                 ↓ Structured Memory Object ↓
   

   ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
   ┃ STAGE 5️⃣  : VECTOR DATABASE (FAISS / PINECONE)                       ┃
   ┃ 📊 EMBEDDING & STORAGE                                               ┃
   ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛
   
   Service: EmbeddingService
   
   Embedding Models:
   ├─ FAISS (Local, fast)
   |  └─ sentence-transformers/all-MiniLM-L6-v2
   └─ Pinecone (Cloud, scalable)
      └─ Optional cloud integration
   
   Processing:
   ├─ Convert text to 384-dim vectors
   ├─ Store in vector database
   ├─ Build similarity indices
   └─ Enable semantic search
   
   Storage:
   Database: SQLite (memories table)
   Fields:
   ├─ id: Integer
   ├─ text: String
   ├─ type: String
   ├─ person: String
   ├─ time: String
   ├─ is_reminder: Integer
   ├─ priority: String
   ├─ due_time: String
   ├─ status: String
   ├─ embedding: JSON (float array)
   └─ timestamp: ISO 8601
   
                    ↓ Indexed in Vector DB ↓
   

   ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
   ┃ STAGE 6️⃣  : QUERY SYSTEM (VOICE / TEXT)                              ┃
   ┃ 🔍 SEMANTIC & KEYWORD RETRIEVAL                                      ┃
   ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛
   
   Service: SearchService
   
   Query Input:
   ├─ Voice: "When do I meet John?" (transcribed)
   └─ Text: Direct text query
   
   Search Methods:
   ├─ Semantic Search (if embeddings enabled)
   │  ├─ Convert query to vector
   │  ├─ Compute cosine similarity
   │  ├─ Rank by relevance score
   │  └─ Return top-K results
   └─ Keyword/Fuzzy Search (fallback)
      ├─ Text matching
      ├─ Token-based ranking
      └─ Similarity scoring
   
   Output:
   [
     {
       "id": 1,
       "text": "Meet with John tomorrow at 2 PM",
       "type": "meeting",
       "person": "John",
       "score": 0.95,
       "is_reminder": true
     }
   ]
   
                  ↓ Relevant Memories Retrieved ↓
   

   ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
   ┃ STAGE 7️⃣  : OUTPUT (RECALL + REMINDERS)                              ┃
   ┃ 💾 FINAL RESULTS                                                      ┃
   ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛
   
   Component A: RECALL
   ├─ LLM-Generated Answer
   |  └─ "You have a meeting with John tomorrow at 2 PM"
   ├─ Source Attribution
   |  └─ "ollama" OR "fallback"
   ├─ Retrieved Memories
   |  └─ [memory objects...]
   └─ Citations
      └─ [memory IDs...]
   
   Component B: REMINDERS
   ├─ Pending Count
   |  └─ 2 pending reminders
   ├─ Relevant Reminders (filtered to query)
   |  └─ [John meeting for tomorrow]
   └─ All Pending (top 5)
      └─ [John meeting, expense report, ...]
   
   APIs:
   ├─ POST /ask (LLM-powered answer)
   ├─ POST /pipeline/query (complete pipeline)
   ├─ GET /brief (quick summary)
   ├─ GET /reminders/today (today's reminders)
   └─ GET /memories (all memories)
   
   Final Response:
   {
     "pipeline": {...all 7 stages...},
     "output": {
       "recall": {
         "answer": "...",
         "source": "ollama",
         "retrieved_memories": [...],
         "citations": [1]
       },
       "reminders": {
         "pending_count": 2,
         "relevant_reminders": [...],
         "all_pending": [...]
       }
     }
   }

═════════════════════════════════════════════════════════════════════════════

API ENDPOINT FLOW DIAGRAM:

═════════════════════════════════════════════════════════════════════════════

Input Entry Points:
│
├─ POST /add (text input)
├─ POST /ingest_audio_chunk (audio file)
├─ POST /ingest_audio_stream_chunk (streaming)
└─ POST /detect_wake_word (wake word)
   │
   └──▶ Stages 1-4 ──▶ Storage
         │
         └──▶ Stage 5 ──▶ Vector DB
             │
             └──▶ Ready for queries

Query Entry Points:
│
├─ POST /pipeline/query (complete pipeline)
│  └──▶ Stages 1-7 with transparency
├─ POST /ask (LLM answer)
│  └──▶ Stages 5-7
├─ POST /search (semantic search)
│  └──▶ Stage 6
├─ GET /brief (quick summary)
│  └──▶ Stage 7 optimized
└─ GET /reminders/today (today's reminders)
   └──▶ Stage 7 filtered

═════════════════════════════════════════════════════════════════════════════

DATA FLOW EXAMPLE:

═════════════════════════════════════════════════════════════════════════════

User Input:
┌─────────────────────────────────────────────────────────────────┐
│ "Meet with John tomorrow at 2 PM to discuss the project"       │
└─────────────────────────────────────────────────────────────────┘

Stage 1-2: Audio ──▶ Text
┌─────────────────────────────────────────────────────────────────┐
│ Text: "Meet with John tomorrow at 2 PM to discuss the project" │
└─────────────────────────────────────────────────────────────────┘

Stage 3: LLM Processing
┌─────────────────────────────────────────────────────────────────┐
│ Intent: SCHEDULE_MEETING                                        │
│ Type: meeting                                                   │
│ Person: John                                                    │
│ Time: tomorrow at 2 PM                                          │
│ Action: discuss project                                         │
└─────────────────────────────────────────────────────────────────┘

Stage 4: Memory Structuring
┌─────────────────────────────────────────────────────────────────┐
│ {                                                               │
│   "type": "meeting",                                            │
│   "person": "John",                                             │
│   "time": "tomorrow at 2 PM",                                   │
│   "priority": "medium",                                         │
│   "due_time": "2026-04-02T14:00:00",                           │
│   "is_reminder": true,                                          │
│   "status": "pending"                                           │
│ }                                                               │
└─────────────────────────────────────────────────────────────────┘

Stage 5: Vector DB
┌─────────────────────────────────────────────────────────────────┐
│ Embedding: [0.12, 0.45, ..., 0.78] (384 dimensions)            │
│ Stored in memories table with ID=1                              │
└─────────────────────────────────────────────────────────────────┘

Stage 6: Query
User: "When do I meet John?"
┌─────────────────────────────────────────────────────────────────┐
│ Query Embedding: [0.14, 0.48, ..., 0.81]                       │
│ Similarity with ID=1: 0.94 (very high match!)                  │
│ Retrieved: [Memory#1 with John meeting]                         │
└─────────────────────────────────────────────────────────────────┘

Stage 7: Output
┌─────────────────────────────────────────────────────────────────┐
│ RECALL:                                                         │
│ • Answer: "You have a meeting with John tomorrow at 2 PM"      │
│ • Source: LLM (ollama)                                          │
│ • Retrieved: [Memory#1]                                         │
│                                                                 │
│ REMINDERS:                                                      │
│ • Pending: 1                                                    │
│ • Relevant: [John meeting tomorrow at 2 PM]                    │
└─────────────────────────────────────────────────────────────────┘

═════════════════════════════════════════════════════════════════════════════

TECHNOLOGY STACK:

═════════════════════════════════════════════════════════════════════════════

Input Layer (Stage 1-2):
├─ Audio: WAV, MP3, PCM streams
├─ ASR: Vosk (offline)
└─ Platform: REST API via Flask

Processing Layer (Stage 3-4):
├─ LLM: Ollama (local) + OpenAI (optional)
├─ NLP: spaCy, regex pattern matching
├─ Inference: CPU/GPU supported
└─ Language: Python with Flask

Storage Layer (Stage 5):
├─ Database: SQLite
├─ Embeddings: Sentence Transformers (FAISS)
├─ Vectors: 384-dimensional
└─ Indexing: FAISS indices

Retrieval Layer (Stage 6):
├─ Search: Cosine similarity
├─ Ranking: Score-based top-K
├─ Fallback: Keyword matching
└─ Speed: <100ms per query

Output Layer (Stage 7):
├─ Answer Gen: LLM-powered + fallback
├─ Reminders: Structured extraction
├─ Format: JSON REST API
└─ Frontend: Flutter/Dart mobile app

═════════════════════════════════════════════════════════════════════════════

PERFORMANCE BENCHMARKS:

═════════════════════════════════════════════════════════════════════════════

Stage                      Time        Notes
─────────────────────────────────────────────────────────────────
1. Wearable Mic            Instant     Direct input
2. Speech-to-Text          1-2s        Vosk ASR processing
3. LLM Processing          2-5s        Ollama inference
4. Memory Structuring      <100ms      NLP extraction
5. Vector Database         50ms        Embedding creation
6. Query System            <100ms      Semantic search
7. Output (Recall)         500ms       LLM answer generation
─────────────────────────────────────────────────────────────────
Total Pipeline             <10s        End-to-end latency

═════════════════════════════════════════════════════════════════════════════

ERROR HANDLING & FALLBACKS:

═════════════════════════════════════════════════════════════════════════════

Stage 2 (ASR):
├─ Fail ──▶ Return error
└─ Audio not readable ──▶ Show error message

Stage 3 (LLM):
├─ Ollama unavailable ──▶ Fallback to deterministic
└─ Network error ──▶ Use cached patterns

Stage 5 (Embeddings):
├─ Disabled ──▶ Use keyword search (Stage 6)
└─ Model unavailable ──▶ Switch to fuzzy search

Stage 6 (Search):
├─ No results ──▶ Return empty
└─ Ambiguous query ──▶ Return all or filtered subset

Stage 7 (Output):
├─ LLM timeout ──▶ Fallback answer
└─ No memories ──▶ Generic response

═════════════════════════════════════════════════════════════════════════════

This is your complete, transparent, 7-stage pipeline ready for production use!

═════════════════════════════════════════════════════════════════════════════

