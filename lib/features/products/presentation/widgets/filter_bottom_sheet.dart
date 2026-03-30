import 'package:flutter/material.dart';

import '../../../../core/theme/theme_extensions.dart';
import '../../../../core/design_system/components/app_button.dart';
import '../../../../core/design_system/components/app_chip.dart';
import '../../../../core/design_system/layout/app_spacing.dart';
import '../../domain/entities/product_filter.dart';

class FilterBottomSheet extends StatefulWidget {
  const FilterBottomSheet({
    super.key,
    this.initialFilter,
    required this.categories,
    this.currentQuery,
    required this.onApply,
    required this.onClear,
  });

  final ProductFilter? initialFilter;
  final List<String> categories;
  final String? currentQuery;
  final void Function(ProductFilter filter) onApply;
  final VoidCallback onClear;

  static const List<({double min, double? max, String label})> priceRanges = [
    (min: 0.0, max: 100.0, label: '0 – 100'),
    (min: 100.0, max: 1000.0, label: '100 – 1,000'),
    (min: 1000.0, max: 10000.0, label: '1,000 – 10,000'),
    (min: 10000.0, max: 100000.0, label: '10,000 – 100,000'),
    (min: 100000.0, max: null, label: '100,000+'),
  ];

  static const List<double> ratingOptions = [1, 2, 3, 4, 5];

  static const List<({double min, double max, String label})> discountRanges = [
    (min: 0.0, max: 10.0, label: '0 – 10%'),
    (min: 10.0, max: 25.0, label: '10 – 25%'),
    (min: 25.0, max: 50.0, label: '25 – 50%'),
    (min: 50.0, max: 75.0, label: '50 – 75%'),
    (min: 75.0, max: 100.0, label: '75 – 100%'),
  ];

  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  String? _selectedCategory;
  int? _selectedPriceIndex;
  double? _selectedMinRating;
  int? _selectedDiscountIndex;

  @override
  void initState() {
    super.initState();
    final f = widget.initialFilter;
    if (f != null) {
      _selectedCategory = f.category;
      _selectedMinRating = f.minRating;
      if (f.minPrice != null || f.maxPrice != null) {
        final idx = FilterBottomSheet.priceRanges.indexWhere((r) {
          if (f.minPrice != r.min) return false;
          if (r.max == null) return f.maxPrice == null;
          return f.maxPrice == r.max;
        });
        if (idx >= 0) _selectedPriceIndex = idx;
      }
      if (f.minDiscount != null && f.maxDiscount != null) {
        final idx = FilterBottomSheet.discountRanges.indexWhere(
          (r) => f.minDiscount == r.min && f.maxDiscount == r.max,
        );
        if (idx >= 0) _selectedDiscountIndex = idx;
      }
    }
  }

  ProductFilter _buildFilter() {
    double? minPrice;
    double? maxPrice;
    if (_selectedPriceIndex != null) {
      final r = FilterBottomSheet.priceRanges[_selectedPriceIndex!];
      minPrice = r.min;
      maxPrice = r.max;
    }
    double? minDiscount;
    double? maxDiscount;
    if (_selectedDiscountIndex != null) {
      final r = FilterBottomSheet.discountRanges[_selectedDiscountIndex!];
      minDiscount = r.min;
      maxDiscount = r.max;
    }
    return ProductFilter(
      query: widget.currentQuery?.trim().isEmpty == false ? widget.currentQuery!.trim() : null,
      category: _selectedCategory,
      minPrice: minPrice,
      maxPrice: maxPrice,
      minRating: _selectedMinRating,
      minDiscount: minDiscount,
      maxDiscount: maxDiscount,
    );
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: ListView(
            controller: scrollController,
            children: [
              Text(
                'Filters',
                style: context.textTheme.headlineSmall,
              ),
              AppSpacing.verticalLg,
              Text(
                'Category',
                style: context.textTheme.titleMedium,
              ),
              AppSpacing.verticalSm,
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: widget.categories.map((c) {
                  final selected = _selectedCategory == c;
                  return AppChip(
                    label: c,
                    selected: selected,
                    onSelected: (_) {
                      setState(() => _selectedCategory = selected ? null : c);
                    },
                  );
                }).toList(),
              ),
              AppSpacing.verticalLg,
              Text(
                'Price range',
                style: context.textTheme.titleMedium,
              ),
              AppSpacing.verticalSm,
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: List.generate(FilterBottomSheet.priceRanges.length, (i) {
                  final r = FilterBottomSheet.priceRanges[i];
                  final selected = _selectedPriceIndex == i;
                  return AppChip(
                    label: r.label,
                    selected: selected,
                    onSelected: (_) {
                      setState(() => _selectedPriceIndex = selected ? null : i);
                    },
                  );
                }),
              ),
              AppSpacing.verticalLg,
              Text(
                'Minimum rating',
                style: context.textTheme.titleMedium,
              ),
              AppSpacing.verticalSm,
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: FilterBottomSheet.ratingOptions.map((r) {
                  final selected = _selectedMinRating == r;
                  return AppChip(
                    label: '$r+',
                    selected: selected,
                    icon: Icon(Icons.star, size: 16, color: context.appColors.star),
                    onSelected: (_) {
                      setState(() => _selectedMinRating = selected ? null : r);
                    },
                  );
                }).toList(),
              ),
              AppSpacing.verticalLg,
              Text(
                'Discount',
                style: context.textTheme.titleMedium,
              ),
              AppSpacing.verticalSm,
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: List.generate(FilterBottomSheet.discountRanges.length, (i) {
                  final r = FilterBottomSheet.discountRanges[i];
                  final selected = _selectedDiscountIndex == i;
                  return AppChip(
                    label: r.label,
                    selected: selected,
                    onSelected: (_) {
                      setState(() => _selectedDiscountIndex = selected ? null : i);
                    },
                  );
                }),
              ),
              AppSpacing.verticalXl,
              Row(
                children: [
                  Expanded(
                    child: AppButton(
                      label: 'Clear Filters',
                      variant: AppButtonVariant.outlined,
                      onPressed: () {
                        widget.onClear();
                        Navigator.of(context).pop();
                      },
                    ),
                  ),
                  AppSpacing.horizontalMd,
                  Expanded(
                    child: AppButton(
                      label: 'Apply Filters',
                      variant: AppButtonVariant.primary,
                      onPressed: () {
                        widget.onApply(_buildFilter());
                        Navigator.of(context).pop();
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
