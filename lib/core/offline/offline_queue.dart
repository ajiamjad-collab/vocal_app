import 'dart:convert';
import 'dart:async';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

typedef OfflineTaskRunner = Future<void> Function(OfflineTask task);

class OfflineTask {
  final String id;
  final String type;
  final Map<String, dynamic> payload;
  final int retries;
  final int createdAtMs;

  OfflineTask({
    required this.id,
    required this.type,
    required this.payload,
    required this.retries,
    required this.createdAtMs,
  });

  OfflineTask copyWith({int? retries}) => OfflineTask(
        id: id,
        type: type,
        payload: payload,
        retries: retries ?? this.retries,
        createdAtMs: createdAtMs,
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "type": type,
        "payload": payload,
        "retries": retries,
        "createdAtMs": createdAtMs,
      };

  static OfflineTask fromJson(Map<String, dynamic> json) => OfflineTask(
        id: json["id"].toString(),
        type: json["type"].toString(),
        payload: Map<String, dynamic>.from(json["payload"] ?? {}),
        retries: (json["retries"] ?? 0) as int,
        createdAtMs: (json["createdAtMs"] ?? DateTime.now().millisecondsSinceEpoch) as int,
      );
}

class OfflineQueue {
  static const _key = "offline_queue_v1";

  // Limits
  static const int _maxRetries = 5;
  static const int _maxAgeMs = 7 * 24 * 60 * 60 * 1000; // 7 days

  final SharedPreferences prefs;
  final Connectivity connectivity;
  final OfflineTaskRunner runner;

  // ✅ NEW: connectivity_plus returns Stream<List<ConnectivityResult>>
  StreamSubscription<List<ConnectivityResult>>? _sub;

  bool _processing = false;

  OfflineQueue({
    required this.prefs,
    required this.connectivity,
    required this.runner,
  });

  Future<void> start() async {
    await _sub?.cancel();

    // ✅ NEW: stream gives List<ConnectivityResult>
    _sub = connectivity.onConnectivityChanged.listen((_) {
      process();
    });

    await process();
  }

  Future<void> stop() async {
    await _sub?.cancel();
    _sub = null;
  }

  Future<void> enqueue(String type, Map<String, dynamic> payload) async {
    final now = DateTime.now().millisecondsSinceEpoch;

    final task = OfflineTask(
      id: "$type-$now-${payload.hashCode}",
      type: type,
      payload: payload,
      retries: 0,
      createdAtMs: now,
    );

    final list = _load();
    list.add(task);
    await _save(list);

    await process();
  }

  Future<void> process() async {
    if (_processing) return;

    final online = await _isOnline();
    if (!online) return;

    _processing = true;
    try {
      var list = _load();

      // Cleanup old tasks
      final now = DateTime.now().millisecondsSinceEpoch;
      list = list.where((t) => (now - t.createdAtMs) <= _maxAgeMs).toList();

      if (list.isEmpty) {
        await _save([]);
        return;
      }

      final remaining = <OfflineTask>[];

      for (final task in list) {
        try {
          await runner(task);
        } catch (_) {
          final nextRetries = task.retries + 1;
          if (nextRetries >= _maxRetries) {
            // drop permanently
            continue;
          }

          // backoff
          final delayMs = 300 * (1 << (nextRetries - 1)); // 300, 600, 1200, 2400...
          await Future.delayed(Duration(milliseconds: delayMs.clamp(300, 5000)));

          remaining.add(task.copyWith(retries: nextRetries));
        }
      }

      await _save(remaining);
    } finally {
      _processing = false;
    }
  }

  // ✅ NEW: checkConnectivity now returns List<ConnectivityResult>
  Future<bool> _isOnline() async {
    final results = await connectivity.checkConnectivity();

    // online if ANY result is not none
    return results.any((r) => r != ConnectivityResult.none);
  }

  List<OfflineTask> _load() {
    final raw = prefs.getString(_key);
    if (raw == null || raw.trim().isEmpty) return [];

    final decoded = jsonDecode(raw);
    if (decoded is! List) return [];

    return decoded
        .map((e) => OfflineTask.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  Future<void> _save(List<OfflineTask> tasks) async {
    final raw = jsonEncode(tasks.map((t) => t.toJson()).toList());
    await prefs.setString(_key, raw);
  }
}
