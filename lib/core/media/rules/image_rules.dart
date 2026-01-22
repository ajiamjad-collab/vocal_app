import 'package:image_cropper/image_cropper.dart';

enum ImageUseCase { profile, logo, poster, banner, gallery }

class ImageRules {
  final bool allowMultiple;
  final bool enableCrop;
  final CropAspectRatio? aspectRatio;

  /// Hard size limit (prevents huge uploads)
  final int maxBytes;

  /// If above this KB, do an extra resize pass before final compress
  final int resizeThresholdKb;

  final int qualityWifi;
  final int qualityMobile;
  final int qualityOffline;

  final int maxWidthWifi;
  final int maxHeightWifi;

  final int maxWidthMobile;
  final int maxHeightMobile;

  final int maxWidthOffline;
  final int maxHeightOffline;

  const ImageRules({
    required this.allowMultiple,
    required this.enableCrop,
    required this.aspectRatio,
    required this.maxBytes,
    required this.resizeThresholdKb,
    required this.qualityWifi,
    required this.qualityMobile,
    required this.qualityOffline,
    required this.maxWidthWifi,
    required this.maxHeightWifi,
    required this.maxWidthMobile,
    required this.maxHeightMobile,
    required this.maxWidthOffline,
    required this.maxHeightOffline,
  });
}

class ImageUseCaseRules {
  static ImageRules of(ImageUseCase useCase) {
    switch (useCase) {
      case ImageUseCase.profile:
        return const ImageRules(
          allowMultiple: false,
          enableCrop: true,
          aspectRatio: CropAspectRatio(ratioX: 1, ratioY: 1),
          maxBytes: 6 * 1024 * 1024, // allow more input formats, compress later
          resizeThresholdKb: 700,
          qualityWifi: 85,
          qualityMobile: 75,
          qualityOffline: 70,
          maxWidthWifi: 1080,
          maxHeightWifi: 1080,
          maxWidthMobile: 900,
          maxHeightMobile: 900,
          maxWidthOffline: 800,
          maxHeightOffline: 800,
        );

      case ImageUseCase.logo:
        return const ImageRules(
          allowMultiple: false,
          enableCrop: true,
          aspectRatio: null,
          maxBytes: 10 * 1024 * 1024,
          resizeThresholdKb: 900,
          qualityWifi: 92,
          qualityMobile: 88,
          qualityOffline: 85,
          maxWidthWifi: 2000,
          maxHeightWifi: 2000,
          maxWidthMobile: 1600,
          maxHeightMobile: 1600,
          maxWidthOffline: 1400,
          maxHeightOffline: 1400,
        );

      case ImageUseCase.poster:
        return const ImageRules(
          allowMultiple: true,
          enableCrop: true,
          aspectRatio: CropAspectRatio(ratioX: 3, ratioY: 4),
          maxBytes: 16 * 1024 * 1024,
          resizeThresholdKb: 1600,
          qualityWifi: 88,
          qualityMobile: 78,
          qualityOffline: 72,
          maxWidthWifi: 2400,
          maxHeightWifi: 3200,
          maxWidthMobile: 1800,
          maxHeightMobile: 2600,
          maxWidthOffline: 1600,
          maxHeightOffline: 2400,
        );

      case ImageUseCase.banner:
        return const ImageRules(
          allowMultiple: false,
          enableCrop: true,
          aspectRatio: CropAspectRatio(ratioX: 16, ratioY: 9),
          maxBytes: 16 * 1024 * 1024,
          resizeThresholdKb: 1400,
          qualityWifi: 86,
          qualityMobile: 76,
          qualityOffline: 70,
          maxWidthWifi: 3000,
          maxHeightWifi: 1800,
          maxWidthMobile: 2200,
          maxHeightMobile: 1300,
          maxWidthOffline: 1800,
          maxHeightOffline: 1050,
        );

      case ImageUseCase.gallery:
        return const ImageRules(
          allowMultiple: true,
          enableCrop: false,
          aspectRatio: null,
          maxBytes: 20 * 1024 * 1024,
          resizeThresholdKb: 1400,
          qualityWifi: 85,
          qualityMobile: 72,
          qualityOffline: 68,
          maxWidthWifi: 2000,
          maxHeightWifi: 2000,
          maxWidthMobile: 1600,
          maxHeightMobile: 1600,
          maxWidthOffline: 1400,
          maxHeightOffline: 1400,
        );
    }
  }
}
