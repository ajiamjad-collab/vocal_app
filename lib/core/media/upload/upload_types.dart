import 'package:firebase_storage/firebase_storage.dart';

class UploadResult {
  final String path;
  final String downloadUrl;
  const UploadResult({required this.path, required this.downloadUrl});
}

class UploadController {
  final UploadTask task;
  final Stream<double> progress; // 0..1
  const UploadController({required this.task, required this.progress});

  Future<bool> pause() => task.pause();
  Future<bool> resume() => task.resume();
  Future<bool> cancel() => task.cancel();
}
