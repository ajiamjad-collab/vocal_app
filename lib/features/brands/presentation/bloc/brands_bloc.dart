import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vocal_app/features/brands/domain/usecases/get_brands_page.dart';

import 'brands_event.dart';
import 'brands_state.dart';

class BrandsBloc extends Bloc<BrandsEvent, BrandsState> {
  final GetBrandsPage getBrandsPage;

  static const int _pageSize = 20;
  Timer? _debounce;

  BrandsBloc({required this.getBrandsPage}) : super(BrandsState.initial()) {
    on<BrandsStarted>(_onStarted);
    on<BrandsLoadMore>(_onLoadMore);
    on<BrandsSearchChanged>(_onSearchChanged);
    on<BrandsRefresh>(_onRefresh);
  }

  Future<void> _loadFirstPage(Emitter<BrandsState> emit) async {
    emit(state.copyWith(loading: true, error: null, items: [], lastDoc: null, hasMore: true));
    try {
      final page = await getBrandsPage(
        category: state.category,
        limit: _pageSize,
        searchToken: state.searchToken,
        startAfter: null,
      );

      emit(state.copyWith(
        loading: false,
        items: page.items,
        lastDoc: page.lastDoc,
        hasMore: page.hasMore,
      ));
    } catch (e) {
      emit(state.copyWith(loading: false, error: e.toString()));
    }
  }

  Future<void> _onStarted(BrandsStarted event, Emitter<BrandsState> emit) async {
    emit(state.copyWith(category: event.category));
    await _loadFirstPage(emit);
  }

  Future<void> _onRefresh(BrandsRefresh event, Emitter<BrandsState> emit) async {
    await _loadFirstPage(emit);
  }

  Future<void> _onLoadMore(BrandsLoadMore event, Emitter<BrandsState> emit) async {
    if (state.loading || state.loadingMore || !state.hasMore) return;

    emit(state.copyWith(loadingMore: true, error: null));
    try {
      final page = await getBrandsPage(
        category: state.category,
        limit: _pageSize,
        searchToken: state.searchToken,
        startAfter: state.lastDoc,
      );

      emit(state.copyWith(
        loadingMore: false,
        items: [...state.items, ...page.items],
        lastDoc: page.lastDoc,
        hasMore: page.hasMore,
      ));
    } catch (e) {
      emit(state.copyWith(loadingMore: false, error: e.toString()));
    }
  }

  Future<void> _onSearchChanged(BrandsSearchChanged event, Emitter<BrandsState> emit) async {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 280), () async {
      final token = event.query.trim().toLowerCase();
      emit(state.copyWith(searchToken: token));
      await _loadFirstPage(emit);
    });
  }

  @override
  Future<void> close() {
    _debounce?.cancel();
    return super.close();
  }
}
