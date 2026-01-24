part of 'brand_list_bloc.dart';

class BrandListState extends Equatable {
  const BrandListState({
    this.category = 'professional', // ✅ default professional
    this.searchToken = '',
    this.isLoading = false,
    this.items = const [],
    this.error,
  });

  final String category;
  final String searchToken;
  final bool isLoading;
  final List<Brand> items;
  final String? error;

  BrandListState copyWith({
    String? category,
    String? searchToken,
    bool? isLoading,
    List<Brand>? items,
    String? error,
  }) {
    return BrandListState(
      category: category ?? this.category,
      searchToken: searchToken ?? this.searchToken,
      isLoading: isLoading ?? this.isLoading,
      items: items ?? this.items,
      error: error,
    );
  }

  @override
  List<Object?> get props => [category, searchToken, isLoading, items, error];
}
