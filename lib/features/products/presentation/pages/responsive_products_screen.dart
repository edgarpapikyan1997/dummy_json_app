import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/design_system/components/empty_state.dart';
import '../../../../core/design_system/components/error_state.dart';
import '../../../../core/design_system/components/product_detail_skeleton.dart';
import '../bloc/products_bloc.dart';
import '../widgets/product_detail_content.dart';
import 'products_page.dart';

const double _masterDetailBreakpoint = 768;
const double _listPanelWidth = 380;

class ResponsiveProductsScreen extends StatelessWidget {
  const ResponsiveProductsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final useMasterDetail = constraints.maxWidth >= _masterDetailBreakpoint;
        if (useMasterDetail) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                width: _listPanelWidth,
                child: ProductsPage(
                  onProductSelected: (id) {
                    context.read<ProductsBloc>().add(LoadProductDetails(id));
                  },
                ),
              ),
              Expanded(
                child: _MasterDetailDetailPanel(),
              ),
            ],
          );
        }
        return const ProductsPage();
      },
    );
  }
}

class _MasterDetailDetailPanel extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProductsBloc, ProductsState>(
      buildWhen: (prev, current) =>
          current is ProductDetailLoading ||
          current is ProductDetailsLoaded ||
          current is ProductDetailError ||
          current is ProductDetailEmpty ||
          current is ProductsLoaded ||
          current is ProductsLoadingMore ||
          current is ProductsInitial ||
          current is ProductsLoading,
      builder: (context, state) {
        if (state is ProductDetailLoading) {
          return const ProductDetailSkeleton();
        }
        if (state is ProductDetailError) {
          return ErrorState(
            message: state.message,
            retryLabel: 'Retry',
            onRetry: () {
              if (state.id != null) {
                context.read<ProductsBloc>().add(LoadProductDetails(state.id!));
              }
            },
          );
        }
        if (state is ProductDetailEmpty) {
          return EmptyState(message: 'Product not found');
        }
        if (state is ProductDetailsLoaded) {
          return ProductDetailContent(product: state.product);
        }
        return const EmptyState(message: 'Select a product');
      },
    );
  }
}
