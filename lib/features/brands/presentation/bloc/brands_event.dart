import 'package:equatable/equatable.dart';
import 'package:vocal_app/features/brands/domain/entities/brand_category.dart';


sealed class BrandsEvent extends Equatable {
  const BrandsEvent();
  @override
  List<Object?> get props => [];
}

class BrandsStarted extends BrandsEvent {
  final BrandCategory category;
  const BrandsStarted(this.category);
  @override
  List<Object?> get props => [category];
}

class BrandsLoadMore extends BrandsEvent {
  const BrandsLoadMore();
}

class BrandsSearchChanged extends BrandsEvent {
  final String query;
  const BrandsSearchChanged(this.query);
  @override
  List<Object?> get props => [query];
}

class BrandsRefresh extends BrandsEvent {
  const BrandsRefresh();
}
