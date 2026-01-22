import 'dart:io' show File;

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:mime/mime.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:video_compress/video_compress.dart';

import '../models/app_media.dart';
import '../rules/video_rules.dart';
import 'media_picker.dart';

class VideoValidationException implements Exception {
  final String message;
  VideoValidationException(this.message);
  @override
  String toString() => 'VideoValidationException: $message';
}

class VideoHelper {
  VideoHelper._();

  static bool _isAllowedVideoMime(String? mime) {
    if (mime == null) return false;
    if (mime.startsWith('video/')) return true;
    return mime == 'application/octet-stream';
  }

  static Future<void> validateOrThrow(
    AppMedia media, {
    required int maxBytes,
    int? maxDurationMs,
  }) async {
    if (media.kind != MediaKind.video) {
      throw VideoValidationException('Not a video.');
    }

    final bytes = await media.readBytes();
    if (bytes.lengthInBytes > maxBytes) {
      final mb = (maxBytes / (1024 * 1024)).toStringAsFixed(0);
      throw VideoValidationException('Video too large. Max ${mb}MB.');
    }

    final mime = lookupMimeType(media.name, headerBytes: bytes);
    if (!_isAllowedVideoMime(mime)) {
      throw VideoValidationException('Unsupported video type: ${mime ?? "unknown"}');
    }

    // Duration check (mobile best-effort)
    if (!kIsWeb && maxDurationMs != null) {
      try {
        final info = await VideoCompress.getMediaInfo(media.xfile.path);
        final dur = info.duration?.round();
        if (dur != null && dur > maxDurationMs) {
          final s = (maxDurationMs / 1000).round();
          throw VideoValidationException('Video too long. Max ${s}s.');
        }
      } catch (_) {
        // If duration reading fails, don’t block
      }
    }
  }

  static Future<AppMedia> withThumbnail(AppMedia media) async {
    if (kIsWeb) return media;

    try {
      final thumb = await VideoCompress.getByteThumbnail(
        media.xfile.path,
        quality: 60,
        position: -1,
      );
      return media.copyWith(thumbnailBytes: thumb);
    } catch (_) {
      return media;
    }
  }

  static Future<AppMedia> smartCompress(
    AppMedia media, {
    required VideoRules rules,
  }) async {
    // Web: keep original
    if (kIsWeb) return media;

    try {
      final file = File(media.xfile.path);
      final kb = (await file.length() / 1024).round();
      if (kb <= rules.compressThresholdKb) return media;

      final conn = await Connectivity().checkConnectivity();
      final wifi = conn.contains(ConnectivityResult.wifi) ||
          conn.contains(ConnectivityResult.ethernet);
      final mobile = conn.contains(ConnectivityResult.mobile);

      final quality = wifi
          ? rules.qualityWifi
          : (mobile ? rules.qualityMobile : rules.qualityOffline);

      final preset = _mapQualityToPreset(quality);

      final MediaInfo? info = await VideoCompress.compressVideo(
        media.xfile.path,
        quality: preset,
        deleteOrigin: false,
        includeAudio: true,
      );

      if (info?.file == null) return media;

      final outFile = info!.file!;
      final dir = await getTemporaryDirectory();
      final targetPath = p.join(
        dir.path,
        '${DateTime.now().microsecondsSinceEpoch}.mp4',
      );

      final moved = await outFile.copy(targetPath);

      final x = XFile(moved.path, name: p.basename(moved.path), mimeType: 'video/mp4');
      return AppMedia(kind: MediaKind.video, xfile: x);
    } catch (_) {
      return media;
    }
  }

  static VideoQuality _mapQualityToPreset(int quality) {
    if (quality >= 80) return VideoQuality.MediumQuality;
    if (quality >= 65) return VideoQuality.LowQuality;
    return VideoQuality.LowQuality;
  }

  static Future<List<AppMedia>> pickProcessAuto({
    required VideoUseCase useCase,
    required bool fromCamera,
    int? limit,
  }) async {
    final rules = VideoUseCaseRules.of(useCase);

    final picked = await MediaPicker.pick(
      kind: MediaKind.video,
      allowMultiple: rules.allowMultiple,
      fromCamera: fromCamera,
      limit: limit,
      maxVideoDuration: rules.maxDurationMs == null
          ? null
          : Duration(milliseconds: rules.maxDurationMs!),
    );

    if (picked.isEmpty) return <AppMedia>[];

    final out = <AppMedia>[];

    for (final m in picked) {
      try {
        await validateOrThrow(
          m,
          maxBytes: rules.maxBytes,
          maxDurationMs: rules.maxDurationMs,
        );

        final withThumb = await withThumbnail(m);
        final compressed = await smartCompress(withThumb, rules: rules);

        // keep thumbnail if we had it
        out.add(
          compressed.thumbnailBytes == null && withThumb.thumbnailBytes != null
              ? compressed.copyWith(thumbnailBytes: withThumb.thumbnailBytes)
              : compressed,
        );
      } catch (_) {
        // skip
      }
    }

    return out;
  }
}
