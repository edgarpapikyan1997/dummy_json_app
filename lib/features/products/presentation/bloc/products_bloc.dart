import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

import '../../domain/entities/product.dart';
import '../../domain/entities/product_filter.dart';
import '../../domain/usecases/get_products_usecase.dart';
import '../../domain/usecases/search_products_with_filters_usecase.dart';
import '../../domain/usecases/get_categories_usecase.dart';
import '../../../../core/error/failures.dart';
import '../../domain/usecases/get_product_details_usecase.dart';

part 'products_event.dart';
part 'products_state.dart';

class ProductsBloc extends Bloc<ProductsEvent, ProductsState> {
  ProductsBloc({
    required GetProductsUseCase getProductsUseCase,
    required GetCategoriesUseCase getCategoriesUseCase,
    required GetProductDetailsUseCase getProductDetailsUseCase,
    required SearchProductsWithFiltersUseCase searchProductsWithFiltersUseCase,
  })  : _getProductsUseCase = getProductsUseCase,
        _getCategoriesUseCase = getCategoriesUseCase,
        _getProductDetailsUseCase = getProductDetailsUseCase,
        _searchProductsWithFiltersUseCase = searchProductsWithFiltersUseCase,
        super(ProductsInitial()) {
    on<LoadProducts>(_onLoadProducts);
    on<RefreshProducts>(_onRefreshProducts);
    on<LoadMoreProducts>(_onLoadMoreProducts);
    on<SearchProducts>(_onSearchProducts);
    on<SearchProductsWithFilters>(_onSearchProductsWithFilters);
    on<ApplyFilters>(_onApplyFilters);
    on<ClearFilters>(_onClearFilters);
    on<LoadCategories>(_onLoadCategories);
    on<FilterByCategory>(_onFilterByCategory);
    on<LoadProductDetails>(_onLoadProductDetails);
    on<RestoreListFromDetails>(_onRestoreListFromDetails);
  }

  static const int _pageSize = 20;

  final GetProductsUseCase _getProductsUseCase;
  final GetCategoriesUseCase _getCategoriesUseCase;
  final GetProductDetailsUseCase _getProductDetailsUseCase;
  final SearchProductsWithFiltersUseCase _searchProductsWithFiltersUseCase;

  ProductsState? _previousListState;

  Future<void> _onLoadProducts(LoadProducts event, Emitter<ProductsState> emit) async {
    emit(ProductsLoading());
    final result = await _getProductsUseCase(
      limit: _pageSize,
      skip: 0,
      forceRefresh: event.forceRefresh,
    );
    await result.fold<Future<void>>(
      (f) async => emit(ProductsError(f.message)),
      (listResult) async {
        final page = listResult.page;
        final categoriesResult = await _getCategoriesUseCase();
        List<String>? categories;
        categoriesResult.fold((_) {}, (list) => categories = list);
        emit(ProductsLoaded(
          products: page.products,
          total: page.total,
          categories: categories,
          selectedCategory: null,
          currentFilters: null,
          apiSkip: null,
          isFromCache: listResult.isFromCache,
          isStale: listResult.isStale,
        ));
      },
    );
  }

  Future<void> _onRefreshProducts(RefreshProducts event, Emitter<ProductsState> emit) async {
    final current = state;
    if (current is! ProductsLoaded && current is! ProductsLoadingMore) return;
    final categories = current is ProductsLoaded
        ? current.categories
        : (current as ProductsLoadingMore).categories;
    final currentFilters = current is ProductsLoaded
        ? current.currentFilters
        : (current as ProductsLoadingMore).currentFilters;
    final result = await _getProductsUseCase(
      limit: _pageSize,
      skip: 0,
      forceRefresh: true,
    );
    result.fold(
      (f) => emit(ProductsError(f.message)),
      (listResult) {
        final page = listResult.page;
        emit(ProductsLoaded(
          products: page.products,
          total: page.total,
          categories: categories,
          selectedCategory: null,
          currentFilters: currentFilters,
          apiSkip: null,
          isFromCache: false,
          isStale: false,
        ));
      },
    );
  }

  Future<void> _onLoadMoreProducts(LoadMoreProducts event, Emitter<ProductsState> emit) async {
    final current = state;
    if (current is! ProductsLoaded || !current.hasMore) return;
    final hasFilters = current.currentFilters != null && current.currentFilters!.hasActiveFilters;
    if (hasFilters) {
      final skip = current.apiSkip ?? 0;
      if (skip >= current.total) return;
      emit(ProductsLoadingMore(
        products: current.products,
        total: current.total,
        categories: current.categories,
        selectedCategory: current.selectedCategory,
        currentFilters: current.currentFilters,
        apiSkip: current.apiSkip,
      ));
      final result = await _searchProductsWithFiltersUseCase(
        current.currentFilters!,
        limit: _pageSize,
        skip: skip,
      );
      result.fold<void>(
        (f) => emit(ProductsError(f.message)),
        (page) {
          final updated = List<Product>.from(current.products)..addAll(page.products);
          emit(ProductsLoaded(
            products: updated,
            total: current.total,
            categories: current.categories,
            selectedCategory: current.selectedCategory,
            currentFilters: current.currentFilters,
            apiSkip: skip + _pageSize,
          ));
        },
      );
      return;
    }
    emit(ProductsLoadingMore(
      products: current.products,
      total: current.total,
      categories: current.categories,
      selectedCategory: current.selectedCategory,
      currentFilters: null,
      apiSkip: null,
    ));
    final skip = current.products.length;
    final result = await _getProductsUseCase(limit: _pageSize, skip: skip);
    result.fold<void>(
      (f) => emit(ProductsError(f.message)),
      (listResult) {
        final page = listResult.page;
        final updated = List<Product>.from(current.products)..addAll(page.products);
        emit(ProductsLoaded(
          products: updated,
          total: page.total,
          categories: current.categories,
          selectedCategory: current.selectedCategory,
          currentFilters: null,
          apiSkip: null,
        ));
      },
    );
  }

