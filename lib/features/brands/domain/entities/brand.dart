import 'package:equatable/equatable.dart';
import 'brand_category.dart';

class Brand extends Equatable {
  final String id;
  final String title;
  final String description;
  final BrandCategory category;

  final String createdByUid;
  final String createdByPublicUserId;

  final Map<String, dynamic> uiRefs;

  final String logoUrl;
  final String coverUrl;

  final Map<String, dynamic>? contacts;
  final Map<String, dynamic>? socialMedia;
  final Map<String, dynamic>? location;

  final List<dynamic> branches;
  final Map<String, dynamic> workingHours;
  final bool showWorkingHours;

  final List<String> tags;
  final List<String> languagesKnown;

  final List<String> categories;
  final List<String> subCategories;

  final String businessType;
  final List<String> offeringsTypes;
  final List<String> serviceModes;
  final String customerType;

  final String companyType;
  final String companyFounded;
  final String? gstNumber;

  final int visitsCount;

  const Brand({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.createdByUid,
    required this.createdByPublicUserId,
    required this.uiRefs,
    required this.logoUrl,
    required this.coverUrl,
    required this.contacts,
    required this.socialMedia,
    required this.location,
    required this.branches,
    required this.workingHours,
    required this.showWorkingHours,
    required this.tags,
    required this.languagesKnown,
    required this.categories,
    required this.subCategories,
    required this.businessType,
    required this.offeringsTypes,
    required this.serviceModes,
    required this.customerType,
    required this.companyType,
    required this.companyFounded,
    required this.gstNumber,
    required this.visitsCount,
  });

  @override
  List<Object?> get props => [id, title, category, logoUrl, visitsCount];
}
