import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:vocal_app/core/di/service_locator.dart';
import 'package:vocal_app/features/brands/domain/repositories/brand_repository.dart';
import 'package:vocal_app/features/brands/presentation/bloc/brand_list_bloc.dart';
import 'package:vocal_app/features/brands/presentation/bloc/pages/brand_list_page.dart';

class BrandTabPage extends StatelessWidget {
  const BrandTabPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => BrandListBloc(sl<BrandRepository>())
        ..add(const BrandListStarted(category: 'professional')),
      child: const BrandListPage(),
    );
  }
}
