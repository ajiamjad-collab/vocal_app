import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/brand_category.dart';
import '../../domain/usecases/create_brand.dart';

class BrandCreateState extends Equatable {
  final bool loading;
  final String? error;
  final String? brandId;

  const BrandCreateState({required this.loading, required this.error, required this.brandId});

  factory BrandCreateState.initial() => const BrandCreateState(loading: false, error: null, brandId: null);

  BrandCreateState copyWith({bool? loading, String? error, String? brandId}) {
    return BrandCreateState(
      loading: loading ?? this.loading,
      error: error,
      brandId: brandId ?? this.brandId,
    );
  }

  @override
  List<Object?> get props => [loading, error, brandId];
}

class BrandCreateCubit extends Cubit<BrandCreateState> {
  final CreateBrand createBrand;
  BrandCreateCubit({required this.createBrand}) : super(BrandCreateState.initial());

  Future<void> submit({
    required String title,
    required String description,
    required BrandCategory category,
    required Map<String, dynamic> uiRefs,

    required Map<String, dynamic> contacts,
    required Map<String, dynamic> socialMedia,
    required Map<String, dynamic> location,
    required List<Map<String, dynamic>> branches,
    required Map<String, dynamic> workingHours,
    required bool showWorkingHours,

    required List<String> tags,
    required List<String> languagesKnown,
    required List<String> categories,
    required List<String> subCategories,

    required String businessType,
    required List<String> offeringsTypes,
    required List<String> serviceModes,
    required String customerType,

    required String companyType,
    required String companyFounded,
    required String? gstNumber,

    required List<int>? logoBytes,
    required String? logoFileName,
    required String? logoContentType,
  }) async {
    emit(state.copyWith(loading: true, error: null, brandId: null));
    try {
      final id = await createBrand(
        title: title,
        description: description,
        category: category,
        uiRefs: uiRefs,
        contacts: contacts,
        socialMedia: socialMedia,
        location: location,
        branches: branches,
        workingHours: workingHours,
        showWorkingHours: showWorkingHours,
        tags: tags,
        languagesKnown: languagesKnown,
        categories: categories,
        subCategories: subCategories,
        businessType: businessType,
        offeringsTypes: offeringsTypes,
        serviceModes: serviceModes,
        customerType: customerType,
        companyType: companyType,
        companyFounded: companyFounded,
        gstNumber: gstNumber,
        logoBytes: logoBytes,
        logoFileName: logoFileName,
        logoContentType: logoContentType,
      );

      emit(state.copyWith(loading: false, brandId: id));
    } catch (e) {
      emit(state.copyWith(loading: false, error: e.toString()));
    }
  }
}
