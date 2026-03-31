from __future__ import annotations

import tempfile
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
    CORS(app)

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
        return jsonify(
            {
                "status": "ok",
                "embeddings": embedding_service.diagnostics(),
                "vosk_model": app.config["VOSK_MODEL_PATH"],
                "llm_enabled": app.config["ENABLE_LLM"],
                "llm_model": app.config["LLM_MODEL"],
            }
        )

    @app.post("/add")
    def add_memory():
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
        )

    @app.post("/detect_wake_word")
    def detect_wake_word():
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
            return jsonify({"detected": detected, "text": text})
        finally:
            tmp_path.unlink(missing_ok=True)

    @app.post("/ingest_chunk")
    def ingest_chunk():
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
        )

    @app.post("/ingest_audio_chunk")
    def ingest_audio_chunk():
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
            )
        finally:
            tmp_path.unlink(missing_ok=True)

    @app.post("/ingest_audio_stream_chunk")
    def ingest_audio_stream_chunk():
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
                )
            else:
                return jsonify({"transcription": text, "final": False})
        return jsonify({"transcription": "", "final": False})

    @app.post("/finalize_audio_session")
    def finalize_audio_session():
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
            )
        return jsonify({"message": "Session finalized, no additional transcription"})

    @app.post("/search")
    def search_memories():
        payload = request.get_json(silent=True) or {}
        query = (payload.get("query") or "").strip()
        if not query:
            return jsonify({"error": "query is required"}), 400

        records = db_service.get_all_memories()
        results = search_service.search(query, records, top_k=5)
        return jsonify({"query": query, "results": results})

    @app.get("/memories")
    def list_memories():
        records = db_service.get_all_memories()
        return jsonify({"count": len(records), "memories": records})

    @app.get("/reminders/today")
    def reminders_today():
        reminders = db_service.get_today_reminders()
        return jsonify({"count": len(reminders), "reminders": reminders})

    @app.get("/brief")
    def proactive_brief():
        pending = db_service.get_pending_reminders(limit=5)
        if not pending:
            message = "No pending reminders. You are all caught up."
        else:
            top = pending[0]
            message = (
                f"You have {len(pending)} pending reminders. "
                f"Top item: {top.get('text', '')}"
            )
        return jsonify({"message": message, "reminders": pending})

    @app.get("/memories/<int:memory_id>")
    def get_memory(memory_id: int):
        record = db_service.get_memory_by_id(memory_id)
        if not record:
            return jsonify({"error": "memory not found"}), 404
        return jsonify({"memory": record})

    @app.post("/ask")
    def ask_assistant():
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
        )

    return app


if __name__ == "__main__":
    app = create_app()
    app.run(debug=True, host="0.0.0.0", port=5000)
