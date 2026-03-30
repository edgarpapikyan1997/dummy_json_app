part of 'products_bloc.dart';

sealed class ProductsEvent extends Equatable {
  const ProductsEvent();
  @override
  List<Object?> get props => [];
}

final class LoadProducts extends ProductsEvent {
  const LoadProducts({this.forceRefresh = false});
  final bool forceRefresh;
  @override
  List<Object?> get props => [forceRefresh];
}

final class RefreshProducts extends ProductsEvent {
  const RefreshProducts();
}

final class LoadMoreProducts extends ProductsEvent {
  const LoadMoreProducts();
}

final class SearchProducts extends ProductsEvent {
  const SearchProducts(this.query);
  final String query;
  @override
  List<Object?> get props => [query];
}

final class SearchProductsWithFilters extends ProductsEvent {
  const SearchProductsWithFilters(this.filter);
  final ProductFilter filter;
  @override
  List<Object?> get props => [filter];
}

final class ApplyFilters extends ProductsEvent {
  const ApplyFilters(this.filter);
  final ProductFilter filter;
  @override
  List<Object?> get props => [filter];
}

final class ClearFilters extends ProductsEvent {
  const ClearFilters();
}

final class LoadCategories extends ProductsEvent {
  const LoadCategories();
}

final class FilterByCategory extends ProductsEvent {
  const FilterByCategory(this.category);
  final String category;
  @override
  List<Object?> get props => [category];
}

final class LoadProductDetails extends ProductsEvent {
  const LoadProductDetails(this.id);
  final int id;
  @override
  List<Object?> get props => [id];
}

final class RestoreListFromDetails extends ProductsEvent {
  const RestoreListFromDetails();
}
