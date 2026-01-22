import 'dart:io' show File;
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';

enum MediaKind { image, video }

@immutable
class AppMedia {
  final MediaKind kind;
  final XFile xfile;

  /// Web: keep bytes, Mobile: usually null
  final Uint8List? bytes;

  /// Optional extras (mostly useful for video)
  final Uint8List? thumbnailBytes;
  final int? durationMs;

  const AppMedia({
    required this.kind,
    required this.xfile,
    this.bytes,
    this.thumbnailBytes,
    this.durationMs,
  });

  String get name => xfile.name;

  Future<Uint8List> readBytes() async => bytes ?? await xfile.readAsBytes();

  File? asFileOrNull() => kIsWeb ? null : File(xfile.path);

  AppMedia copyWith({
    MediaKind? kind,
    XFile? xfile,
    Uint8List? bytes,
    Uint8List? thumbnailBytes,
    int? durationMs,
  }) {
    return AppMedia(
      kind: kind ?? this.kind,
      xfile: xfile ?? this.xfile,
      bytes: bytes ?? this.bytes,
      thumbnailBytes: thumbnailBytes ?? this.thumbnailBytes,
      durationMs: durationMs ?? this.durationMs,
    );
  }
}
