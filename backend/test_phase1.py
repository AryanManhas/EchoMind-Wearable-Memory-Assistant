#!/usr/bin/env python3
"""
Quick test for Phase 1 NLP improvements
"""

import sys
import os
sys.path.append(os.path.dirname(__file__))

from services.nlp_service import NLPService

def test_phase1_improvements():
    nlp = NLPService()

    # Test cases that should now work better
    test_cases = [
        # Original working cases
        ("Call John tomorrow", "Should work (original)"),
        ("Meet with Sarah", "Should work (original)"),

        # NEW: Social activities
        ("Lunch with Mark", "Should detect 'meeting' type"),
        ("Coffee with team", "Should detect 'meeting' type"),
        ("Dinner with Sarah", "Should detect 'meeting' type"),

        # NEW: Discussions
        ("Discuss budget", "Should detect 'meeting' type"),
        ("Talk to John", "Should detect 'call' type"),
        ("Sync with team", "Should detect 'meeting' type"),

        # NEW: Communications
        ("Email the report", "Should detect 'reminder' type"),
        ("Text John", "Should detect 'reminder' type"),
        ("Message Sarah", "Should detect 'reminder' type"),

        # NEW: Time expressions
        ("Call ASAP", "Should map 'asap' to 'today'"),
        ("Meet next week", "Should map to '+7 days'"),
        ("Do it soon", "Should map to '+3 days'"),
    ]

    print("🧪 Testing Phase 1 NLP Improvements")
    print("=" * 50)

    for text, expected in test_cases:
        result = nlp.extract_memory(text)
        print(f"Input: '{text}'")
        print(f"  → Type: {result['type']} (Expected: {expected})")
        print(f"  → Person: {result['person']}")
        print(f"  → Time: {result['time']}")
        print(f"  → Is Reminder: {result['is_reminder']}")
        print()

if __name__ == "__main__":
    test_phase1_improvements()