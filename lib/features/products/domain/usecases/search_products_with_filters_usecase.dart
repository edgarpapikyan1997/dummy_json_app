import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/product_filter.dart';
import '../entities/products_page.dart';
import '../repositories/products_repository.dart';

class SearchProductsWithFiltersUseCase {
  SearchProductsWithFiltersUseCase(this._repository);

  final ProductsRepository _repository;

  Future<Either<Failure, ProductsPage>> call(
    ProductFilter filter, {
    int limit = 20,
    int skip = 0,
  }) {
    return _repository.searchProductsWithFilters(filter, limit: limit, skip: skip);
  }
}
