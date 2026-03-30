import 'package:equatable/equatable.dart';

class ProductFilter extends Equatable {
  const ProductFilter({
    this.query,
    this.category,
    this.minPrice,
    this.maxPrice,
    this.minRating,
    this.minDiscount,
    this.maxDiscount,
  });

  final String? query;
  final String? category;
  final double? minPrice;
  final double? maxPrice;
  final double? minRating;
  final double? minDiscount;
  final double? maxDiscount;

  ProductFilter copyWith({
    String? query,
    String? category,
    double? minPrice,
    double? maxPrice,
    double? minRating,
    double? minDiscount,
    double? maxDiscount,
  }) {
    return ProductFilter(
      query: query ?? this.query,
      category: category ?? this.category,
      minPrice: minPrice ?? this.minPrice,
      maxPrice: maxPrice ?? this.maxPrice,
      minRating: minRating ?? this.minRating,
      minDiscount: minDiscount ?? this.minDiscount,
      maxDiscount: maxDiscount ?? this.maxDiscount,
    );
  }

  bool get hasActiveFilters =>
      (query != null && query!.isNotEmpty) ||
      (category != null && category!.isNotEmpty) ||
      minPrice != null ||
      maxPrice != null ||
      minRating != null ||
      minDiscount != null ||
      maxDiscount != null;

  @override
  List<Object?> get props => [query, category, minPrice, maxPrice, minRating, minDiscount, maxDiscount];
}
