import 'dart:io' show File;
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:mime/mime.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../models/app_media.dart';
import '../rules/image_rules.dart';
import 'media_picker.dart';

class ImageValidationException implements Exception {
  final String message;
  ImageValidationException(this.message);
  @override
  String toString() => 'ImageValidationException: $message';
}

class ImageHelper {
  ImageHelper._();

  // Accept "almost all" images.
  // (If you want stricter control, restrict this.)
  static bool _isAllowedImageMime(String? mime) {
    if (mime == null) return false;
    if (mime.startsWith('image/')) return true;

    // some pickers return odd values; keep small allowlist
    return mime == 'application/octet-stream';
  }

  static Future<void> validateOrThrow(
    AppMedia media, {
    required int maxBytes,
  }) async {
    if (media.kind != MediaKind.image) {
      throw ImageValidationException('Not an image.');
    }

    final bytes = await media.readBytes();
    if (bytes.lengthInBytes > maxBytes) {
      final mb = (maxBytes / (1024 * 1024)).toStringAsFixed(0);
      throw ImageValidationException('Image too large. Max ${mb}MB.');
    }

    final mime = lookupMimeType(media.name, headerBytes: bytes);
    if (!_isAllowedImageMime(mime)) {
      throw ImageValidationException('Unsupported image type: ${mime ?? "unknown"}');
    }
  }

  static Future<AppMedia?> crop({
    required BuildContext? Function() getContext, // pass: () => mounted ? context : null
    required AppMedia media,
    required bool enable,
    CropAspectRatio? aspectRatio,
    String toolbarTitle = 'Crop',
  }) async {
    if (!enable) return media;

    try {
      final ctx = getContext();
      if (ctx == null) return null;

      // Cropper needs a file path; on web cropper uses WebUiSettings context.
      final CroppedFile? cropped = await ImageCropper().cropImage(
        sourcePath: media.xfile.path,
        compressQuality: 100,
        aspectRatio: aspectRatio,
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: toolbarTitle,
            lockAspectRatio: aspectRatio != null,
          ),
          IOSUiSettings(
            title: toolbarTitle,
            aspectRatioLockEnabled: aspectRatio != null,
          ),
          WebUiSettings(context: ctx),
        ],
      );

      if (cropped == null) return null;

      final x = XFile(cropped.path, name: p.basename(cropped.path));
      return AppMedia(
        kind: MediaKind.image,
        xfile: x,
        bytes: kIsWeb ? await x.readAsBytes() : null,
      );
    } catch (_) {
      return null;
    }
  }

  static Future<AppMedia?> smartCompress(
    AppMedia media, {
    required ImageRules rules,
    bool keepExif = true,
  }) async {
    try {
      final conn = await Connectivity().checkConnectivity();
      final wifi = conn.contains(ConnectivityResult.wifi) ||
          conn.contains(ConnectivityResult.ethernet);
      final mobile = conn.contains(ConnectivityResult.mobile);

      final quality = wifi
          ? rules.qualityWifi
          : (mobile ? rules.qualityMobile : rules.qualityOffline);

      final maxW = wifi
          ? rules.maxWidthWifi
          : (mobile ? rules.maxWidthMobile : rules.maxWidthOffline);

      final maxH = wifi
          ? rules.maxHeightWifi
          : (mobile ? rules.maxHeightMobile : rules.maxHeightOffline);

      // ✅ Normalize output to JPEG so you always "support" display/decode consistently.
      if (kIsWeb) {
        final bytes = await media.readBytes();
        final out = await FlutterImageCompress.compressWithList(
          bytes,
          quality: quality,
          minWidth: maxW,
          minHeight: maxH,
          keepExif: keepExif,
          format: CompressFormat.jpeg,
        );

        final x = XFile.fromData(out, name: _toJpg(media.name), mimeType: 'image/jpeg');
        return AppMedia(kind: MediaKind.image, xfile: x, bytes: out);
      }

      File file = File(media.xfile.path);
      final kb = (await file.length() / 1024).round();

      // resize pass if huge
      if (kb > rules.resizeThresholdKb) {
        final resized = await _compressFileToTemp(
          file,
          quality: 90,
          minWidth: maxW,
          minHeight: maxH,
          keepExif: keepExif,
        );
        if (resized != null) file = resized;
      }

      final compressed = await _compressFileToTemp(
        file,
        quality: quality,
        minWidth: maxW,
        minHeight: maxH,
        keepExif: keepExif,
      );

      if (compressed == null) return media;

      final x = XFile(compressed.path, name: p.basename(compressed.path), mimeType: 'image/jpeg');
      return AppMedia(kind: MediaKind.image, xfile: x);
    } catch (_) {
      return media;
    }
  }

  static Future<List<AppMedia>> pickProcessAuto({
    required BuildContext? Function() getContext,
    required ImageUseCase useCase,
    required bool fromCamera,
    int? limit,
  }) async {
    final rules = ImageUseCaseRules.of(useCase);

    final picked = await MediaPicker.pick(
      kind: MediaKind.image,
      allowMultiple: rules.allowMultiple,
      fromCamera: fromCamera,
      limit: limit,
    );

    if (picked.isEmpty) return <AppMedia>[];

    final out = <AppMedia>[];

    for (final m in picked) {
      try {
        await validateOrThrow(m, maxBytes: rules.maxBytes);

        AppMedia current = m;

        if (rules.enableCrop) {
          final cropped = await crop(
            getContext: getContext,
            media: current,
            enable: true,
            aspectRatio: rules.aspectRatio,
            toolbarTitle: _title(useCase),
          );
          if (cropped == null) continue;
          current = cropped;
        }

        final compressed = await smartCompress(current, rules: rules);
        out.add(compressed ?? current);
      } catch (_) {
        // skip
      }
    }

    return out;
  }

  static Future<AppMedia?> pickProcessSingle({
    required BuildContext? Function() getContext,
    required ImageUseCase useCase,
    required bool fromCamera,
  }) async {
    final list = await pickProcessAuto(
      getContext: getContext,
      useCase: useCase,
      fromCamera: fromCamera,
      limit: 1,
    );
    return list.isEmpty ? null : list.first;
  }

  static Future<List<AppMedia>> pickProcessMultiple({
    required BuildContext? Function() getContext,
    required ImageUseCase useCase,
    int? limit,
  }) {
    return pickProcessAuto(
      getContext: getContext,
      useCase: useCase,
      fromCamera: false,
      limit: limit,
    );
  }

  static Future<File?> _compressFileToTemp(
    File file, {
    required int quality,
    required int minWidth,
    required int minHeight,
    required bool keepExif,
  }) async {
    final dir = await getTemporaryDirectory();
    final target = p.join(dir.path, '${DateTime.now().microsecondsSinceEpoch}.jpg');

    final out = await FlutterImageCompress.compressAndGetFile(
      file.path,
      target,
      quality: quality,
      minWidth: minWidth,
      minHeight: minHeight,
      keepExif: keepExif,
      format: CompressFormat.jpeg,
    );

    return out == null ? null : File(out.path);
  }

  static String _toJpg(String name) {
    final base = name.replaceAll(RegExp(r'\.[^.]+$'), '');
    return '$base.jpg';
  }

  static String _title(ImageUseCase useCase) {
    switch (useCase) {
      case ImageUseCase.profile:
        return 'Crop Profile';
      case ImageUseCase.logo:
        return 'Crop Logo';
      case ImageUseCase.poster:
        return 'Crop Poster';
      case ImageUseCase.banner:
        return 'Crop Banner';
      case ImageUseCase.gallery:
        return 'Crop';
    }
  }
}
