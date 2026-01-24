import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:vocal_app/features/brands/domain/entities/brand.dart';

import 'package:vocal_app/features/brands/domain/usecases/increment_brand_visit.dart';
import 'package:vocal_app/features/brands/domain/usecases/watch_brand.dart';


class BrandDetailState extends Equatable {
  final bool loading;
  final String? error;
  final Brand? brand;

  const BrandDetailState({required this.loading, required this.error, required this.brand});

  factory BrandDetailState.initial() => const BrandDetailState(loading: true, error: null, brand: null);

  BrandDetailState copyWith({bool? loading, String? error, Brand? brand}) {
    return BrandDetailState(
      loading: loading ?? this.loading,
      error: error,
      brand: brand ?? this.brand,
    );
  }

  @override
  List<Object?> get props => [loading, error, brand];
}

class BrandDetailCubit extends Cubit<BrandDetailState> {
  final WatchBrand watchBrand;
  final IncrementBrandVisit incrementBrandVisit;

  StreamSubscription? _sub;

  BrandDetailCubit({required this.watchBrand, required this.incrementBrandVisit}) : super(BrandDetailState.initial());

  Future<void> start(String brandId) async {
    emit(BrandDetailState.initial());

    // Fire-and-forget visit increment
    unawaited(incrementBrandVisit(brandId));

    _sub?.cancel();
    _sub = watchBrand(brandId).listen(
      (b) => emit(state.copyWith(loading: false, error: null, brand: b)),
      onError: (e) => emit(state.copyWith(loading: false, error: e.toString())),
    );
  }

  @override
  Future<void> close() async {
    await _sub?.cancel();
    return super.close();
  }
}
