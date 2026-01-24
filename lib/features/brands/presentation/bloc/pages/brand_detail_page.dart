import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vocal_app/core/di/service_locator.dart';
import 'package:vocal_app/core/ui/widgets/app_cached_image.dart';
import 'package:vocal_app/features/brands/presentation/bloc/brand_detail_cubit.dart';

class BrandDetailPage extends StatelessWidget {
  final String brandId;
  const BrandDetailPage({super.key, required this.brandId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<BrandDetailCubit>()..start(brandId),
      child: const _BrandDetailView(),
    );
  }
}

class _BrandDetailView extends StatelessWidget {
  const _BrandDetailView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: BlocBuilder<BrandDetailCubit, BrandDetailState>(
        builder: (_, s) {
          if (s.loading) return const Center(child: CircularProgressIndicator());
          if (s.error != null) return Center(child: Text('Error: ${s.error}'));
          final b = s.brand!;
          final logo = b.logoUrl.trim();

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 34,
                    backgroundColor: Colors.grey.shade200,
                    child: ClipOval(
                      child: logo.isEmpty
                          ? const Icon(Icons.storefront, size: 30)
                          : AppCachedImage(url: logo, width: 68, height: 68),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(b.title, style: Theme.of(context).textTheme.titleLarge),
                        const SizedBox(height: 6),
                        Text('Brand ID: ${b.id}'),
                        Text('Category: ${b.category.name}'),
                        Text('Visits: ${b.visitsCount}'),
                      ],
                    ),
                  )
                ],
              ),
              const SizedBox(height: 16),
              Text(b.description),

              const SizedBox(height: 20),
              const Divider(),
              const Text('Contacts', style: TextStyle(fontWeight: FontWeight.w800)),
              Text((b.contacts ?? {}).toString()),

              const SizedBox(height: 12),
              const Text('Social', style: TextStyle(fontWeight: FontWeight.w800)),
              Text((b.socialMedia ?? {}).toString()),

              const SizedBox(height: 12),
              const Text('Location', style: TextStyle(fontWeight: FontWeight.w800)),
              Text((b.location ?? {}).toString()),
            ],
          );
        },
      ),
    );
  }
}
