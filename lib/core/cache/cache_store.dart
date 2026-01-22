class CacheHit {
  final String json;
  final DateTime savedAt;
  final String? etag;

  CacheHit({required this.json, required this.savedAt, this.etag});
}

abstract class CacheStore {
  Future<CacheHit?> get(String key, {Duration? ttl});
  Future<void> set(String key, String json, {Duration? ttl, String? etag});
  Future<void> remove(String key);
  Future<void> clear();
}
