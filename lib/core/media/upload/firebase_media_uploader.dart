import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';

import '../models/app_media.dart';
import 'upload_types.dart';

class FirebaseMediaUploader {
  final FirebaseStorage storage;

  FirebaseMediaUploader({FirebaseStorage? storage})
      : storage = storage ?? FirebaseStorage.instance;

  Future<UploadController> upload({
    required AppMedia media,
    required String storagePath,
    SettableMetadata? metadata,
  }) async {
    final ref = storage.ref().child(storagePath);

    final defaultMeta = SettableMetadata(
      contentType: media.kind == MediaKind.video ? 'video/mp4' : 'image/jpeg',
      cacheControl: 'public,max-age=86400',
    );

    final meta = metadata ?? defaultMeta;

    final UploadTask task = kIsWeb
        ? ref.putData(await media.readBytes(), meta)
        : ref.putFile(media.asFileOrNull()!, meta);

    final progress = task.snapshotEvents.map((snap) {
      final total = snap.totalBytes;
      if (total == 0) return 0.0;
      return snap.bytesTransferred / total;
    });

    return UploadController(task: task, progress: progress);
  }

  Future<UploadResult> waitForResult({
    required UploadController controller,
  }) async {
    final snap = await controller.task;
    final url = await snap.ref.getDownloadURL();
    return UploadResult(path: snap.ref.fullPath, downloadUrl: url);
  }
}
