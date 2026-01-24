import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:vocal_app/features/brands/domain/entities/brand.dart';
import 'package:vocal_app/features/brands/domain/entities/brand_category.dart';

class BrandModel extends Brand {
  const BrandModel({
    required super.id,
    required super.title,
    required super.description,
    required super.category,
    required super.createdByUid,
    required super.createdByPublicUserId,
    required super.uiRefs,
    required super.logoUrl,
    required super.coverUrl,
    required super.contacts,
    required super.socialMedia,
    required super.location,
    required super.branches,
    required super.workingHours,
    required super.showWorkingHours,
    required super.tags,
    required super.languagesKnown,
    required super.categories,
    required super.subCategories,
    required super.businessType,
    required super.offeringsTypes,
    required super.serviceModes,
    required super.customerType,
    required super.companyType,
    required super.companyFounded,
    required super.gstNumber,
    required super.visitsCount,
  });

  factory BrandModel.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data() ?? <String, dynamic>{};

    return BrandModel(
      id: (d['id'] ?? doc.id).toString(),
      title: (d['title'] ?? '').toString(),
      description: (d['description'] ?? '').toString(),

      // ✅ FIXED: use wire helper
      category: brandCategoryFromWire((d['category'] ?? 'personal').toString()),

      createdByUid: (d['createdByUid'] ?? d['ownerId'] ?? '').toString(),
      createdByPublicUserId: (d['createdByPublicUserId'] ?? '').toString(),

      uiRefs: (d['uiRefs'] is Map)
          ? Map<String, dynamic>.from(d['uiRefs'])
          : <String, dynamic>{},

      logoUrl: (d['logoUrl'] ?? '').toString(),
      coverUrl: (d['coverUrl'] ?? '').toString(),

      contacts: (d['contacts'] is Map)
          ? Map<String, dynamic>.from(d['contacts'])
          : null,
      socialMedia: (d['socialMedia'] is Map)
          ? Map<String, dynamic>.from(d['socialMedia'])
          : null,
      location: (d['location'] is Map)
          ? Map<String, dynamic>.from(d['location'])
          : null,

      branches: (d['branches'] is List) ? List<dynamic>.from(d['branches']) : const [],
      workingHours: (d['workingHours'] is Map)
          ? Map<String, dynamic>.from(d['workingHours'])
          : <String, dynamic>{},
      showWorkingHours: (d['showWorkingHours'] ?? true) == true,

      tags: (d['tags'] is List)
          ? List<String>.from((d['tags'] as List).map((e) => e.toString()))
          : const [],
      languagesKnown: (d['languagesKnown'] is List)
          ? List<String>.from((d['languagesKnown'] as List).map((e) => e.toString()))
          : const [],

      categories: (d['categories'] is List)
          ? List<String>.from((d['categories'] as List).map((e) => e.toString()))
          : const [],
      subCategories: (d['subCategories'] is List)
          ? List<String>.from((d['subCategories'] as List).map((e) => e.toString()))
          : const [],

      businessType: (d['businessType'] ?? '').toString(),
      offeringsTypes: (d['offeringsTypes'] is List)
          ? List<String>.from((d['offeringsTypes'] as List).map((e) => e.toString()))
          : const [],
      serviceModes: (d['serviceModes'] is List)
          ? List<String>.from((d['serviceModes'] as List).map((e) => e.toString()))
          : const [],
      customerType: (d['customerType'] ?? '').toString(),

      companyType: (d['companyType'] ?? '').toString(),
      companyFounded: (d['companyFounded'] ?? '').toString(),
      gstNumber: (d['gstNumber'] ?? '').toString().trim().isEmpty
          ? null
          : (d['gstNumber'] ?? '').toString(),

      visitsCount: (d['visitsCount'] is int)
          ? d['visitsCount'] as int
          : int.tryParse('${d['visitsCount'] ?? 0}') ?? 0,
    );
  }
}
