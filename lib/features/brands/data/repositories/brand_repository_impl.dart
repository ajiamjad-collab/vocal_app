import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:vocal_app/features/brands/domain/entities/brand.dart';
import 'package:vocal_app/features/brands/domain/entities/brand_category.dart';
import 'package:vocal_app/features/brands/domain/repositories/brand_repository.dart';

import '../datasources/brand_remote_ds.dart';

class BrandRepositoryImpl implements BrandRepository {
  final BrandRemoteDataSource remote;
  BrandRepositoryImpl({required this.remote});

  @override
  Future<BrandsPage> getBrandsPage({
    required BrandCategory category,
    required int limit,
    required String searchToken,
    DocumentSnapshot? startAfter,
  }) async {
    final r = await remote.getBrandsPage(
      category: category,
      limit: limit,
      searchToken: searchToken,
      startAfter: startAfter,
    );

    return BrandsPage(items: r.items, lastDoc: r.lastDoc, hasMore: r.hasMore);
  }

  @override
  Stream<Brand> watchBrand(String brandId) => remote.watchBrand(brandId);

  @override
  Stream<List<Brand>> watchBrands({
    required String category,
    String? searchToken,
  }) {
    // ✅ BrandModel extends Brand, so this is already Stream<List<Brand>>
    return remote.watchBrands(category: category, searchToken: searchToken);
  }

  @override
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
  }) async {
    final payloadExtended = <String, dynamic>{
      'contacts': contacts,
      'socialMedia': socialMedia,
      'location': location,
      'branches': branches,
      'workingHours': workingHours,
      'showWorkingHours': showWorkingHours,
      'tags': tags,
      'languagesKnown': languagesKnown,
      'categories': categories,
      'subCategories': subCategories,
      'businessType': businessType,
      'offeringsTypes': offeringsTypes,
      'serviceModes': serviceModes,
      'customerType': customerType,
      'companyType': companyType,
      'companyFounded': companyFounded,
      'gstNumber': gstNumber ?? '',
    };

    return remote.createBrand(
      title: title,
      description: description,
      category: category,
      uiRefs: uiRefs,
      payloadExtended: payloadExtended,
      logoBytes: logoBytes == null ? null : Uint8List.fromList(logoBytes),
      logoFileName: logoFileName,
      logoContentType: logoContentType,
    );
  }

  @override
  Future<void> setBrandMedia({
    required String brandId,
    String? logoUrl,
    String? coverUrl,
  }) {
    return remote.setBrandMedia(
      brandId: brandId,
      logoUrl: logoUrl,
      coverUrl: coverUrl,
    );
  }

  @override
  Future<void> incrementVisit(String brandId) => remote.incrementVisit(brandId);
}
