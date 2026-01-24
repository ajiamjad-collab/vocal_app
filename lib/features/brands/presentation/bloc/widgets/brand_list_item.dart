import 'package:flutter/material.dart';
import 'package:vocal_app/core/ui/widgets/app_cached_image.dart';
import 'package:vocal_app/features/brands/domain/entities/brand.dart';
import 'package:vocal_app/features/brands/domain/entities/brand_category.dart';

class BrandListItem extends StatelessWidget {
  final Brand brand;
  final VoidCallback onTap;

  const BrandListItem({
    super.key,
    required this.brand,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final url = brand.logoUrl.trim();

    return ListTile(
      onTap: onTap,
      leading: CircleAvatar(
        radius: 22,
        backgroundColor: Colors.grey.shade200,
        child: ClipOval(
          child: url.isEmpty
              ? const Icon(Icons.storefront)
              : AppCachedImage(
                  url: url,
                  width: 44,
                  height: 44,
                ),
        ),
      ),
      title: Text(
        brand.title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        '${brand.category.wire} • visits: ${brand.visitsCount}',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: const Icon(Icons.chevron_right),
    );
  }
}
