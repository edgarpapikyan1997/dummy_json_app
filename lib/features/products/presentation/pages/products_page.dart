import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/theme/theme_cubit.dart';
import '../../../../core/design_system/components/app_text_field.dart';
import '../../../../core/design_system/components/app_chip.dart';
import '../../../../core/design_system/components/app_loading_indicator.dart';
import '../../../../core/design_system/components/product_card_skeleton.dart';
import '../../../../core/design_system/components/error_state.dart';
import '../../../../core/design_system/components/empty_state.dart';
import '../../../../core/design_system/layout/app_spacing.dart';
import '../bloc/products_bloc.dart';
import '../widgets/product_card.dart';
import '../widgets/staggered_list_item.dart';
import '../widgets/filter_bottom_sheet.dart';
import '../../domain/entities/product_filter.dart';

class ProductsPage extends StatefulWidget {
  const ProductsPage({super.key, this.onProductSelected});

  final ValueChanged<int>? onProductSelected;

  @override
  State<ProductsPage> createState() => _ProductsPageState();
}

class _ProductsPageState extends State<ProductsPage> {
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();
  Timer? _searchDebounce;
  static const _searchDebounceDuration = Duration(milliseconds: 400);

  /// When in master-detail (onProductSelected != null), keep last list state
  /// so the left panel stays visible while the right panel shows detail.
  ProductsState? _cachedListState;

  bool _isRefreshing = false;

  @override
  void initState() {
    super.initState();
    context.read<ProductsBloc>().add(const LoadProducts());
    _scrollController.addListener(_onScroll);
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(_searchDebounceDuration, () {
      final query = _searchController.text.trim();
      if (query.isEmpty) {
        context.read<ProductsBloc>().add(const LoadProducts());
      } else {
        context.read<ProductsBloc>().add(SearchProducts(query));
      }
    });
  }

