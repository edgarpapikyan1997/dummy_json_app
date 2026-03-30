import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/design_system/components/error_state.dart';
import '../../../../core/design_system/components/empty_state.dart';
import '../../../../core/design_system/components/product_detail_skeleton.dart';
import '../bloc/products_bloc.dart';
import '../widgets/product_detail_content.dart';

class ProductDetailsPage extends StatefulWidget {
  const ProductDetailsPage({super.key, required this.id});

  final int id;

  @override
  State<ProductDetailsPage> createState() => _ProductDetailsPageState();
}

class _ProductDetailsPageState extends State<ProductDetailsPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductsBloc>().add(LoadProductDetails(widget.id));
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return PopScope(
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) {
          context.read<ProductsBloc>().add(const RestoreListFromDetails());
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('Product Details', style: theme.textTheme.titleLarge),
          backgroundColor: theme.colorScheme.surfaceContainerHighest,
        ),
        body: BlocBuilder<ProductsBloc, ProductsState>(
          buildWhen: (prev, current) =>
              current is ProductDetailLoading ||
              current is ProductDetailsLoaded ||
              current is ProductDetailError ||
              current is ProductDetailEmpty,
          builder: (context, state) {
            if (state is ProductDetailLoading && state.id == widget.id) {
              return const ProductDetailSkeleton();
            }
            if (state is ProductDetailError) {
              return ErrorState(
                message: state.message,
                retryLabel: 'Retry',
                onRetry: () =>
                    context.read<ProductsBloc>().add(LoadProductDetails(widget.id)),
              );
            }
            if (state is ProductDetailEmpty && state.id == widget.id) {
              return EmptyState(
                message: 'Product not found',
                onClearFilters: () => Navigator.of(context).pop(),
                clearFiltersLabel: 'Back to list',
              );
            }
            if (state is ProductDetailsLoaded && state.product.id == widget.id) {
              return ProductDetailContent(product: state.product);
            }
            return const ProductDetailSkeleton();
          },
        ),
      ),
    );
  }
}
