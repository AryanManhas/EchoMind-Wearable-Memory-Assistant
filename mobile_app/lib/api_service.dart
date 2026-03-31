import "dart:convert";

import "package:flutter/foundation.dart";
import "package:http/http.dart" as http;

import "models.dart";

class AssistantReply {
  final String answer;
  final String source;
  final List<int> citations;

  AssistantReply({
    required this.answer,
    required this.source,
    required this.citations,
  });
}

class BriefResponse {
  final String message;
  final List<MemoryItem> reminders;

  BriefResponse({required this.message, required this.reminders});
}

class ChunkIngestResult {
  final bool saved;
  final int id;
  final String sessionId;
  final int chunkIndex;
  final String speaker;
  final bool isReminder;
  final String? priority;
  final String response;

  ChunkIngestResult({
    required this.saved,
    required this.id,
    required this.sessionId,
    required this.chunkIndex,
    required this.speaker,
    required this.isReminder,
    required this.priority,
    required this.response,
  });
}

class ApiService {
  // Update this for real phone testing on the same Wi-Fi as backend.
  static const String _lanIp = "192.168.29.113";

  static String get baseUrl {
    if (kIsWeb) return "http://127.0.0.1:5000";
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        // Android emulator host loopback.
        return "http://10.0.2.2:5000";
      case TargetPlatform.iOS:
        // iOS simulator loopback.
        return "http://127.0.0.1:5000";
      default:
        // Physical mobile devices should use PC LAN IP.
        return "http://$_lanIp:5000";
    }
  }

  Future<String> addMemory(String text) async {
    final uri = Uri.parse("$baseUrl/add");
    final response = await http.post(
      uri,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"text": text}),
    );

    if (response.statusCode >= 400) {
      throw Exception("Failed to add memory: ${response.body}");
    }
    final parsed = jsonDecode(response.body) as Map<String, dynamic>;
    return (parsed["response"] ?? "Memory saved") as String;
  }

  Future<ChunkIngestResult> ingestChunk({
    required String text,
    required String sessionId,
    required int chunkIndex,
    required String speaker,
  }) async {
    final uri = Uri.parse("$baseUrl/ingest_chunk");
    final response = await http.post(
      uri,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(
        {
          "text": text,
          "session_id": sessionId,
          "chunk_index": chunkIndex,
          "speaker": speaker,
        },
      ),
    );
    if (response.statusCode >= 400) {
      throw Exception("Chunk ingest failed: ${response.body}");
    }
    final parsed = jsonDecode(response.body) as Map<String, dynamic>;
    return ChunkIngestResult(
      saved: (parsed["saved"] ?? false) == true,
      id: (parsed["id"] ?? 0) as int,
      sessionId: (parsed["session_id"] ?? sessionId) as String,
      chunkIndex: (parsed["chunk_index"] ?? chunkIndex) as int,
      speaker: (parsed["speaker"] ?? speaker) as String,
      isReminder: (parsed["is_reminder"] ?? false) == true,
      priority: parsed["priority"] as String?,
      response: (parsed["response"] ?? "Saved") as String,
    );
  }

  Future<ChunkIngestResult> ingestAudioChunk({
    required String audioPath,
    required String sessionId,
    required int chunkIndex,
    required String speaker,
  }) async {
    final uri = Uri.parse("$baseUrl/ingest_audio_chunk");
    final request = http.MultipartRequest("POST", uri)
      ..fields["session_id"] = sessionId
      ..fields["chunk_index"] = chunkIndex.toString()
      ..fields["speaker"] = speaker
      ..files.add(await http.MultipartFile.fromPath("audio", audioPath));
    final streamed = await request.send();
    final body = await streamed.stream.bytesToString();
    if (streamed.statusCode >= 400) {
      throw Exception("Audio chunk ingest failed: $body");
    }
    final parsed = jsonDecode(body) as Map<String, dynamic>;
    return ChunkIngestResult(
      saved: (parsed["saved"] ?? false) == true,
      id: (parsed["id"] ?? 0) as int,
      sessionId: (parsed["session_id"] ?? sessionId) as String,
      chunkIndex: (parsed["chunk_index"] ?? chunkIndex) as int,
      speaker: (parsed["speaker"] ?? speaker) as String,
      isReminder: (parsed["is_reminder"] ?? false) == true,
      priority: parsed["priority"] as String?,
      response: (parsed["response"] ?? "Saved") as String,
    );
  }

  Future<String> addMemoryFromAudioPath(String audioPath) async {
    final uri = Uri.parse("$baseUrl/add");
    final request = http.MultipartRequest("POST", uri)
      ..files.add(await http.MultipartFile.fromPath("audio", audioPath));
    final streamed = await request.send();
    final body = await streamed.stream.bytesToString();
    if (streamed.statusCode >= 400) {
      throw Exception("Failed to add memory from audio: $body");
    }
    final parsed = jsonDecode(body) as Map<String, dynamic>;
    return (parsed["response"] ?? "Memory saved") as String;
  }

  Future<List<MemoryItem>> getMemories() async {
    final uri = Uri.parse("$baseUrl/memories");
    final response = await http.get(uri);
    if (response.statusCode >= 400) {
      throw Exception("Failed to fetch memories: ${response.body}");
    }
    final parsed = jsonDecode(response.body) as Map<String, dynamic>;
    final raw = (parsed["memories"] as List<dynamic>? ?? <dynamic>[]);
    return raw
        .map((item) => MemoryItem.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<MemoryItem> getMemoryById(int id) async {
    final uri = Uri.parse("$baseUrl/memories/$id");
    final response = await http.get(uri);
    if (response.statusCode >= 400) {
      throw Exception("Failed to fetch memory: ${response.body}");
    }
    final parsed = jsonDecode(response.body) as Map<String, dynamic>;
    return MemoryItem.fromJson(parsed["memory"] as Map<String, dynamic>);
  }

  Future<List<MemoryItem>> getTodayReminders() async {
    final uri = Uri.parse("$baseUrl/reminders/today");
    final response = await http.get(uri);
    if (response.statusCode >= 400) {
      throw Exception("Failed to fetch today's reminders: ${response.body}");
    }
    final parsed = jsonDecode(response.body) as Map<String, dynamic>;
    final raw = (parsed["reminders"] as List<dynamic>? ?? <dynamic>[]);
    return raw
        .map((item) => MemoryItem.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<BriefResponse> getBrief() async {
    final uri = Uri.parse("$baseUrl/brief");
    final response = await http.get(uri);
    if (response.statusCode >= 400) {
      throw Exception("Failed to fetch brief: ${response.body}");
    }
    final parsed = jsonDecode(response.body) as Map<String, dynamic>;
    final raw = (parsed["reminders"] as List<dynamic>? ?? <dynamic>[]);
    final reminders = raw
        .map((item) => MemoryItem.fromJson(item as Map<String, dynamic>))
        .toList();
    return BriefResponse(
      message: (parsed["message"] ?? "No brief available.") as String,
      reminders: reminders,
    );
  }

  Future<List<MemoryItem>> search(String query) async {
    final uri = Uri.parse("$baseUrl/search");
    final response = await http.post(
      uri,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"query": query}),
    );
    if (response.statusCode >= 400) {
      throw Exception("Search failed: ${response.body}");
    }
    final parsed = jsonDecode(response.body) as Map<String, dynamic>;
    final raw = (parsed["results"] as List<dynamic>? ?? <dynamic>[]);
    return raw
        .map((item) => MemoryItem.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<AssistantReply> askAssistant(String query) async {
    final uri = Uri.parse("$baseUrl/ask");
    final response = await http.post(
      uri,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"query": query}),
    );
    if (response.statusCode >= 400) {
      throw Exception("Assistant request failed: ${response.body}");
    }
    final parsed = jsonDecode(response.body) as Map<String, dynamic>;
    final rawCitations = (parsed["citations"] as List<dynamic>? ?? <dynamic>[]);
    return AssistantReply(
      answer: (parsed["answer"] ?? "No answer available.") as String,
      source: (parsed["source"] ?? "fallback") as String,
      citations: rawCitations
          .whereType<num>()
          .map((e) => e.toInt())
          .toList(growable: false),
    );
  }

  Future<WakeWordResult> detectWakeWord({required String audioPath}) async {
    final uri = Uri.parse("$baseUrl/detect_wake_word");
    final request = http.MultipartRequest("POST", uri)
      ..files.add(await http.MultipartFile.fromPath("audio", audioPath));
    final streamed = await request.send();
    final body = await streamed.stream.bytesToString();
    if (streamed.statusCode >= 400) {
      throw Exception("Wake word detection failed: $body");
    }
    final parsed = jsonDecode(body) as Map<String, dynamic>;
    return WakeWordResult(
      detected: (parsed["detected"] ?? false) == true,
      text: (parsed["text"] ?? "") as String,
    );
  }
}
