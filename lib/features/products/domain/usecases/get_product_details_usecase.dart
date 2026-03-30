import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/product.dart';
import '../repositories/products_repository.dart';

class GetProductDetailsUseCase {
  GetProductDetailsUseCase(this._repository);

  final ProductsRepository _repository;

  Future<Either<Failure, Product>> call(int id) {
    return _repository.getProductDetails(id);
  }
}
