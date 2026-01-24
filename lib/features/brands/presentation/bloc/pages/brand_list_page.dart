import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:vocal_app/features/brands/presentation/bloc/brand_list_bloc.dart';
import 'package:vocal_app/features/brands/presentation/bloc/pages/brand_create_page.dart';
import 'brand_detail_page.dart';

class BrandListPage extends StatefulWidget {
  const BrandListPage({super.key});

  @override
  State<BrandListPage> createState() => _BrandListPageState();
}

class _BrandListPageState extends State<BrandListPage> {
  final _search = TextEditingController();

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  void _restartWatch(BuildContext context) {
    // Always professional only
    context.read<BrandListBloc>().add(const BrandListStarted(category: 'professional'));
    final token = _search.text.trim();
    context.read<BrandListBloc>().add(BrandListSearchChanged(token));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Professional Brands'),
        actions: [
          IconButton(
            tooltip: 'Add Brand',
            icon: const Icon(Icons.add),
            onPressed: () async {
              final created = await Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const BrandCreatePage()),
              );
              if (created == true && context.mounted) {
                _restartWatch(context);
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
            child: TextField(
              controller: _search,
              decoration: const InputDecoration(
                hintText: 'Search brands...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(), // ✅ default theme border
              ),
              onChanged: (_) => _restartWatch(context),
            ),
          ),
          Expanded(
            child: BlocBuilder<BrandListBloc, BrandListState>(
              builder: (context, state) {
                if (state.isLoading) return const Center(child: CircularProgressIndicator());
                if (state.error != null) return Center(child: Text('Error: ${state.error}'));
                if (state.items.isEmpty) return const Center(child: Text('No brands found.'));

                return RefreshIndicator(
                  onRefresh: () async => _restartWatch(context),
                  child: ListView.separated(
                    itemCount: state.items.length,
                    separatorBuilder: (_, _) => const Divider(height: 1),
                    itemBuilder: (_, i) {
                      final b = state.items[i];
                      return ListTile(
                        title: Text(b.title),
                        subtitle: Text(
                          b.description,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => BrandDetailPage(brandId: b.id)),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
