import '../cache/cache_store.dart';
import '../network/network_info.dart';

class SwrEvent<T> {
  final T data;
  final bool fromCache;
  final DateTime? cacheSavedAt;
  const SwrEvent({required this.data, required this.fromCache, this.cacheSavedAt});
}

Stream<SwrEvent<T>> swrStream<T>({
  required String cacheKey,
  required Duration ttl,
  required CacheStore cache,
  required NetworkInfo net,
  required T Function(String json) decode,
  required String Function(T data) encode,
  required Future<T> Function() fetchRemote,
  bool emitCacheFirst = true,
}) async* {
  // 1) cache
  final hit = await cache.get(cacheKey, ttl: ttl);
  if (hit != null && emitCacheFirst) {
    yield SwrEvent(
      data: decode(hit.json),
      fromCache: true,
      cacheSavedAt: hit.savedAt,
    );
  }

  // 2) refresh only if online
  final online = await net.isOnline;
  if (!online) return;

  final fresh = await fetchRemote();
  await cache.set(cacheKey, encode(fresh), ttl: ttl);
  yield SwrEvent(data: fresh, fromCache: false);
}
