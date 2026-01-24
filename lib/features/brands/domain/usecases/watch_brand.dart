import 'package:vocal_app/features/brands/domain/entities/brand.dart';


import '../repositories/brand_repository.dart';

class WatchBrand {
  final BrandRepository repo;
  WatchBrand(this.repo);

  Stream<Brand> call(String brandId) => repo.watchBrand(brandId);
}
