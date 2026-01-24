import 'package:cloud_firestore/cloud_firestore.dart';
import '../entities/brand_category.dart';
import '../repositories/brand_repository.dart';

class GetBrandsPage {
  final BrandRepository repo;
  GetBrandsPage(this.repo);

  Future<BrandsPage> call({
    required BrandCategory category,
    required int limit,
    required String searchToken,
    DocumentSnapshot? startAfter,
  }) {
    return repo.getBrandsPage(
      category: category,
      limit: limit,
      searchToken: searchToken,
      startAfter: startAfter,
    );
  }
}
