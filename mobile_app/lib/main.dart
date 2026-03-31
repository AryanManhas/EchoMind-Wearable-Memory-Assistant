import "dart:async";

import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:path_provider/path_provider.dart";
import "package:record/record.dart";

import "api_service.dart";
import "models.dart";

void main() {
  runApp(const MemoryAssistantApp());
}

int? parseMemoryIdFromRoute(String? routeName) {
  if (routeName == null || routeName.isEmpty) return null;
  final uri = Uri.tryParse(routeName);
  if (uri == null) return null;
  if (uri.pathSegments.length == 2 && uri.pathSegments.first == "memory") {
    return int.tryParse(uri.pathSegments[1]);
  }
  return null;
}

int? parseMemoryIdFromDeepLink(String raw) {
  final normalized = raw.trim();
  if (normalized.isEmpty) return null;
  final uri = Uri.tryParse(normalized);
  if (uri == null) return null;
  if (uri.scheme == "memory" &&
      uri.host == "id" &&
      uri.pathSegments.isNotEmpty) {
    return int.tryParse(uri.pathSegments.first);
  }
  return parseMemoryIdFromRoute(uri.path);
}

class MemoryAssistantApp extends StatelessWidget {
  const MemoryAssistantApp({super.key});

  @override
  Widget build(BuildContext context) {
    final customScheme = ColorScheme.fromSeed(seedColor: Colors.indigo);
    return MaterialApp(
      title: "Memory Assistant",
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: customScheme,
        scaffoldBackgroundColor: const Color(0xFFF4F7FF),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF2E4BC9),
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          toolbarHeight: 66,
        ),
        textTheme: const TextTheme(
          headlineSmall: TextStyle(fontWeight: FontWeight.w700),
          bodyMedium: TextStyle(fontSize: 15, height: 1.45),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
        ),
        navigationBarTheme: NavigationBarThemeData(
          backgroundColor: Colors.white,
          indicatorColor: customScheme.primary.withOpacity(0.15),
          labelTextStyle: WidgetStateProperty.all(
            const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
      ),
      initialRoute: "/",
      onGenerateRoute: (settings) {
        final route = settings.name ?? "/";
        if (route == "/") {
          return MaterialPageRoute(builder: (_) => const MainShell());
        }
        final memoryId = parseMemoryIdFromRoute(route);
        if (memoryId != null) {
          return MaterialPageRoute(
            builder: (_) => MemoryDetailScreen(memoryId: memoryId),
            settings: settings,
          );
        }
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(child: Text("Unknown route")),
          ),
        );
      },
    );
  }
}

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final pages = <Widget>[
      const TodayScreen(),
      const HomeScreen(),
      const MemoriesScreen(),
      const SearchScreen(),
      const AssistantScreen(),
    ];

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(80),
        child: AppBar(
          title: const Text("Wearable Memory Assistant"),
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF3752D5), Color(0xFF0F2A8F)],
              ),
            ),
          ),
          elevation: 1,
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFF4F7FF), Color(0xFFE7ECFF)],
          ),
        ),
        child: pages[_index],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.today), label: "Today"),
          NavigationDestination(icon: Icon(Icons.mic), label: "Home"),
          NavigationDestination(icon: Icon(Icons.list), label: "Memories"),
          NavigationDestination(icon: Icon(Icons.search), label: "Search"),
          NavigationDestination(
              icon: Icon(Icons.smart_toy), label: "Assistant"),
        ],
      ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class TodayScreen extends StatefulWidget {
  const TodayScreen({super.key});

  @override
  State<TodayScreen> createState() => _TodayScreenState();
}

class _TodayScreenState extends State<TodayScreen> {
  final _api = ApiService();
  late Future<BriefResponse> _briefFuture;
  late Future<List<MemoryItem>> _todayFuture;

  @override
  void initState() {
    super.initState();
    _briefFuture = _api.getBrief();
    _todayFuture = _api.getTodayReminders();
  }

