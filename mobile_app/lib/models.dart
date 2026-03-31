class MemoryItem {
  final int id;
  final String text;
  final String? type;
  final String? person;
  final String? time;
  final bool isReminder;
  final String? priority;
  final String? dueTime;
  final String? status;
  final String timestamp;

  MemoryItem({
    required this.id,
    required this.text,
    required this.timestamp,
    required this.isReminder,
    this.type,
    this.person,
    this.time,
    this.priority,
    this.dueTime,
    this.status,
  });

  factory MemoryItem.fromJson(Map<String, dynamic> json) {
    return MemoryItem(
      id: json["id"] as int,
      text: (json["text"] ?? "") as String,
      type: json["type"] as String?,
      person: json["person"] as String?,
      time: json["time"] as String?,
      isReminder: (json["is_reminder"] ?? 0) == 1 || (json["is_reminder"] == true),
      priority: json["priority"] as String?,
      dueTime: json["due_time"] as String?,
      status: json["status"] as String?,
      timestamp: (json["timestamp"] ?? "") as String,
    );
  }
}

class WakeWordResult {
  final bool detected;
  final String text;

  WakeWordResult({required this.detected, required this.text});
}
