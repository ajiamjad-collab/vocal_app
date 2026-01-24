import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

class StorageUploader {
  StorageUploader({FirebaseStorage? storage})
      : _storage = storage ?? FirebaseStorage.instance;

  final FirebaseStorage _storage;

  Future<String> uploadFile({
    required File file,
    required String path,
    String? contentType,
  }) async {
    final ref = _storage.ref(path);
    final meta = SettableMetadata(contentType: contentType ?? 'image/jpeg');
    final task = await ref.putFile(file, meta);
    return task.ref.getDownloadURL();
  }
}
