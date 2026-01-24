import 'dart:async';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vocal_app/features/brands/domain/entities/brand.dart';
import '../../domain/repositories/brand_repository.dart';

part 'brand_list_state.dart';
part 'brand_list_event.dart';

class BrandListBloc extends Bloc<BrandListEvent, BrandListState> {
  BrandListBloc(this._repo) : super(const BrandListState()) {
    on<BrandListStarted>(_onStarted);
    on<BrandListSearchChanged>(_onSearchChanged);
    on<BrandListCategoryChanged>(_onCategoryChanged);

    // ✅ FIX: register internal handlers
    on<_BrandListInternalUpdated>(_onInternalUpdated);
    on<_BrandListInternalError>(_onInternalError);
  }

  final BrandRepository _repo;
  StreamSubscription<List<Brand>>? _sub;

  Future<void> _onStarted(BrandListStarted e, Emitter<BrandListState> emit) async {
    emit(state.copyWith(category: e.category, isLoading: true, error: null));
    await _watch(emit, category: e.category, token: state.searchToken);
  }

  Future<void> _onCategoryChanged(BrandListCategoryChanged e, Emitter<BrandListState> emit) async {
    emit(state.copyWith(category: e.category, isLoading: true, error: null));
    await _watch(emit, category: e.category, token: state.searchToken);
  }

  Future<void> _onSearchChanged(BrandListSearchChanged e, Emitter<BrandListState> emit) async {
    final token = e.search.trim().toLowerCase();
    emit(state.copyWith(searchToken: token, isLoading: true, error: null));
    await _watch(emit, category: state.category, token: token);
  }

  void _onInternalUpdated(_BrandListInternalUpdated e, Emitter<BrandListState> emit) {
    emit(state.copyWith(items: e.items, isLoading: false, error: null));
  }

  void _onInternalError(_BrandListInternalError e, Emitter<BrandListState> emit) {
    emit(state.copyWith(isLoading: false, error: e.message));
  }

  Future<void> _watch(Emitter<BrandListState> emit, {required String category, required String token}) async {
    await _sub?.cancel();

    _sub = _repo
        .watchBrands(category: category, searchToken: token.isEmpty ? null : token)
        .listen(
          (items) => add(_BrandListInternalUpdated(items)),
          onError: (err) => add(_BrandListInternalError(err.toString())),
        );
  }

  @override
  Future<void> close() async {
    await _sub?.cancel();
    return super.close();
  }
}
