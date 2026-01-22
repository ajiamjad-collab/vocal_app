//import 'package:isar/isar.dart';
import 'package:isar_community/isar.dart';


part 'cache_entry.g.dart';

@collection
class CacheEntry {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String key;

  late String json;

  late int savedAtMs;

  late int ttlSeconds;

  String? etag;

  bool get isExpired {
    if (ttlSeconds <= 0) return false;
    final now = DateTime.now().millisecondsSinceEpoch;
    return (now - savedAtMs) > ttlSeconds * 1000;
  }
}


// dart run build_runner build --delete-conflicting-outputs
