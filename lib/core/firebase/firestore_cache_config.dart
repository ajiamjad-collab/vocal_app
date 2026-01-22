import 'package:cloud_firestore/cloud_firestore.dart';

Future<void> configureFirestoreOfflineCache() async {
  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: true,
    cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
  );
}
