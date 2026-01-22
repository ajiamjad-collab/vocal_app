import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../models/app_media.dart';

class MediaDisplay {
  MediaDisplay._();

  static Widget imageFrom(AppMedia media, {BoxFit fit = BoxFit.cover}) {
    // If you have bytes (web or after processing), show memory:
    if (media.bytes != null) {
      return Image.memory(media.bytes!, fit: fit);
    }

    // Mobile local file:
    if (!kIsWeb) {
      return Image.file(media.asFileOrNull()!, fit: fit);
    }

    // Web fallback if bytes missing:
    return const SizedBox.shrink();
  }

  static Widget videoThumbnailOrPlaceholder(
    AppMedia media, {
    double size = 72,
  }) {
    if (media.thumbnailBytes != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.memory(
          media.thumbnailBytes!,
          width: size,
          height: size,
          fit: BoxFit.cover,
        ),
      );
    }

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.black12,
      ),
      child: const Icon(Icons.play_arrow),
    );
  }
}