  Future<void> _refresh() async {
    final b = await _api.getBrief();
    final t = await _api.getTodayReminders();
    setState(() {
      _briefFuture = Future.value(b);
      _todayFuture = Future.value(t);
    });
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _refresh,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          FutureBuilder<BriefResponse>(
            future: _briefFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Card(
                  child: ListTile(title: Text("Loading daily brief...")),
                );
              }
              if (snapshot.hasError) {
                return Card(
                  child: ListTile(
                    leading: const Icon(Icons.error_outline),
                    title: const Text("Brief unavailable"),
                    subtitle: Text("${snapshot.error}"),
                  ),
                );
              }
              final brief = snapshot.data;
              return Card(
                child: ListTile(
                  leading: const Icon(Icons.wb_sunny_outlined),
                  title: const Text("Daily Brief"),
                  subtitle: Text(brief?.message ?? "No brief available."),
                ),
              );
            },
          ),
          const SizedBox(height: 12),
          const Text(
            "Today's reminders",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          FutureBuilder<List<MemoryItem>>(
            future: _todayFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Card(
                  child: ListTile(title: Text("Loading reminders...")),
                );
              }
              if (snapshot.hasError) {
                return Card(
                  child: ListTile(
                    leading: const Icon(Icons.error_outline),
                    title: const Text("Unable to load reminders"),
                    subtitle: Text("${snapshot.error}"),
                  ),
                );
              }
              final reminders = snapshot.data ?? [];
              if (reminders.isEmpty) {
                return const Card(
                  child: ListTile(
                    leading: Icon(Icons.check_circle_outline),
                    title: Text("No reminders due today"),
                  ),
                );
              }
              return Column(
                children: reminders
                    .map(
                      (r) => Card(
                        child: ListTile(
                          leading:
                              const Icon(Icons.notifications_active_outlined),
                          title: Text(r.text),
                          subtitle: Text(
                            "Priority: ${r.priority ?? "-"} | Due: ${r.dueTime ?? r.time ?? "-"}",
                          ),
                        ),
                      ),
                    )
                    .toList(growable: false),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _HomeScreenState extends State<HomeScreen> {
  final _api = ApiService();
  final _recorder = AudioRecorder();
  final _controller = TextEditingController();
  final _sessionController = TextEditingController(text: "session-001");
  int _chunkIndex = 1;
  String _status = "Record real conversation chunks and analyze.";
  bool _loading = false;
  bool _recording = false;
  String? _recordedPath;
  bool _alwaysOn = false;
  Timer? _wakeTimer;

  Future<void> _submit() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    setState(() => _loading = true);
    try {
      final response = await _api.addMemory(text);
      setState(() => _status = response);
      _controller.clear();
    } catch (e) {
      setState(() => _status = "Error: $e");
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _toggleRecording() async {
    if (_loading || _alwaysOn) return;
    if (_recording) {
      final path = await _recorder.stop();
      setState(() {
        _recording = false;
        _recordedPath = path;
        _status = path == null
            ? "Recording cancelled."
            : "Recorded clip ready. Tap Send Voice.";
      });
      return;
    }

    final granted = await _recorder.hasPermission();
    if (!granted) {
      setState(() => _status = "Microphone permission denied.");
      return;
    }

    final dir = await getTemporaryDirectory();
    final filePath =
        "${dir.path}/memory_${DateTime.now().millisecondsSinceEpoch}.m4a";
    await _recorder.start(const RecordConfig(), path: filePath);
    setState(() {
      _recording = true;
      _recordedPath = null;
      _status = "Recording... tap Stop.";
    });
  }

  Future<void> _sendVoice() async {
    final path = _recordedPath;
    if (path == null) return;

    setState(() => _loading = true);
    try {
      final sessionId = _sessionController.text.trim();
      final result = await _api.ingestAudioChunk(
        audioPath: path,
        sessionId: sessionId.isEmpty ? "default-session" : sessionId,
        chunkIndex: _chunkIndex,
        speaker: "user",
      );
      setState(() {
        _status =
            "Voice chunk #${result.chunkIndex} saved. Reminder: ${result.isReminder ? "yes" : "no"} (${result.priority ?? "n/a"})";
        _recordedPath = null;
        _chunkIndex += 1;
      });
    } catch (e) {
      setState(() => _status = "Error: $e");
    } finally {
      setState(() => _loading = false);
    }
  }

  void _startWakeDetection() async {
    final granted = await _recorder.hasPermission();
    if (!granted) {
      setState(() => _status = "Microphone permission denied for always-on mode.");
      setState(() => _alwaysOn = false);
      return;
    }
    setState(() => _status = "Always-on mode active. Listening for 'Hey EchoMind'...");
    _wakeTimer = Timer.periodic(const Duration(seconds: 2), (timer) async {
      if (!_alwaysOn) {
        timer.cancel();
        return;
      }
      final dir = await getTemporaryDirectory();
      final filePath = "${dir.path}/wake_${DateTime.now().millisecondsSinceEpoch}.m4a";
      await _recorder.start(const RecordConfig(), path: filePath);
      await Future.delayed(const Duration(seconds: 2));
      final path = await _recorder.stop();
      if (path != null) {
        try {
          final result = await _api.detectWakeWord(audioPath: path);
          if (result.detected) {
            setState(() {
              _alwaysOn = false;
              _recording = true;
              _status = "Wake word detected! Recording...";
            });
            _wakeTimer?.cancel();
            // Start recording for memory
            final recDir = await getTemporaryDirectory();
            final recPath = "${recDir.path}/memory_${DateTime.now().millisecondsSinceEpoch}.m4a";
            await _recorder.start(const RecordConfig(), path: recPath);
            setState(() {
              _recordedPath = recPath;
            });
          } else {
            setState(() => _status = "Listening... (last heard: '${result.text}')");
          }
        } catch (e) {
          setState(() => _status = "Error in wake detection: $e");
        }
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _sessionController.dispose();
    _recorder.dispose();
    _wakeTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFE8EEFF), Color(0xFFFFFFFF)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  children: [
                    TextField(
                      controller: _controller,
                      decoration: const InputDecoration(
                        labelText: "Typed memory",
                        hintText: "Meet Rahul tomorrow at 4 PM",
                        border: OutlineInputBorder(),
                      ),
                      minLines: 1,
                      maxLines: 3,
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _sessionController,
                      decoration: const InputDecoration(
                        labelText: "Conversation session ID",
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: FilledButton.icon(
                            onPressed: _loading ? null : _submit,
                            icon: const Icon(Icons.add),
                            label:
                                Text(_loading ? "Processing..." : "Add Memory"),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      "Voice Module",
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 8),
                    SwitchListTile(
                      title: const Text("Always-on mode"),
                      subtitle: const Text("Continuously listen for wake word"),
                      value: _alwaysOn,
                      onChanged: (value) {
                        setState(() => _alwaysOn = value);
                        if (value) {
                          _startWakeDetection();
                        } else {
                          _wakeTimer?.cancel();
                          setState(() => _status = "Always-on mode disabled.");
                        }
                      },
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _loading ? null : _toggleRecording,
                            icon: Icon(
                              _recording ? Icons.stop : Icons.mic,
                              color: _recording ? Colors.red : null,
                            ),
                            label: Text(_recording
                                ? "Stop Recording"
                                : "Start Recording"),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: FilledButton.icon(
                            onPressed: (_loading ||
                                    _recordedPath == null ||
                                    _recording)
                                ? null
                                : _sendVoice,
                            icon: const Icon(Icons.send),
                            label: const Text("Send Voice Chunk"),
                          ),
                        ),
                      ],
                    ),
                    if (_recordedPath != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        "Recorded clip ready.",
                        style: TextStyle(color: Colors.green.shade700),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Card(
              child: ListTile(
                leading: const Icon(Icons.auto_awesome),
                title: const Text("System status"),
                subtitle: Text(_status),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MemoriesScreen extends StatefulWidget {
  const MemoriesScreen({super.key});

  @override
  State<MemoriesScreen> createState() => _MemoriesScreenState();
}

class _MemoriesScreenState extends State<MemoriesScreen> {
  final _api = ApiService();
  late Future<List<MemoryItem>> _future;

  @override
  void initState() {
    super.initState();
    _future = _api.getMemories();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<MemoryItem>>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text("Error: ${snapshot.error}"));
        }
        final memories = snapshot.data ?? [];
        if (memories.isEmpty) {
          return const Center(child: Text("No memories yet."));
        }
        return RefreshIndicator(
          onRefresh: () async {
            final next = await _api.getMemories();
            setState(() => _future = Future.value(next));
          },
          child: ListView.builder(
            itemCount: memories.length,
            itemBuilder: (context, index) {
              final m = memories[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: ListTile(
                  leading: const Icon(Icons.memory),
                  title: Text(m.text),
                  subtitle: Text(
                    "Type: ${m.type ?? "-"} | Person: ${m.person ?? "-"} | Time: ${m.time ?? "-"} | Reminder: ${m.isReminder ? "yes" : "no"}",
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _api = ApiService();
  final _controller = TextEditingController();
  List<MemoryItem> _results = [];
  bool _loading = false;
  String? _error;

  Future<void> _runSearch() async {
    final query = _controller.text.trim();
    if (query.isEmpty) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final result = await _api.search(query);
      setState(() => _results = result);
    } catch (e) {
      setState(() => _error = "$e");
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          TextField(
            controller: _controller,
            decoration: const InputDecoration(
              labelText: "Search memories",
              hintText: "When is my meeting with Rahul?",
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: _loading ? null : _runSearch,
            icon: const Icon(Icons.search),
            label: Text(_loading ? "Searching..." : "Search"),
          ),
          const SizedBox(height: 12),
          if (_error != null) Text("Error: $_error"),
          Expanded(
            child: ListView.builder(
              itemCount: _results.length,
              itemBuilder: (context, index) {
                final m = _results[index];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  child: ListTile(
                    title: Text(m.text),
                    subtitle: Text(
                      "Type: ${m.type ?? "-"} | Person: ${m.person ?? "-"} | Time: ${m.time ?? "-"} | Priority: ${m.priority ?? "-"}",
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class AssistantScreen extends StatefulWidget {
  const AssistantScreen({super.key});

  @override
  State<AssistantScreen> createState() => _AssistantScreenState();
}

class _AssistantScreenState extends State<AssistantScreen> {
  final _api = ApiService();
  final _controller = TextEditingController();
  bool _loading = false;
  String _answer = "Ask about your past conversations and memories.";
  String _meta = "";
  List<int> _citations = const [];

  Future<void> _ask() async {
    final query = _controller.text.trim();
    if (query.isEmpty) return;
    setState(() => _loading = true);
    try {
      final reply = await _api.askAssistant(query);
      final citations = reply.citations;
      final citationText = citations.isEmpty
          ? "No memory citations."
          : "Based on memories #${citations.join(", #")}";
      setState(() {
        _answer = reply.answer;
        _meta = "$citationText | Source: ${reply.source}";
        _citations = reply.citations;
      });
    } catch (e) {
      setState(() {
        _answer = "Error: $e";
        _meta = "";
        _citations = const [];
      });
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _openCitation(int id) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      await Navigator.of(context).pushNamed("/memory/$id");
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(content: Text("Unable to open memory #$id: $e")),
      );
    }
  }

  Future<void> _showOpenDeepLinkDialog() async {
    final controller = TextEditingController();
    final messenger = ScaffoldMessenger.of(context);
    final raw = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text("Open memory link"),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(
              hintText: "memory://id/12 or /memory/12",
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text("Cancel"),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(controller.text),
              child: const Text("Open"),
            ),
          ],
        );
      },
    );
    if (raw == null) return;
    final id = parseMemoryIdFromDeepLink(raw);
    if (id == null) {
      messenger.showSnackBar(
        const SnackBar(content: Text("Invalid memory deep link format.")),
      );
      return;
    }
    await _openCitation(id);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          TextField(
            controller: _controller,
            decoration: const InputDecoration(
              labelText: "Ask memory assistant",
              hintText: "What did I plan with Rahul?",
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: _loading ? null : _ask,
            icon: const Icon(Icons.smart_toy),
            label: Text(_loading ? "Analyzing..." : "Analyze Conversation"),
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: _showOpenDeepLinkDialog,
            icon: const Icon(Icons.open_in_new),
            label: const Text("Open memory deep link"),
          ),
          const SizedBox(height: 12),
          Card(
            child: ListTile(
              leading: const Icon(Icons.psychology),
              title: const Text("Assistant answer"),
              subtitle: Text("$_answer\n\n$_meta"),
            ),
          ),
          if (_citations.isNotEmpty) ...[
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.centerLeft,
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _citations
                    .map(
                      (id) => ActionChip(
                        avatar: const Icon(Icons.link, size: 16),
                        label: Text("#$id"),
                        onPressed: () => _openCitation(id),
                      ),
                    )
                    .toList(growable: false),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class MemoryDetailScreen extends StatelessWidget {
  final int memoryId;

  const MemoryDetailScreen({super.key, required this.memoryId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Memory #$memoryId"),
        actions: [
          IconButton(
            tooltip: "Copy deep link",
            icon: const Icon(Icons.link),
            onPressed: () async {
              await Clipboard.setData(
                  ClipboardData(text: "memory://id/$memoryId"));
              if (!context.mounted) return;
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text("Deep link copied")));
            },
          ),
        ],
      ),
      body: FutureBuilder<MemoryItem>(
        future: ApiService().getMemoryById(memoryId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
                child: Text("Unable to load memory: ${snapshot.error}"));
          }
          final memory = snapshot.data;
          if (memory == null) {
            return const Center(child: Text("Memory not found."));
          }
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      memory.text,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text("Type: ${memory.type ?? "-"}"),
                    Text("Person: ${memory.person ?? "-"}"),
                    Text("Time: ${memory.time ?? "-"}"),
                    Text("Reminder: ${memory.isReminder ? "yes" : "no"}"),
                    Text("Priority: ${memory.priority ?? "-"}"),
                    Text("Status: ${memory.status ?? "-"}"),
                    Text("Due: ${memory.dueTime ?? "-"}"),
                    const SizedBox(height: 8),
                    Text("Created: ${memory.timestamp}"),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
