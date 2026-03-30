import 'product_model.dart';

class ProductsResponseModel {
  const ProductsResponseModel({
    required this.products,
    required this.total,
  });

  final List<ProductModel> products;
  final int total;

  factory ProductsResponseModel.fromJson(Map<String, dynamic> json) {
    final productsList = json['products'] as List<dynamic>?;
    final total = json['total'];
    return ProductsResponseModel(
      products: productsList
              ?.map((e) => ProductModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      total: total is int ? total : int.tryParse(total?.toString() ?? '0') ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'products': products.map((e) => e.toJson()).toList(),
      'total': total,
    };
  }
}