  Future<void> _onSearchProducts(SearchProducts event, Emitter<ProductsState> emit) async {
    final current = state;
    List<String>? categories;
    String? selectedCategory;
    if (current is ProductsLoaded) {
      categories = current.categories;
      selectedCategory = current.selectedCategory;
    } else if (current is ProductsLoadingMore) {
      categories = current.categories;
      selectedCategory = current.selectedCategory;
    }
    emit(ProductsLoading());
    final filter = ProductFilter(
      query: event.query.isEmpty ? null : event.query,
      category: selectedCategory,
    );
    final result = await _searchProductsWithFiltersUseCase(filter, limit: _pageSize, skip: 0);
    result.fold<void>(
      (f) => emit(ProductsError(f.message)),
      (page) => emit(ProductsLoaded(
        products: page.products,
        total: page.total,
        categories: categories,
        selectedCategory: selectedCategory,
        currentFilters: filter.hasActiveFilters ? filter : null,
        apiSkip: _pageSize,
      )),
    );
  }

  Future<void> _onSearchProductsWithFilters(
    SearchProductsWithFilters event,
    Emitter<ProductsState> emit,
  ) async {
    emit(ProductsLoading());
    final current = state;
    List<String>? categories;
    if (current is ProductsLoaded) categories = current.categories;
    final result = await _searchProductsWithFiltersUseCase(
      event.filter,
      limit: _pageSize,
      skip: 0,
    );
    result.fold<void>(
      (f) => emit(ProductsError(f.message)),
      (page) => emit(ProductsLoaded(
        products: page.products,
        total: page.total,
        categories: categories,
        selectedCategory: null,
        currentFilters: event.filter.hasActiveFilters ? event.filter : null,
        apiSkip: _pageSize,
      )),
    );
  }

  void _onApplyFilters(ApplyFilters event, Emitter<ProductsState> emit) {
    add(SearchProductsWithFilters(event.filter));
  }

  Future<void> _onClearFilters(ClearFilters event, Emitter<ProductsState> emit) async {
    add(const LoadProducts());
  }

  Future<void> _onLoadCategories(LoadCategories event, Emitter<ProductsState> emit) async {
    final result = await _getCategoriesUseCase();
    final current = state;
    result.fold<void>(
      (f) => emit(ProductsError(f.message)),
      (categories) {
        if (current is ProductsLoaded) {
          emit(ProductsLoaded(
            products: current.products,
            total: current.total,
            categories: categories,
            selectedCategory: current.selectedCategory,
            currentFilters: current.currentFilters,
            apiSkip: current.apiSkip,
          ));
        }
      },
    );
  }

  Future<void> _onFilterByCategory(FilterByCategory event, Emitter<ProductsState> emit) async {
    final current = state;
    List<String>? categories;
    String? currentQuery;
    if (current is ProductsLoaded) {
      categories = current.categories;
      currentQuery = current.currentFilters?.query;
    } else if (current is ProductsLoadingMore) {
      categories = current.categories;
      currentQuery = current.currentFilters?.query;
    }
    emit(ProductsLoading());
    final filter = ProductFilter(
      query: currentQuery,
      category: event.category,
    );
    final result = await _searchProductsWithFiltersUseCase(filter, limit: _pageSize, skip: 0);
    result.fold<void>(
      (f) => emit(ProductsError(f.message)),
      (page) => emit(ProductsLoaded(
        products: page.products,
        total: page.total,
        categories: categories,
        selectedCategory: event.category,
        currentFilters: filter.hasActiveFilters ? filter : null,
        apiSkip: _pageSize,
      )),
    );
  }

  Future<void> _onLoadProductDetails(LoadProductDetails event, Emitter<ProductsState> emit) async {
    if (state is ProductsLoaded || state is ProductsLoadingMore) {
      _previousListState = state;
    }
    emit(ProductDetailLoading(event.id));
    final result = await _getProductDetailsUseCase(event.id);
    result.fold<void>(
      (f) {
        if (f is NotFoundFailure) {
          emit(ProductDetailEmpty(event.id));
        } else {
          emit(ProductDetailError(f.message, id: event.id));
        }
      },
      (product) => emit(ProductDetailsLoaded(product)),
    );
  }

  void _onRestoreListFromDetails(RestoreListFromDetails event, Emitter<ProductsState> emit) {
    if (_previousListState != null) {
      emit(_previousListState!);
      _previousListState = null;
    } else {
      add(const LoadProducts());
    }
  }
}
