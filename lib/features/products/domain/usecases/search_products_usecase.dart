import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/products_page.dart';
import '../repositories/products_repository.dart';

class SearchProductsUseCase {
  SearchProductsUseCase(this._repository);

  final ProductsRepository _repository;

  Future<Either<Failure, ProductsPage>> call(String query) {
    return _repository.searchProducts(query);
  }
}
