import 'package:cloud_firestore/cloud_firestore.dart';
import '../entities/brand.dart';
import '../entities/brand_category.dart';

class BrandsPage {
  final List<Brand> items;
  final DocumentSnapshot? lastDoc;
  final bool hasMore;

  const BrandsPage({
    required this.items,
    required this.lastDoc,
    required this.hasMore,
  });
}

abstract class BrandRepository {
  Future<BrandsPage> getBrandsPage({
    required BrandCategory category,
    required int limit,
    required String searchToken,
    DocumentSnapshot? startAfter,
  });

  Stream<Brand> watchBrand(String brandId);

  /// watch list (used by BrandListBloc)
  Stream<List<Brand>> watchBrands({
    required String category, // 'personal' | 'professional'
    String? searchToken,
  });

  Future<String> createBrand({
    required String title,
    required String description,
    required BrandCategory category,
    required Map<String, dynamic> uiRefs,
    required Map<String, dynamic> contacts,
    required Map<String, dynamic> socialMedia,
    required Map<String, dynamic> location,
    required List<Map<String, dynamic>> branches,
    required Map<String, dynamic> workingHours,
    required bool showWorkingHours,
    required List<String> tags,
    required List<String> languagesKnown,
    required List<String> categories,
    required List<String> subCategories,
    required String businessType,
    required List<String> offeringsTypes,
    required List<String> serviceModes,
    required String customerType,
    required String companyType,
    required String companyFounded,
    required String? gstNumber,
    required List<int>? logoBytes,
    required String? logoFileName,
    required String? logoContentType,
  });

  Future<void> setBrandMedia({
    required String brandId,
    String? logoUrl,
    String? coverUrl,
  });

  Future<void> incrementVisit(String brandId);
}
