import 'dart:developer' as developer;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/theme_extensions.dart';
import '../../../../core/design_system/components/app_card.dart';
import '../../../../core/design_system/layout/app_spacing.dart';
import '../../domain/entities/product.dart';

class ProductCard extends StatelessWidget {
  const ProductCard({
    super.key,
    required this.product,
    required this.onTap,
  });

  final Product product;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
      onTap: onTap,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Hero(
            tag: 'product_${product.id}_image',
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: product.thumbnail != null && product.thumbnail!.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: product.thumbnail!,
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => _placeholder(context),
                      errorWidget: (context, url, error) {
                        developer.log('Image load failed: ${product.thumbnail}', name: 'ProductCard');
                        return _placeholder(context);
                      },
                    )
                  : _placeholderWithWarning(context, product.id, 'thumbnail'),
            ),
          ),
          AppSpacing.horizontalMd,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  product.title,
                  style: context.textTheme.titleMedium,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                AppSpacing.verticalXs,
                Text(
                  product.price < 0 ? 'Price unavailable' : '\$${product.price.toStringAsFixed(2)}',
                  style: context.textTheme.titleSmall?.copyWith(
                        color: context.colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                if (product.rating != null) ...[
                  AppSpacing.verticalXs,
                  Row(
                    children: [
                      Icon(Icons.star, size: 14, color: context.appColors.star),
                      AppSpacing.horizontalXs,
                      Text(
                        product.rating!.toStringAsFixed(1),
                        style: context.textTheme.bodySmall,
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _placeholder(BuildContext context) {
    return Container(
      width: 80,
      height: 80,
      color: context.appColors.surfaceVariant,
      child: const Icon(Icons.shopping_bag, size: 32),
    );
  }

  Widget _placeholderWithWarning(BuildContext context, int productId, String kind) {
    developer.log('Missing or invalid image URL ($kind) for product: $productId', name: 'ProductCard');
    return _placeholder(context);
  }
}
