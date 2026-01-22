import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import '../models/app_media.dart';

class MediaPicker {
  MediaPicker._();
  static final ImagePicker _picker = ImagePicker();

  static Future<List<AppMedia>> pick({
    required MediaKind kind,
    required bool allowMultiple,
    required bool fromCamera,
    int? limit,
    Duration? maxVideoDuration,
  }) async {
    try {
      if (kind == MediaKind.image) {
        if (allowMultiple) {
          final xs = await _picker.pickMultiImage(limit: limit);
          final out = <AppMedia>[];
          for (final x in xs) {
            out.add(
              AppMedia(
                kind: MediaKind.image,
                xfile: x,
                bytes: kIsWeb ? await x.readAsBytes() : null,
              ),
            );
          }
          return out;
        } else {
          final XFile? x = await _picker.pickImage(
            source: fromCamera ? ImageSource.camera : ImageSource.gallery,
          );
          if (x == null) return <AppMedia>[];
          return <AppMedia>[
            AppMedia(
              kind: MediaKind.image,
              xfile: x,
              bytes: kIsWeb ? await x.readAsBytes() : null,
            ),
          ];
        }
      }

      // video
      if (allowMultiple) {
        // Best-effort multi-pick (depends on image_picker version).
        final dynamic dynPicker = _picker;
        final List<XFile> files = await dynPicker.pickMultipleMedia(limit: limit);

        final out = <AppMedia>[];
        for (final x in files) {
          out.add(
            AppMedia(
              kind: MediaKind.video,
              xfile: x,
              bytes: kIsWeb ? await x.readAsBytes() : null,
            ),
          );
        }
        return out;
      } else {
        final XFile? x = await _picker.pickVideo(
          source: fromCamera ? ImageSource.camera : ImageSource.gallery,
          maxDuration: maxVideoDuration,
        );
        if (x == null) return <AppMedia>[];
        final Uint8List? bytes = kIsWeb ? await x.readAsBytes() : null;

        return <AppMedia>[
          AppMedia(kind: MediaKind.video, xfile: x, bytes: bytes),
        ];
      }
    } catch (_) {
      return <AppMedia>[];
    }
  }
}
