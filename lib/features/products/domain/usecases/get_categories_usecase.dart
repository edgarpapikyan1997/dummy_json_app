import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../repositories/products_repository.dart';

class GetCategoriesUseCase {
  GetCategoriesUseCase(this._repository);

  final ProductsRepository _repository;

  Future<Either<Failure, List<String>>> call() {
    return _repository.getCategories();
  }
}
