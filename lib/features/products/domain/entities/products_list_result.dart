import 'package:equatable/equatable.dart';

import 'products_page.dart';

class ProductsListResult extends Equatable {
  const ProductsListResult({
    required this.page,
    this.isFromCache = false,
    this.isStale = false,
  });

  final ProductsPage page;
  final bool isFromCache;
  final bool isStale;

  @override
  List<Object?> get props => [page, isFromCache, isStale];
}
