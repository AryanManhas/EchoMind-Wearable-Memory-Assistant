from __future__ import annotations

import tempfile
from datetime import datetime
from pathlib import Path

from flask import Flask, jsonify, request
from flask_cors import CORS

from config import Config
from services.audio_service import AudioService
from services.db_service import DBService
from services.embedding_service import EmbeddingService
from services.llm_service import LLMService
from services.nlp_service import NLPService
from services.search_service import SearchService


def create_app() -> Flask:
    app = Flask(__name__)
    app.config.from_object(Config)
    
    # Enhanced CORS for mobile/Android access
    CORS(
        app,
        resources={r"/*": {"origins": "*"}},
        supports_credentials=True,
        allow_headers=["Content-Type", "Authorization"],
        methods=["GET", "POST", "PUT", "DELETE", "OPTIONS"],
    )

    db_service = DBService(Path(app.config["DB_PATH"]))
    nlp_service = NLPService()
    audio_service = AudioService(app.config["VOSK_MODEL_PATH"])
    embedding_service = EmbeddingService(
        app.config["EMBEDDING_MODEL"], enabled=app.config["ENABLE_EMBEDDINGS"]
    )
    search_service = SearchService(embedding_service)
    llm_service = LLMService(
        enabled=app.config["ENABLE_LLM"],
        provider=app.config["LLM_PROVIDER"],
        model=app.config["LLM_MODEL"],
        endpoint_url=app.config["OLLAMA_URL"],
    )

    @app.get("/health")
    def health():
        try:
            return jsonify(
                {
                    "status": "ok",
                    "embeddings": embedding_service.diagnostics(),
                    "vosk_model": app.config["VOSK_MODEL_PATH"],
                    "llm_enabled": app.config["ENABLE_LLM"],
                    "llm_model": app.config["LLM_MODEL"],
                    "database": "ready",
                }
            ), 200
        except Exception as e:
            return jsonify({"status": "error", "message": str(e)}), 500

    @app.post("/add")
    def add_memory():
        try:
            text_input = None
            audio_chunks = []

            if request.content_type and "application/json" in request.content_type:
                payload = request.get_json(silent=True) or {}
                text_input = payload.get("text")
            else:
                text_input = request.form.get("text")

            if not text_input and "audio" in request.files:
                audio = request.files["audio"]
                suffix = Path(audio.filename or "clip.wav").suffix or ".wav"
                with tempfile.NamedTemporaryFile(delete=False, suffix=suffix) as tmp:
                    tmp_path = Path(tmp.name)
                    audio.save(tmp.name)
                try:
                    transcription = audio_service.transcribe_audio(tmp_path)
                    text_input = transcription["text"]
                    audio_chunks = transcription["chunks"]
                finally:
                    tmp_path.unlink(missing_ok=True)

            if not text_input:
                return jsonify({"error": "Provide text or audio input"}), 400

            memory = nlp_service.extract_memory(text_input)
            embedding = embedding_service.embed_text(memory["text"])
            memory_id = db_service.add_memory(memory, embedding)
            concise_response = nlp_service.to_concise_response(memory)

            return jsonify(
                {
                    "id": memory_id,
                    "memory": memory,
                    "response": concise_response,
                    "chunks": audio_chunks,
                }
            ), 200
        except Exception as e:
            return jsonify({"error": f"Failed to add memory: {str(e)}"}), 500

    @app.post("/detect_wake_word")
    def detect_wake_word():
        try:
            if "audio" not in request.files:
                return jsonify({"error": "audio file is required"}), 400

            audio = request.files["audio"]
            suffix = Path(audio.filename or "clip.wav").suffix or ".wav"

            with tempfile.NamedTemporaryFile(delete=False, suffix=suffix) as tmp:
                tmp_path = Path(tmp.name)
                audio.save(tmp.name)
            try:
                transcription = audio_service.transcribe_audio(tmp_path)
                text = (transcription.get("text") or "").strip().lower()
                wake_word = "hey echomind"  # Configurable wake word
                detected = wake_word in text
                return jsonify({"detected": detected, "text": text}), 200
            finally:
                tmp_path.unlink(missing_ok=True)
        except Exception as e:
            return jsonify({"error": f"Wake word detection failed: {str(e)}"}), 500

    @app.post("/ingest_chunk")
    def ingest_chunk():
        try:
            payload = request.get_json(silent=True) or {}
            text = (payload.get("text") or "").strip()
            if not text:
                return jsonify({"error": "text is required"}), 400

            session_id = (payload.get("session_id") or "default-session").strip()
            chunk_index = int(payload.get("chunk_index") or 0)
            speaker = (payload.get("speaker") or "unknown").strip()

            memory = nlp_service.extract_memory(text)
            memory["session_id"] = session_id
            memory["chunk_index"] = chunk_index
            memory["speaker"] = speaker

            embedding = embedding_service.embed_text(memory["text"])
            memory_id = db_service.add_memory(memory, embedding)
            response = nlp_service.to_concise_response(memory)
            return jsonify(
                {
                    "saved": True,
                    "id": memory_id,
                    "session_id": session_id,
                    "chunk_index": chunk_index,
                    "speaker": speaker,
                    "is_reminder": memory.get("is_reminder", False),
                    "priority": memory.get("priority"),
                    "response": response,
                }
            ), 200
        except Exception as e:
            return jsonify({"error": f"Chunk ingest failed: {str(e)}"}), 500

    @app.post("/ingest_audio_chunk")
    def ingest_audio_chunk():
        try:
            if "audio" not in request.files:
                return jsonify({"error": "audio file is required"}), 400

            audio = request.files["audio"]
            session_id = (request.form.get("session_id") or "default-session").strip()
            chunk_index = int(request.form.get("chunk_index") or 0)
            speaker = (request.form.get("speaker") or "unknown").strip()
            suffix = Path(audio.filename or "clip.wav").suffix or ".wav"

            with tempfile.NamedTemporaryFile(delete=False, suffix=suffix) as tmp:
                tmp_path = Path(tmp.name)
                audio.save(tmp.name)
            try:
                transcription = audio_service.transcribe_audio(tmp_path)
                text = (transcription.get("text") or "").strip()
                if not text:
                    return jsonify({"error": "could not transcribe audio"}), 400

                memory = nlp_service.extract_memory(text)
                memory["session_id"] = session_id
                memory["chunk_index"] = chunk_index
                memory["speaker"] = speaker

                embedding = embedding_service.embed_text(memory["text"])
                memory_id = db_service.add_memory(memory, embedding)
                response = nlp_service.to_concise_response(memory)
                return jsonify(
                    {
                        "saved": True,
                        "id": memory_id,
                        "session_id": session_id,
                        "chunk_index": chunk_index,
                        "speaker": speaker,
                        "transcript": text,
                        "chunks": transcription.get("chunks", []),
                        "is_reminder": memory.get("is_reminder", False),
                        "priority": memory.get("priority"),
                        "response": response,
                    }
                ), 200
            finally:
                tmp_path.unlink(missing_ok=True)
        except Exception as e:
            return jsonify({"error": f"Audio chunk ingest failed: {str(e)}"}), 500

    @app.post("/ingest_audio_stream_chunk")
    def ingest_audio_stream_chunk():
        try:
            session_id = (request.form.get("session_id") or "default-session").strip()
            speaker = (request.form.get("speaker") or "unknown").strip()
            audio_data = request.get_data()  # Raw bytes
            if not audio_data:
                return jsonify({"error": "audio data is required"}), 400

            transcription = audio_service.transcribe_audio_chunk(session_id, audio_data)
            if transcription:
                text = transcription["text"]
                is_final = transcription["final"]
                if is_final:
                    # Extract memory from final text
                    memory = nlp_service.extract_memory(text)
                    memory["session_id"] = session_id
                    memory["speaker"] = speaker
                    embedding = embedding_service.embed_text(memory["text"])
                    memory_id = db_service.add_memory(memory, embedding)
                    response = nlp_service.to_concise_response(memory)
                    return jsonify(
                        {
                            "transcription": text,
                            "final": True,
                            "saved": True,
                            "id": memory_id,
                            "is_reminder": memory.get("is_reminder", False),
                            "priority": memory.get("priority"),
                            "response": response,
                        }
                    ), 200
                else:
                    return jsonify({"transcription": text, "final": False}), 200
            return jsonify({"transcription": "", "final": False}), 200
        except Exception as e:
            return jsonify({"error": f"Audio stream processing failed: {str(e)}"}), 500

    @app.post("/finalize_audio_session")
    def finalize_audio_session():
        try:
            session_id = (request.form.get("session_id") or "default-session").strip()
            transcription = audio_service.finalize_session(session_id)
            if transcription:
                text = transcription["text"]
                memory = nlp_service.extract_memory(text)
                memory["session_id"] = session_id
                embedding = embedding_service.embed_text(memory["text"])
                memory_id = db_service.add_memory(memory, embedding)
                response = nlp_service.to_concise_response(memory)
                return jsonify(
                    {
                        "transcription": text,
                        "final": True,
                        "saved": True,
                        "id": memory_id,
                        "is_reminder": memory.get("is_reminder", False),
                        "priority": memory.get("priority"),
                        "response": response,
                    }
                ), 200
            return jsonify({"message": "Session finalized, no additional transcription"}), 200
        except Exception as e:
            return jsonify({"error": f"Session finalization failed: {str(e)}"}), 500

    @app.post("/search")
    def search_memories():
        try:
            payload = request.get_json(silent=True) or {}
            query = (payload.get("query") or "").strip()
            if not query:
                return jsonify({"error": "query is required"}), 400

            records = db_service.get_all_memories()
            results = search_service.search(query, records, top_k=5)
            return jsonify({"query": query, "results": results}), 200
        except Exception as e:
            return jsonify({"error": f"Search failed: {str(e)}"}), 500

    @app.get("/memories")
    def list_memories():
        try:
            records = db_service.get_all_memories()
            return jsonify({"count": len(records), "memories": records}), 200
        except Exception as e:
            return jsonify({"error": f"Failed to fetch memories: {str(e)}"}), 500

    @app.get("/reminders/today")
    def reminders_today():
        try:
            reminders = db_service.get_today_reminders()
            return jsonify({"count": len(reminders), "reminders": reminders}), 200
        except Exception as e:
            return jsonify({"error": f"Failed to fetch reminders: {str(e)}"}), 500

    @app.get("/brief")
    def proactive_brief():
        try:
            pending = db_service.get_pending_reminders(limit=5)
            if not pending:
                message = "No pending reminders. You are all caught up."
            else:
                top = pending[0]
                message = (
                    f"You have {len(pending)} pending reminders. "
                    f"Top item: {top.get('text', '')}"
                )
            return jsonify({"message": message, "reminders": pending}), 200
        except Exception as e:
            return jsonify({"error": f"Failed to get brief: {str(e)}"}), 500

    @app.get("/memories/<int:memory_id>")
    def get_memory(memory_id: int):
        try:
            record = db_service.get_memory_by_id(memory_id)
            if not record:
                return jsonify({"error": "memory not found"}), 404
            return jsonify({"memory": record}), 200
        except Exception as e:
            return jsonify({"error": f"Failed to fetch memory: {str(e)}"}), 500

    @app.post("/ask")
    def ask_assistant():
        try:
            payload = request.get_json(silent=True) or {}
            query = (payload.get("query") or "").strip()
            if not query:
                return jsonify({"error": "query is required"}), 400

            records = db_service.get_all_memories()
            retrieved = search_service.search(query, records, top_k=5)
            answer = llm_service.answer_with_context(query=query, memories=retrieved)
            return jsonify(
                {
                    "query": query,
                    "answer": answer["answer"],
                    "source": answer["source"],
                    "citations": answer.get("citations", []),
                    "retrieved": retrieved,
                }
            ), 200
        except Exception as e:
            return jsonify({"error": f"Assistant failed: {str(e)}"}), 500

    @app.post("/pipeline/query")
    def pipeline_query():
        """
        Complete end-to-end pipeline query with transparent output.
        Pipeline stages:
        1. Wearable Device (Mic) - Input capture
        2. Speech-to-Text (ASR) - Convert audio to text
        3. LLM Processing (NLP) - Extract intent and structure
        4. Memory Structuring - Extract tasks, events, entities
        5. Vector Database - Semantic search with embeddings
        6. Query System - Retrieve related memories
        7. Output (Recall + Reminders) - Return structured results
        """
        try:
            payload = request.get_json(silent=True) or {}
            query = (payload.get("query") or "").strip()
            if not query:
                return jsonify({"error": "query is required"}), 400

            # Stage 3: LLM Processing (NLP) - Structure the query
            query_memory = nlp_service.extract_memory(query)
            
            # Stage 5: Vector Database - Get all memories with embeddings
            all_memories = db_service.get_all_memories()
            
            # Stage 6: Query System - Semantic search
            retrieved_memories = search_service.search(query, all_memories, top_k=5)
            
            # Stage 7a: Output - Recall
            answer = llm_service.answer_with_context(query=query, memories=retrieved_memories)
            
            # Stage 7b: Output - Reminders
            all_reminders = db_service.get_pending_reminders(limit=10)
            relevant_reminders = [
                r for r in all_reminders
                if any(
                    word in r.get("text", "").lower()
                    for word in query.lower().split()
                    if len(word) > 3
                )
            ] if query else []
            
            # Return complete pipeline output
            return jsonify(
                {
                    "pipeline": {
                        "status": "complete",
                        "stages": {
                            "1_wearable_mic": "input_processed",
                            "2_speech_to_text": "text_ready",
                            "3_llm_processing": {
                                "detected_type": query_memory.get("type"),
                                "detected_person": query_memory.get("person"),
                                "detected_time": query_memory.get("time"),
                            },
                            "4_memory_structuring": {
                                "type": query_memory.get("type"),
                                "person": query_memory.get("person"),
                                "time": query_memory.get("time"),
                                "priority": query_memory.get("priority"),
                            },
                            "5_vector_database": {
                                "embedding_enabled": embedding_service.enabled,
                                "total_memories": len(all_memories),
                                "memories_with_embeddings": len(
                                    db_service.get_memories_with_embeddings()
                                ),
                            },
                            "6_query_system": {
                                "query_text": query,
                                "retrieved_count": len(retrieved_memories),
                                "search_type": "semantic" if embedding_service.enabled else "keyword",
                            },
                        },
                    },
                    "output": {
                        "recall": {
                            "answer": answer["answer"],
                            "source": answer["source"],
                            "retrieved_memories": retrieved_memories,
                            "citations": answer.get("citations", []),
                        },
                        "reminders": {
                            "pending_count": len(all_reminders),
                            "relevant_reminders": relevant_reminders,
                            "all_pending": all_reminders[:5],
                        },
                    },
                    "metadata": {
                        "query": query,
                        "timestamp": datetime.utcnow().isoformat(),
                    },
                }
            ), 200
        except Exception as e:
            return jsonify({"error": f"Pipeline query failed: {str(e)}"}), 500

    @app.get("/pipeline/info")
    def pipeline_info():
        """Get pipeline architecture and configuration info."""
        try:
            return jsonify(
                {
                    "pipeline_name": "EchoMind Memory Assistant",
                    "version": "1.0.0",
                    "stages": [
                        {
                            "stage": 1,
                            "name": "Wearable Device (Mic)",
                            "description": "Audio input capture from wearable device",
                            "enabled": True,
                        },
                        {
                            "stage": 2,
                            "name": "Speech-to-Text (Whisper/ASR)",
                            "description": "Convert audio to text using Vosk ASR",
                            "enabled": True,
                            "model": "vosk-model-small-en-us-0.15",
                        },
                        {
                            "stage": 3,
                            "name": "LLM Processing (GPT/NLP)",
                            "description": "Process with LLM for intent and context",
                            "enabled": app.config["ENABLE_LLM"],
                            "provider": app.config["LLM_PROVIDER"],
                            "model": app.config["LLM_MODEL"],
                        },
                        {
                            "stage": 4,
                            "name": "Memory Structuring",
                            "description": "Extract tasks, events, entities from text",
                            "enabled": True,
                            "services": ["NLPService"],
                        },
                        {
                            "stage": 5,
                            "name": "Vector Database (FAISS/Pinecone)",
                            "description": "Store and index embeddings for semantic search",
                            "enabled": app.config["ENABLE_EMBEDDINGS"],
                            "model": app.config["EMBEDDING_MODEL"],
                        },
                        {
                            "stage": 6,
                            "name": "Query System (Voice/Text)",
                            "description": "Query memories using semantic search",
                            "enabled": True,
                        },
                        {
                            "stage": 7,
                            "name": "Output (Recall + Reminders)",
                            "description": "Return structured results with reminders",
                            "enabled": True,
                        },
                    ],
                    "database": {
                        "type": "SQLite",
                        "path": app.config["DB_PATH"],
                        "tables": ["memories"],
                    },
                }
            ), 200
        except Exception as e:
            return jsonify({"error": f"Failed to get pipeline info: {str(e)}"}), 500

    # Global error handlers
    @app.errorhandler(404)
    def not_found(error):
        return jsonify({"error": "Endpoint not found"}), 404

    @app.errorhandler(500)
    def internal_error(error):
        return jsonify({"error": "Internal server error"}), 500

    return app


if __name__ == "__main__":
    app = create_app()
    app.run(debug=True, host="0.0.0.0", port=5000)
