import 'package:equatable/equatable.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:vocal_app/features/brands/domain/entities/brand.dart';
import 'package:vocal_app/features/brands/domain/entities/brand_category.dart';


class BrandsState extends Equatable {
  final BrandCategory category;
  final String searchToken;

  final bool loading;
  final bool loadingMore;
  final String? error;

  final List<Brand> items;
  final DocumentSnapshot? lastDoc;
  final bool hasMore;

  const BrandsState({
    required this.category,
    required this.searchToken,
    required this.loading,
    required this.loadingMore,
    required this.error,
    required this.items,
    required this.lastDoc,
    required this.hasMore,
  });

  factory BrandsState.initial() => const BrandsState(
        category: BrandCategory.personal,
        searchToken: '',
        loading: true,
        loadingMore: false,
        error: null,
        items: [],
        lastDoc: null,
        hasMore: true,
      );

  BrandsState copyWith({
    BrandCategory? category,
    String? searchToken,
    bool? loading,
    bool? loadingMore,
    String? error,
    List<Brand>? items,
    DocumentSnapshot? lastDoc,
    bool? hasMore,
  }) {
    return BrandsState(
      category: category ?? this.category,
      searchToken: searchToken ?? this.searchToken,
      loading: loading ?? this.loading,
      loadingMore: loadingMore ?? this.loadingMore,
      error: error,
      items: items ?? this.items,
      lastDoc: lastDoc ?? this.lastDoc,
      hasMore: hasMore ?? this.hasMore,
    );
  }

  @override
  List<Object?> get props => [category, searchToken, loading, loadingMore, error, items, lastDoc, hasMore];
}