  void _onScroll() {
    final state = context.read<ProductsBloc>().state;
    if (state is! ProductsLoaded || !state.hasMore) return;
    if (state is ProductsLoadingMore) return;
    final threshold = _scrollController.position.maxScrollExtent - 200;
    if (_scrollController.position.pixels >= threshold) {
      context.read<ProductsBloc>().add(const LoadMoreProducts());
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('Products', style: theme.textTheme.titleLarge),
        backgroundColor: theme.colorScheme.surfaceContainerHighest,
        actions: [
          IconButton(
            icon: const Icon(Icons.palette_outlined),
            tooltip: 'Component showcase',
            onPressed: () => context.push('/showcase'),
          ),
          IconButton(
            icon: Icon(
              theme.brightness == Brightness.dark ? Icons.light_mode : Icons.dark_mode,
            ),
            onPressed: () => sl<ThemeCubit>().toggle(),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.md),
            child: AppTextField(
              controller: _searchController,
              hintText: 'Search products',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: IconButton(
                icon: const Icon(Icons.filter_list),
                onPressed: () => _openFilterSheet(context),
              ),
              onSubmitted: (value) {
                _searchDebounce?.cancel();
                final query = value.trim();
                if (query.isEmpty) {
                  context.read<ProductsBloc>().add(const LoadProducts());
                } else {
                  context.read<ProductsBloc>().add(SearchProducts(query));
                }
              },
            ),
          ),
        ),
      ),
      body: BlocConsumer<ProductsBloc, ProductsState>(
        listenWhen: (_, current) =>
            current is ProductsError ||
            current is ProductsLoaded ||
            current is ProductsLoadingMore,
        listener: (context, state) {
          if (state is ProductsError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Theme.of(context).colorScheme.error,
              ),
            );
          }
          if (state is ProductsLoaded || state is ProductsLoadingMore) {
            setState(() => _cachedListState = state);
          }
        },
        builder: (context, state) {
          final isDetailState = state is ProductDetailLoading ||
              state is ProductDetailsLoaded ||
              state is ProductDetailError ||
              state is ProductDetailEmpty;
          final useCachedList = widget.onProductSelected != null &&
              isDetailState &&
              _cachedListState != null &&
              (_cachedListState is ProductsLoaded ||
                  _cachedListState is ProductsLoadingMore);
          final displayState = useCachedList ? _cachedListState! : state;

          if (displayState is ProductsInitial) {
            return ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
              itemCount: 6,
              itemBuilder: (context, index) => const ProductCardSkeleton(),
            );
          }
          if (displayState is ProductsLoading) {
            return ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
              itemCount: 6,
              itemBuilder: (context, index) => const ProductCardSkeleton(),
            );
          }
          if (displayState is ProductsError) {
            return ErrorState(
              message: displayState.message,
              onRetry: () =>
                  context.read<ProductsBloc>().add(const LoadProducts()),
            );
          }
          if (displayState is ProductsLoaded || displayState is ProductsLoadingMore) {
            final products = displayState is ProductsLoaded
                ? displayState.products
                : (displayState as ProductsLoadingMore).products;
            final total = displayState is ProductsLoaded
                ? displayState.total
                : (displayState as ProductsLoadingMore).total;
            final categories = displayState is ProductsLoaded
                ? displayState.categories
                : (displayState as ProductsLoadingMore).categories;
            final selectedCategory = displayState is ProductsLoaded
                ? displayState.selectedCategory
                : (displayState as ProductsLoadingMore).selectedCategory;
            final isLoadingMore = displayState is ProductsLoadingMore;

            final isFromCache = displayState is ProductsLoaded && displayState.isFromCache;
            final isStale = displayState is ProductsLoaded && displayState.isStale;

            return RefreshIndicator(
              onRefresh: () async {
                setState(() => _isRefreshing = true);
                context.read<ProductsBloc>().add(const RefreshProducts());
                await context.read<ProductsBloc>().stream
                    .where((s) => s is ProductsLoaded || s is ProductsError)
                    .first;
                if (mounted) setState(() => _isRefreshing = false);
              },
              child: CustomScrollView(
                controller: _scrollController,
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  if (_isRefreshing)
                    SliverToBoxAdapter(
                      child: _RefreshingBanner(),
                    ),
                  if (isFromCache)
                    SliverToBoxAdapter(
                      child: _CacheIndicatorBanner(isStale: isStale),
                    ),
                if (categories != null && categories.isNotEmpty)
                  SliverToBoxAdapter(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      child: Row(
                        children: [
                          AppChip(
                            label: 'All',
                            selected: selectedCategory == null,
                            onSelected: (_) =>
                                context.read<ProductsBloc>().add(const LoadProducts()),
                          ),
                          AppSpacing.horizontalSm,
                          ...categories.map(
                            (c) => Padding(
                              padding: const EdgeInsets.only(right: AppSpacing.sm),
                              child: AppChip(
                                label: c,
                                selected: selectedCategory == c,
                                onSelected: (_) {
                                  context
                                      .read<ProductsBloc>()
                                      .add(FilterByCategory(c));
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                if (products.isEmpty)
                  SliverFillRemaining(
                    child: EmptyState(
                      message: 'No products found',
                      onClearFilters: _hasActiveFilters(displayState)
                          ? () => context.read<ProductsBloc>().add(const LoadProducts())
                          : null,
                    ),
                  )
                else
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        if (index == products.length) {
                          return const Padding(
                            padding: EdgeInsets.all(AppSpacing.lg),
                            child: Center(child: AppLoadingIndicator()),
                          );
                        }
                        final product = products[index];
                        final isInitialLoad = displayState is ProductsLoaded &&
                            displayState.apiSkip == null &&
                            !isLoadingMore;
                        final card = ProductCard(
                          product: product,
                          onTap: () {
                            if (widget.onProductSelected != null) {
                              widget.onProductSelected!(product.id);
                            } else {
                              _openDetails(context, product.id);
                            }
                          },
                        );
                        return isInitialLoad
                            ? StaggeredListItem(index: index, child: card)
                            : card;
                      },
                      childCount: products.length + (isLoadingMore || (products.length < total) ? 1 : 0),
                    ),
                  ),
              ],
            ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  void _openDetails(BuildContext context, int id) {
    context.push('/products/$id', extra: context.read<ProductsBloc>());
  }

  bool _hasActiveFilters(ProductsState state) {
    if (state is ProductsLoaded) {
      return state.selectedCategory != null ||
          (state.currentFilters != null && state.currentFilters!.hasActiveFilters);
    }
    if (state is ProductsLoadingMore) {
      return state.selectedCategory != null ||
          (state.currentFilters != null && state.currentFilters!.hasActiveFilters);
    }
    return false;
  }

  void _openFilterSheet(BuildContext context) {
    final state = context.read<ProductsBloc>().state;
    final isDetailState = state is ProductDetailLoading ||
        state is ProductDetailsLoaded ||
        state is ProductDetailError ||
        state is ProductDetailEmpty;
    final listState = (widget.onProductSelected != null &&
            isDetailState &&
            _cachedListState != null &&
            (_cachedListState is ProductsLoaded ||
                _cachedListState is ProductsLoadingMore))
        ? _cachedListState!
        : state;
    List<String> categories = [];
    ProductFilter? initialFilter;
    if (listState is ProductsLoaded) {
      categories = listState.categories ?? [];
      initialFilter = listState.currentFilters ??
          (listState.selectedCategory != null
              ? ProductFilter(category: listState.selectedCategory)
              : null);
    } else if (listState is ProductsLoadingMore) {
      categories = listState.categories ?? [];
      initialFilter = listState.currentFilters ??
          (listState.selectedCategory != null
              ? ProductFilter(category: listState.selectedCategory)
              : null);
    }
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) => FilterBottomSheet(
        initialFilter: initialFilter,
        categories: categories,
        currentQuery: _searchController.text,
        onApply: (filter) {
          context.read<ProductsBloc>().add(ApplyFilters(filter));
        },
        onClear: () {
          context.read<ProductsBloc>().add(const ClearFilters());
        },
      ),
    );
  }
}

class _RefreshingBanner extends StatelessWidget {
  const _RefreshingBanner();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: child,
        );
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.sm,
        ),
        color: theme.colorScheme.primaryContainer.withValues(alpha: 0.5),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Text(
              'Refreshing…',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CacheIndicatorBanner extends StatelessWidget {
  const _CacheIndicatorBanner({required this.isStale});

  final bool isStale;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.sm,
      ),
      color: theme.colorScheme.surfaceContainerHighest,
      child: Row(
        children: [
          Icon(
            Icons.cloud_done_outlined,
            size: 20,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              isStale
                  ? 'Showing cached data (outdated). Pull to refresh.'
                  : 'Showing cached data. Pull to refresh for latest.',
              style: theme.textTheme.bodySmall,
            ),
          ),
        ],
      ),
    );
  }
}
