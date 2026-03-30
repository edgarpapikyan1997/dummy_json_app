import 'package:equatable/equatable.dart';

import 'product.dart';

class ProductsPage extends Equatable {
  const ProductsPage({
    required this.products,
    required this.total,
  });

  final List<Product> products;
  final int total;

  @override
  List<Object?> get props => [products, total];
}
