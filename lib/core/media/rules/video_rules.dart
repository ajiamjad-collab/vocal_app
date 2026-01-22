enum VideoUseCase {
  profileIntro, // short
  post,         // normal
  story,        // short
  banner,       // medium
  gallery,      // multiple
}

class VideoRules {
  final bool allowMultiple;
  final int maxBytes;
  final int? maxDurationMs;

  /// If above this size, compress
  final int compressThresholdKb;

  final int qualityWifi;    // 0..100
  final int qualityMobile;  // 0..100
  final int qualityOffline; // 0..100

  const VideoRules({
    required this.allowMultiple,
    required this.maxBytes,
    required this.maxDurationMs,
    required this.compressThresholdKb,
    required this.qualityWifi,
    required this.qualityMobile,
    required this.qualityOffline,
  });
}

class VideoUseCaseRules {
  static VideoRules of(VideoUseCase useCase) {
    switch (useCase) {
      case VideoUseCase.profileIntro:
        return const VideoRules(
          allowMultiple: false,
          maxBytes: 120 * 1024 * 1024, // accept big input, compress later
          maxDurationMs: 20 * 1000,
          compressThresholdKb: 6000,
          qualityWifi: 70,
          qualityMobile: 60,
          qualityOffline: 55,
        );

      case VideoUseCase.story:
        return const VideoRules(
          allowMultiple: false,
          maxBytes: 200 * 1024 * 1024,
          maxDurationMs: 30 * 1000,
          compressThresholdKb: 8000,
          qualityWifi: 72,
          qualityMobile: 62,
          qualityOffline: 58,
        );

      case VideoUseCase.post:
        return const VideoRules(
          allowMultiple: false,
          maxBytes: 500 * 1024 * 1024,
          maxDurationMs: null,
          compressThresholdKb: 12000,
          qualityWifi: 78,
          qualityMobile: 66,
          qualityOffline: 60,
        );

      case VideoUseCase.banner:
        return const VideoRules(
          allowMultiple: false,
          maxBytes: 600 * 1024 * 1024,
          maxDurationMs: null,
          compressThresholdKb: 15000,
          qualityWifi: 80,
          qualityMobile: 68,
          qualityOffline: 62,
        );

      case VideoUseCase.gallery:
        return const VideoRules(
          allowMultiple: true,
          maxBytes: 600 * 1024 * 1024,
          maxDurationMs: null,
          compressThresholdKb: 15000,
          qualityWifi: 78,
          qualityMobile: 66,
          qualityOffline: 60,
        );
    }
  }
}
