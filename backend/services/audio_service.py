from __future__ import annotations

import json
import os
from pathlib import Path
from typing import Any

import numpy as np


class AudioService:
    def __init__(self, vosk_model_path: str = "vosk-model-small-en-us-0.15") -> None:
        self.vosk_model_path = vosk_model_path
        self._vosk_model = None
        self._vosk_error: str | None = None
        self._recognizers = {}  # session_id -> recognizer

    def _load_model(self) -> None:
        if self._vosk_model is not None or self._vosk_error is not None:
            return
        try:
            from vosk import Model  # type: ignore

            if not os.path.exists(self.vosk_model_path):
                raise RuntimeError(f"Vosk model not found at {self.vosk_model_path}. Download from https://alphacephei.com/vosk/models")
            self._vosk_model = Model(self.vosk_model_path)
        except Exception as exc:  # noqa: BLE001
            self._vosk_error = str(exc)

    def get_recognizer(self, session_id: str):
        self._load_model()
        if self._vosk_model is None:
            raise RuntimeError(f"Vosk unavailable. Root error: {self._vosk_error}")
        if session_id not in self._recognizers:
            from vosk import KaldiRecognizer  # type: ignore
            self._recognizers[session_id] = KaldiRecognizer(self._vosk_model, 16000)
        return self._recognizers[session_id]

    def transcribe_audio_chunk(self, session_id: str, audio_data: bytes) -> dict[str, Any] | None:
        recognizer = self.get_recognizer(session_id)
        if recognizer.AcceptWaveform(audio_data):
            result = json.loads(recognizer.Result())
            text = result.get("text", "").strip()
            if text:
                return {"text": text, "final": True}
        else:
            partial = json.loads(recognizer.PartialResult())
            text = partial.get("partial", "").strip()
            if text:
                return {"text": text, "final": False}
        return None

    def finalize_session(self, session_id: str) -> dict[str, Any] | None:
        if session_id in self._recognizers:
            recognizer = self._recognizers[session_id]
            result = json.loads(recognizer.FinalResult())
            text = result.get("text", "").strip()
            if text:
                return {"text": text, "final": True}
            del self._recognizers[session_id]
        return None

    # Fallback for non-streaming
    def transcribe_audio(self, audio_path: Path) -> dict[str, Any]:
        # For compatibility, use a temporary session
        import wave
        with wave.open(str(audio_path), "rb") as wf:
            if wf.getsampwidth() != 2 or wf.getnchannels() != 1:
                raise ValueError("Audio must be 16-bit mono PCM")
            audio_data = wf.readframes(wf.getnframes())
        session_id = "temp"
        chunks = []
        chunk_size = 4000  # 0.25s at 16kHz
        for i in range(0, len(audio_data), chunk_size):
            chunk = audio_data[i:i+chunk_size]
            result = self.transcribe_audio_chunk(session_id, chunk)
            if result:
                chunks.append(result)
        final = self.finalize_session(session_id)
        if final:
            chunks.append(final)
        text = " ".join([c["text"] for c in chunks if c["text"]])
        return {"text": text, "chunks": chunks}
