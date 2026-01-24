part of 'brand_list_bloc.dart';

sealed class BrandListEvent extends Equatable {
  const BrandListEvent();
  @override
  List<Object?> get props => [];
}

class BrandListStarted extends BrandListEvent {
  const BrandListStarted({required this.category});
  final String category; // personal | professional
  @override
  List<Object?> get props => [category];
}

class BrandListCategoryChanged extends BrandListEvent {
  const BrandListCategoryChanged(this.category);
  final String category;
  @override
  List<Object?> get props => [category];
}

class BrandListSearchChanged extends BrandListEvent {
  const BrandListSearchChanged(this.search);
  final String search;
  @override
  List<Object?> get props => [search];
}

// internal
class _BrandListInternalUpdated extends BrandListEvent {
  const _BrandListInternalUpdated(this.items);
  final List<Brand> items;
  @override
  List<Object?> get props => [items];
}

class _BrandListInternalError extends BrandListEvent {
  const _BrandListInternalError(this.message);
  final String message;
  @override
  List<Object?> get props => [message];
}
