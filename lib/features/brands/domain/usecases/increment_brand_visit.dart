import '../repositories/brand_repository.dart';

class IncrementBrandVisit {
  final BrandRepository repo;
  IncrementBrandVisit(this.repo);

  Future<void> call(String brandId) => repo.incrementVisit(brandId);
}
