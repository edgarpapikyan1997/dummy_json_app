import 'dart:developer' as developer;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/theme_extensions.dart';
import '../../../../core/design_system/layout/app_spacing.dart';
import '../../domain/entities/product.dart';

class ProductDetailContent extends StatelessWidget {
  const ProductDetailContent({super.key, required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (product.images != null && product.images!.isNotEmpty)
            Hero(
              tag: 'product_${product.id}_image',
              child: SizedBox(
                height: 280,
                child: PageView.builder(
                  itemCount: product.images!.length,
                  itemBuilder: (context, index) {
                    final url = product.images![index];
                    return CachedNetworkImage(
                      imageUrl: url,
                      height: 280,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => _imagePlaceholder(context),
                      errorWidget: (context, url, error) {
                        developer.log('Image load failed: $url', name: 'ProductDetailContent');
                        return Container(
                          color: context.appColors.surfaceVariant,
                          child: const Icon(Icons.broken_image, size: 64),
                        );
                      },
                    );
                  },
                ),
              ),
            )
          else if (product.thumbnail != null && product.thumbnail!.isNotEmpty)
            Hero(
              tag: 'product_${product.id}_image',
              child: CachedNetworkImage(
                imageUrl: product.thumbnail!,
                height: 280,
                fit: BoxFit.cover,
                placeholder: (context, url) => _imagePlaceholder(context),
                errorWidget: (context, url, error) {
                  developer.log('Image load failed: ${product.thumbnail}', name: 'ProductDetailContent');
                  return Container(
                    height: 280,
                    color: context.appColors.surfaceVariant,
                    child: const Icon(Icons.shopping_bag, size: 64),
                  );
                },
              ),
            )
          else
            Hero(
              tag: 'product_${product.id}_image',
              child: _buildPlaceholderWithWarning(context),
            ),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.title,
                  style: context.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                AppSpacing.verticalSm,
                Row(
                  children: [
                    Text(
                      product.price < 0 ? 'Price unavailable' : '\$${product.price.toStringAsFixed(2)}',
                      style: context.textTheme.titleLarge?.copyWith(
                            color: context.colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    if (product.discountPercentage != null) ...[
                      AppSpacing.horizontalMd,
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
                        decoration: BoxDecoration(
                          color: context.appColors.success.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '${product.discountPercentage!.toStringAsFixed(0)}% off',
                          style: context.textTheme.labelMedium?.copyWith(
                            color: context.appColors.success,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                if (product.rating != null) ...[
                  AppSpacing.verticalSm,
                  Row(
                    children: [
                      Icon(Icons.star, color: context.appColors.star, size: 20),
                      AppSpacing.horizontalXs,
                      Text(
                        product.rating!.toStringAsFixed(1),
                        style: context.textTheme.titleMedium,
                      ),
                    ],
                  ),
                ],
                AppSpacing.verticalSm,
                Text(
                  'Brand: ${product.brand ?? 'Unknown brand'}',
                  style: context.textTheme.bodyLarge,
                ),
                AppSpacing.verticalXs,
                Text(
                  'Category: ${product.category ?? 'Unknown category'}',
                  style: context.textTheme.bodyLarge,
                ),
                if (product.stock != null) ...[
                  AppSpacing.verticalXs,
                  Text(
                    'In stock: ${product.stock}',
                    style: context.textTheme.bodyMedium,
                  ),
                ],
                if (product.description != null &&
                    product.description!.isNotEmpty) ...[
                  AppSpacing.verticalLg,
                  Text(
                    product.description!,
                    style: context.textTheme.bodyLarge,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _imagePlaceholder(BuildContext context) {
    return Container(
      height: 280,
      color: context.appColors.surfaceVariant,
      child: const Center(child: CircularProgressIndicator()),
    );
  }

  Widget _buildPlaceholderWithWarning(BuildContext context) {
    developer.log('Missing or invalid image URLs for product: ${product.id}', name: 'ProductDetailContent');
    return Container(
      height: 280,
      color: context.appColors.surfaceVariant,
      child: const Icon(Icons.shopping_bag, size: 64),
    );
  }
}
