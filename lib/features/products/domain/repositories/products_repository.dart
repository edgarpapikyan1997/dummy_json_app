import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/product.dart';
import '../entities/product_filter.dart';
import '../entities/products_list_result.dart';
import '../entities/products_page.dart';

abstract class ProductsRepository {
  Future<Either<Failure, ProductsListResult>> getProducts({
    required int limit,
    required int skip,
    bool forceRefresh = false,
  });
  Future<Either<Failure, ProductsPage>> searchProducts(String query);
  Future<Either<Failure, ProductsPage>> searchProductsWithFilters(
    ProductFilter filter, {
    required int limit,
    required int skip,
  });
  Future<Either<Failure, List<String>>> getCategories();
  Future<Either<Failure, ProductsPage>> getProductsByCategory(String category);
  Future<Either<Failure, Product>> getProductDetails(int id);
}
