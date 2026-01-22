//import 'package:isar/isar.dart';
import 'package:isar_community/isar.dart';
import 'cache_store.dart';
import 'models/cache_entry.dart';

class IsarCacheStore implements CacheStore {
  final Isar _isar;

  IsarCacheStore(this._isar);

  @override
  Future<CacheHit?> get(String key, {Duration? ttl}) async {
    final entry = await _isar.cacheEntrys.where().keyEqualTo(key).findFirst();
    if (entry == null) return null;

    final savedAt = DateTime.fromMillisecondsSinceEpoch(entry.savedAtMs);

    final expired = ttl != null
        ? DateTime.now().difference(savedAt) > ttl
        : entry.isExpired;

    if (expired) return null;

    return CacheHit(json: entry.json, savedAt: savedAt, etag: entry.etag);
  }

  @override
  Future<void> set(String key, String json, {Duration? ttl, String? etag}) async {
    final now = DateTime.now().millisecondsSinceEpoch;

    final toSave = CacheEntry()
      ..key = key
      ..json = json
      ..savedAtMs = now
      ..ttlSeconds = ttl == null ? 0 : ttl.inSeconds
      ..etag = etag;

    await _isar.writeTxn(() async {
      await _isar.cacheEntrys.put(toSave);
    });
  }

  @override
  Future<void> remove(String key) async {
    await _isar.writeTxn(() async {
      final existing = await _isar.cacheEntrys.where().keyEqualTo(key).findFirst();
      if (existing != null) {
        await _isar.cacheEntrys.delete(existing.id);
      }
    });
  }

  @override
  Future<void> clear() async {
    await _isar.writeTxn(() async {
      await _isar.cacheEntrys.clear();
    });
  }
}
