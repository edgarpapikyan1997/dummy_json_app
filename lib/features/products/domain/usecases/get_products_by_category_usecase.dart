import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/products_page.dart';
import '../repositories/products_repository.dart';

class GetProductsByCategoryUseCase {
  GetProductsByCategoryUseCase(this._repository);

  final ProductsRepository _repository;

  Future<Either<Failure, ProductsPage>> call(String category) {
    return _repository.getProductsByCategory(category);
  }
}
