import '../entities/brand_category.dart';
import '../repositories/brand_repository.dart';

class CreateBrand {
  final BrandRepository repo;
  CreateBrand(this.repo);

  Future<String> call({
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
  }) {
    return repo.createBrand(
      title: title,
      description: description,
      category: category,
      uiRefs: uiRefs,
      contacts: contacts,
      socialMedia: socialMedia,
      location: location,
      branches: branches,
      workingHours: workingHours,
      showWorkingHours: showWorkingHours,
      tags: tags,
      languagesKnown: languagesKnown,
      categories: categories,
      subCategories: subCategories,
      businessType: businessType,
      offeringsTypes: offeringsTypes,
      serviceModes: serviceModes,
      customerType: customerType,
      companyType: companyType,
      companyFounded: companyFounded,
      gstNumber: gstNumber,
      logoBytes: logoBytes,
      logoFileName: logoFileName,
      logoContentType: logoContentType,
    );
  }
}
