import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/products_list_result.dart';
import '../repositories/products_repository.dart';

class GetProductsUseCase {
  GetProductsUseCase(this._repository);

  final ProductsRepository _repository;

  Future<Either<Failure, ProductsListResult>> call({
    required int limit,
    required int skip,
    bool forceRefresh = false,
  }) {
    return _repository.getProducts(
      limit: limit,
      skip: skip,
      forceRefresh: forceRefresh,
    );
  }
}
