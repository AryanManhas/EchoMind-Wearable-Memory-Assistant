from __future__ import annotations

from difflib import SequenceMatcher
from typing import Any

import numpy as np

from services.embedding_service import EmbeddingService


class SearchService:
    def __init__(self, embedding_service: EmbeddingService) -> None:
        self.embedding_service = embedding_service

    def search(self, query: str, memories: list[dict[str, Any]], top_k: int = 5) -> list[dict[str, Any]]:
        if not memories:
            return []
        if self.embedding_service.enabled:
            return self._semantic_search(query, memories, top_k)
        return self._keyword_fuzzy_search(query, memories, top_k)

    def _semantic_search(
        self, query: str, memories: list[dict[str, Any]], top_k: int
    ) -> list[dict[str, Any]]:
        query_vec = self.embedding_service.embed_text(query)
        if query_vec is None:
            return self._keyword_fuzzy_search(query, memories, top_k)

        q = np.array(query_vec)
        scored: list[dict[str, Any]] = []
        for item in memories:
            emb = item.get("embedding")
            if not emb:
                continue
            v = np.array(emb)
            sim = float(np.dot(q, v) / ((np.linalg.norm(q) * np.linalg.norm(v)) + 1e-9))
            item_copy = dict(item)
            item_copy["score"] = sim
            scored.append(item_copy)

        scored.sort(key=lambda x: x["score"], reverse=True)
        return scored[:top_k]

    @staticmethod
    def _keyword_fuzzy_search(
        query: str, memories: list[dict[str, Any]], top_k: int
    ) -> list[dict[str, Any]]:
        query_lower = query.lower().strip()
        query_tokens = set(query_lower.split())
        scored: list[dict[str, Any]] = []

        for item in memories:
            text = (item.get("text") or "").lower()
            tokens = set(text.split())
            overlap = len(query_tokens.intersection(tokens)) / max(len(query_tokens), 1)
            fuzzy = SequenceMatcher(None, query_lower, text).ratio()
            score = 0.65 * overlap + 0.35 * fuzzy
            item_copy = dict(item)
            item_copy["score"] = score
            scored.append(item_copy)

        scored.sort(key=lambda x: x["score"], reverse=True)
        return scored[:top_k]
