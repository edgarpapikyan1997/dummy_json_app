part of 'products_bloc.dart';

sealed class ProductsState extends Equatable {
  const ProductsState();
  @override
  List<Object?> get props => [];
}

final class ProductsInitial extends ProductsState {}

final class ProductsLoading extends ProductsState {}

final class ProductsLoaded extends ProductsState {
  const ProductsLoaded({
    required this.products,
    required this.total,
    this.categories,
    this.selectedCategory,
    this.currentFilters,
    this.apiSkip,
    this.isFromCache = false,
    this.isStale = false,
  });
  final List<Product> products;
  final int total;
  final List<String>? categories;
  final String? selectedCategory;
  final ProductFilter? currentFilters;
  final int? apiSkip;
  final bool isFromCache;
  final bool isStale;
  @override
  List<Object?> get props => [products, total, categories, selectedCategory, currentFilters, apiSkip, isFromCache, isStale];
  bool get hasMore => (apiSkip ?? products.length) < total;
}

final class ProductsLoadingMore extends ProductsState {
  const ProductsLoadingMore({
    required this.products,
    required this.total,
    this.categories,
    this.selectedCategory,
    this.currentFilters,
    this.apiSkip,
  });
  final List<Product> products;
  final int total;
  final List<String>? categories;
  final String? selectedCategory;
  final ProductFilter? currentFilters;
  final int? apiSkip;
  @override
  List<Object?> get props => [products, total, categories, selectedCategory, currentFilters, apiSkip];
}

final class ProductDetailLoading extends ProductsState {
  const ProductDetailLoading(this.id);
  final int id;
  @override
  List<Object?> get props => [id];
}

final class ProductDetailsLoaded extends ProductsState {
  const ProductDetailsLoaded(this.product);
  final Product product;
  @override
  List<Object?> get props => [product];
}

final class ProductDetailError extends ProductsState {
  const ProductDetailError(this.message, {this.id});
  final String message;
  final int? id;
  @override
  List<Object?> get props => [message, id];
}

final class ProductDetailEmpty extends ProductsState {
  const ProductDetailEmpty(this.id);
  final int id;
  @override
  List<Object?> get props => [id];
}

final class ProductsError extends ProductsState {
  const ProductsError(this.message);
  final String message;
  @override
  List<Object?> get props => [message];
}
